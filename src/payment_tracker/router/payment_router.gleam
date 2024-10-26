import gleam/dynamic
import gleam/http
import gleam/json
import gleam/result
import payment_tracker/category
import payment_tracker/error
import payment_tracker/payment
import payment_tracker/web.{type Context}
import wisp.{type Request, type Response}

pub fn payment(request: Request, ctx: Context) -> Response {
  case request.method {
    http.Post -> create_payment(ctx, request)
    // http.Delete -> delete_payment(ctx, request)
    _ -> wisp.method_not_allowed([http.Post, http.Get])
  }
}

fn create_payment(ctx: Context, request: Request) {
  use r_json <- wisp.require_json(request)
  let result = {
    use payment <- result.try(payment.decode_payment(r_json))
    use category <- result.try(category.category_json_decoder(r_json))
    use _ <- result.try(category.add_category_if_not_exists(ctx.db, category))

    use _ <- result.try(payment.insert_payment(ctx.db, payment))

    Ok(
      json.to_string_builder(
        json.object([#("OK", json.string("Payment created"))]),
      ),
    )
  }
  let error_strin_builder =
    json.to_string_builder(
      json.object([#("error", json.string("Payment not created"))]),
    )
  case result {
    Ok(body) -> wisp.json_response(body, 201)
    Error(_) -> wisp.json_response(error_strin_builder, 409)
  }
}

pub fn payments(
  request: Request,
  ctx: Context,
  page: String,
  limit: String,
) -> Response {
  case request.method {
    http.Get -> get_payments(ctx, request, page, limit)
    _ -> wisp.method_not_allowed([http.Get])
  }
}

fn get_payments(
  ctx: Context,
  request: Request,
  page: String,
  limit: String,
) -> Response {
  use r_json <- wisp.require_json(request)
  let result = {
    use id <- result.try(
      dynamic.field("user_id", dynamic.string)(r_json)
      |> result.replace_error(error.BadRequest),
    )
    use page <- result.try(web.parse_int(page))
    use limit <- result.try(web.parse_int(limit))
    let payment =
      result.all(payment.get_payments_paginated(ctx.db, id, page, limit))
    use pay <- result.try(payment)
    Ok(json.to_string_builder(json.array(pay, payment.payments_to_json)))
  }
  case result {
    Ok(body) -> wisp.json_response(body, 200)
    Error(_) -> wisp.internal_server_error()
  }
}
