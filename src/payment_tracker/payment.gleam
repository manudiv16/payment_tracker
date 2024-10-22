import gleam/dynamic.{type DecodeErrors, type Dynamic}
import gleam/json
import gleam/result
import payment_tracker/error.{type AppError}
import sqlight

pub type Payment {
  Payment(
    id: String,
    user_id: String,
    ammount: Int,
    description: String,
    category: String,
    payment_type: PaymentType,
    timestamp: Int,
  )
}

pub fn payments_to_json(payment: Payment) -> json.Json {
  json.object([
    #("id", json.string(payment.id)),
    #("user_id", json.string(payment.user_id)),
    #("ammount", json.int(payment.ammount)),
    #("description", json.string(payment.description)),
    #("category", json.string(payment.category)),
    #("payment_type", json.string(payment_type_encoder(payment.payment_type))),
    #("timestamp", json.int(payment.timestamp)),
  ])
}

pub fn decode_payment(json: Dynamic) -> Result(Payment, AppError) {
  let decoder =
    dynamic.decode7(
      Payment,
      dynamic.field("id", dynamic.string),
      dynamic.field("user_id", dynamic.string),
      dynamic.field("ammount", dynamic.int),
      dynamic.field("description", dynamic.string),
      dynamic.field("category_id", dynamic.string),
      dynamic.field("payment_type", decode_payment_type),
      dynamic.field("timestamp", dynamic.int),
    )
  let result = decoder(json)

  case result {
    Ok(payment) -> Ok(payment)
    Error(errors) -> Error(filter_payment_type_error(errors, error.BadRequest))
  }
}

fn filter_payment_type_error(
  decode_errors: DecodeErrors,
  acc: AppError,
) -> AppError {
  case decode_errors {
    [dynamic.DecodeError("income, expense", _, _)] -> error.DecodePaymentType
    [dynamic.DecodeError(_, _, _), ..rest] ->
      filter_payment_type_error(rest, acc)
    [] -> acc
  }
}

pub type PaymentType {
  Income
  Expense
}

fn get_first(x, err) -> Result(a, AppError) {
  case x {
    Ok([x]) -> Ok(x)
    _ -> Error(err)
  }
}

fn decode_payment_type(dyn: Dynamic) -> Result(PaymentType, DecodeErrors) {
  use str <- result.try(dynamic.string(dyn))
  case str {
    "income" -> Ok(Income)
    "expense" -> Ok(Expense)
    _ -> Error([dynamic.DecodeError("income, expense", str, [])])
  }
}

pub fn payment_row_decoder() -> dynamic.Decoder(Payment) {
  dynamic.decode7(
    Payment,
    dynamic.element(0, dynamic.string),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.int),
    dynamic.element(3, dynamic.string),
    dynamic.element(4, dynamic.string),
    dynamic.element(5, decode_payment_type),
    dynamic.element(6, dynamic.int),
  )
}

pub fn payment_type_encoder(payment_type: PaymentType) -> String {
  case payment_type {
    Income -> "income"
    Expense -> "expense"
  }
}

pub fn get_payments_by_id(
  user_id: String,
  id: String,
  db: sqlight.Connection,
) -> Result(Payment, AppError) {
  let sql =
    "
select
  id,
  user_id,
  ammount,
  description,
  category,
  payment_type,
  timestamp
  from payments
  where user_id = ?1 and id = ?2
    "
  sqlight.query(
    sql,
    db,
    [sqlight.text(user_id), sqlight.text(id)],
    payment_row_decoder(),
  )
  |> get_first(error.PaymentNotFound)
}

pub fn get_payments_by_user(
  user_id: String,
  db: sqlight.Connection,
) -> Result(List(Payment), AppError) {
  let sql =
    "
select
  id,
  user_id,
  ammount,
  description,
  category,
  payment_type,
  timestamp
  from payments
  where user_id = ?1
    "

  sqlight.query(
    sql,
    on: db,
    with: [sqlight.text(user_id)],
    expecting: payment_row_decoder(),
  )
  |> result.map_error(fn(_) { error.CategoryNotFound })
}

pub fn filtered_payments(
  user_id: String,
  payment_type: PaymentType,
  db: sqlight.Connection,
) -> Result(Payment, AppError) {
  let sql =
    "
select
  id,
  user_id,
  ammount,
  description,
  category,
  payment_type,
  timestamp
  from payments
  where user_id = ?1 and payment_type = ?2
    "
  sqlight.query(
    sql,
    on: db,
    with: [
      sqlight.text(user_id),
      sqlight.text(payment_type_encoder(payment_type)),
    ],
    expecting: payment_row_decoder(),
  )
  |> get_first(error.PaymentNotFound)
}

pub fn get_payments_paginated(
  user_id: String,
  page: Int,
  limit: Int,
  db: sqlight.Connection,
) -> Result(List(Payment), AppError) {
  let sql =
    "
select
  id,
  user_id,
  ammount,
  description,
  category,
  payment_type,
  timestamp
  from payments
  where user_id = ?1
  limit ?2
  offset ?3
    "
  sqlight.query(
    sql,
    on: db,
    with: [sqlight.text(user_id), sqlight.int(limit), sqlight.int(page)],
    expecting: payment_row_decoder(),
  )
  |> result.map_error(fn(_) { error.CategoryNotFound })
}

pub fn get_payments_by_category(
  user_id: String,
  category: String,
  db: sqlight.Connection,
) -> Result(Payment, AppError) {
  let sql =
    "
select
  id,
  user_id,
  ammount,
  description,
  category,
  payment_type,
  timestamp
  from payments
  where user_id = ?1 and category = ?2
    "
  sqlight.query(
    sql,
    on: db,
    with: [sqlight.text(user_id), sqlight.text(category)],
    expecting: payment_row_decoder(),
  )
  |> get_first(error.PaymentNotFound)
}

pub fn insert_payment(
  payment: Payment,
  db: sqlight.Connection,
) -> Result(Nil, AppError) {
  let sql =
    "
insert into payments
  (id, user_id, ammount, description, category, payment_type, timestamp)
  values (?1, ?2, ?3, ?4, ?5, ?6, strftime('%s', 'now'))
    "
  sqlight.query(
    sql,
    on: db,
    with: [
      sqlight.text(payment.id),
      sqlight.text(payment.user_id),
      sqlight.int(payment.ammount),
      sqlight.text(payment.description),
      sqlight.text(payment.category),
      sqlight.text(payment_type_encoder(payment.payment_type)),
    ],
    expecting: Ok,
  )
  |> result.map(fn(_) { Nil })
  |> result.map_error(fn(_) { error.BadRequest })
}
