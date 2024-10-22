import gleam/dynamic
import gleam/http
import gleam/json
import gleam/result
import payment_tracker/category
import payment_tracker/error
import payment_tracker/payment
import payment_tracker/user
import payment_tracker/web.{type Context}

import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  case wisp.path_segments(req) {
    ["user"] -> user(req, ctx)
    ["payment"] -> payment(req, ctx)
    ["payments", page, limit] -> payments(req, ctx, page, limit)
    ["categories"] -> categories(req, ctx)
    _ -> wisp.not_found()
  }
}

// Category routes
fn categories(request: Request, ctx: Context) -> Response {
  case request.method {
    http.Get -> get_categories(ctx, request)
    _ -> wisp.method_not_allowed([http.Get])
  }
}

fn get_categories(ctx: Context, request: Request) -> Response {
  use r_json <- wisp.require_json(request)
  let result = {
    use id <- result.try(
      dynamic.field("user_id", dynamic.string)(r_json)
      |> result.replace_error(error.BadRequest),
    )

    use categories <- result.try(category.get_categories(id, ctx.db))
    Ok(
      json.to_string_builder(json.array(categories, category.category_to_json)),
    )
  }
  case result {
    Ok(body) -> wisp.json_response(body, 200)
    Error(_) -> wisp.internal_server_error()
  }
}

// Payment routes

fn payment(request: Request, ctx: Context) -> Response {
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
    use _ <- result.try(category.add_category_if_not_exists(category, ctx.db))
    use _ <- result.try(payment.insert_payment(payment, ctx.db))

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

fn payments(
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
    use payment <- result.try(payment.get_payments_paginated(
      id,
      page,
      limit,
      ctx.db,
    ))
    Ok(json.to_string_builder(json.array(payment, payment.payments_to_json)))
  }
  case result {
    Ok(body) -> wisp.json_response(body, 200)
    Error(_) -> wisp.internal_server_error()
  }
}

// User routes

fn user(request: Request, ctx: Context) -> Response {
  case request.method {
    http.Post -> create_user(ctx, request)
    _ -> wisp.method_not_allowed([http.Post, http.Get])
  }
}

fn create_user(ctx: Context, request: Request) -> Response {
  use r_json <- wisp.require_json(request)
  let result = {
    use user <- result.try(user.decode_user(r_json))
    use id <- result.try(user.insert_user(ctx.db, user))
    Ok(json.to_string_builder(json.object([#("id", json.string(id))])))
  }
  let unique_user =
    json.to_string_builder(
      json.object([#("error", json.string("User already exists"))]),
    )
  case result {
    Ok(body) -> wisp.json_response(body, 201)
    Error(error.UserAlreadyExists) -> wisp.json_response(unique_user, 409)
    Error(_) -> wisp.bad_request()
  }
}
