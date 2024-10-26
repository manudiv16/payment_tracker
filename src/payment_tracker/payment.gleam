import gleam/dynamic.{type DecodeErrors, type Dynamic}
import gleam/json
import gleam/option
import gleam/pgo

import gleam/result
import payment_tracker/database
import payment_tracker/error.{type AppError}
import payment_tracker/utils
import squirrels/sql

pub type Payment {
  Payment(
    id: String,
    user_id: String,
    amount: Int,
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
    #("amount", json.int(payment.amount)),
    #("description", json.string(payment.description)),
    #("category_id", json.string(payment.category)),
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
      dynamic.field("amount", dynamic.int),
      dynamic.field("description", dynamic.string),
      dynamic.field("category_id", dynamic.string),
      dynamic.field("payment_type", decode_payment_type_dynamic),
      dynamic.field("timestamp", dynamic.int),
    )
  let result = decoder(json)

  case result {
    Ok(payment) -> Ok(payment)
    Error(errors) -> Error(filter_payment_type_error(errors, error.BadRequest))
  }
}

fn decode_payment_type_dynamic(
  dyn: Dynamic,
) -> Result(PaymentType, DecodeErrors) {
  use str <- result.try(dynamic.string(dyn))
  case str {
    "income" -> Ok(Income)
    "expense" -> Ok(Expense)
    _ -> Error([dynamic.DecodeError("income, expense", str, [])])
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

pub fn payment_type_encoder(payment_type: PaymentType) -> String {
  case payment_type {
    Income -> "income"
    Expense -> "expense"
  }
}

fn decode_payment_type(
  id: String,
  user_id: String,
  amount: Int,
  description: String,
  category: String,
  payment_type: String,
  timestamp: Int,
) -> Result(Payment, AppError) {
  case payment_type {
    "income" ->
      Ok(Payment(id, user_id, amount, description, category, Income, timestamp))
    "expense" ->
      Ok(Payment(id, user_id, amount, description, category, Expense, timestamp))
    _ -> Error(error.DecodePaymentType)
  }
}

pub fn get_payments_by_id(
  db: database.Connection,
  user_id: String,
  id: String,
) -> List(Result(Payment, AppError)) {
  let get = sql.get_payments_by_id(db, user_id, id)
  use row <- utils.get_if_not_empty_entity(get, error.PaymentNotFound)
  let sql.GetPaymentsByIdRow(
    id,
    user_id,
    amount,
    description,
    category,
    payment_type,
    timestamp,
  ) = row
  decode_payment_type(
    id,
    user_id,
    amount,
    description,
    category,
    payment_type,
    timestamp,
  )
}

pub fn get_payments_by_user(
  db: database.Connection,
  user_id: String,
) -> List(Result(Payment, AppError)) {
  let get = sql.get_payments_by_user(db, user_id)
  use row <- utils.get_if_not_empty_entity(get, error.PaymentNotFound)
  let sql.GetPaymentsByUserRow(
    id,
    user_id,
    amount,
    description,
    category,
    payment_type,
    timestamp,
  ) = row
  decode_payment_type(
    id,
    user_id,
    amount,
    description,
    category,
    payment_type,
    timestamp,
  )
}

pub fn filtered_payments(
  db: database.Connection,
  user_id: String,
  payment_type: PaymentType,
) -> List(Result(Payment, AppError)) {
  let get =
    sql.filtered_payments(db, user_id, payment_type_encoder(payment_type))
  use row <- utils.get_if_not_empty_entity(get, error.PaymentNotFound)
  let sql.FilteredPaymentsRow(
    id,
    user_id,
    amount,
    description,
    category,
    payment_type,
    timestamp,
  ) = row
  decode_payment_type(
    id,
    user_id,
    amount,
    description,
    category,
    payment_type,
    timestamp,
  )
}

pub fn get_payments_paginated(
  db: database.Connection,
  user_id: String,
  page: Int,
  limit: Int,
) -> List(Result(Payment, AppError)) {
  let get = sql.get_payments_paginated(db, user_id, page, limit)
  use row <- utils.get_if_not_empty_entity(get, error.PaymentNotFound)
  let sql.GetPaymentsPaginatedRow(
    id,
    user_id,
    amount,
    description,
    category,
    payment_type,
    timestamp,
  ) = row
  decode_payment_type(
    id,
    user_id,
    amount,
    description,
    category,
    payment_type,
    timestamp,
  )
}

pub fn get_payments_by_category(
  db: database.Connection,
  user_id: String,
  category: String,
) -> List(Result(Payment, AppError)) {
  let query = sql.get_payments_by_category(db, user_id, category)
  use row <- utils.get_if_not_empty_entity(query, error.PaymentNotFound)
  let sql.GetPaymentsByCategoryRow(
    id,
    user_id,
    amount,
    description,
    category,
    payment_type,
    timestamp,
  ) = row
  decode_payment_type(
    id,
    user_id,
    amount,
    description,
    category,
    payment_type,
    timestamp,
  )
}

pub fn insert_payment(
  db: database.Connection,
  payment: Payment,
) -> Result(String, AppError) {
  let query =
    sql.insert_payment(
      db,
      payment.id,
      payment.user_id,
      payment.amount,
      payment.description,
      payment.category,
      payment_type_encoder(payment.payment_type),
    )
  case query {
    Ok(_) -> Ok(payment.id)
    Error(pgo.ConstraintViolated(message, _, _)) ->
      Error(error.PaymentNotInserted(option.Some(message)))
    Error(pgo.PostgresqlError(_, _, _)) ->
      Error(error.PaymentNotInserted(option.None))
    Error(_) -> Error(error.PaymentNotInserted(option.None))
  }
}
