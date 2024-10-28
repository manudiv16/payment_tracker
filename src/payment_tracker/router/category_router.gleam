import gleam/dynamic
import gleam/http
import gleam/json
import gleam/result
import payment_tracker/category
import payment_tracker/error
import payment_tracker/web.{type Context}
import wisp.{type Request, type Response}

pub fn categories(request: Request, ctx: Context, user_id: String) -> Response {
  case request.method {
    http.Get -> get_categories(ctx, user_id)
    _ -> wisp.method_not_allowed([http.Get])
  }
}

fn get_categories(ctx: Context, user_id: String) -> Response {
  let result = {
    use categories <- result.try(category.get_categories(ctx.db, user_id))
    Ok(
      json.to_string_builder(json.array(
        categories,
        category.get_category_to_json,
      )),
    )
  }

  case result {
    Ok(body) -> wisp.json_response(body, 200)
    Error(_) -> wisp.internal_server_error()
  }
}
