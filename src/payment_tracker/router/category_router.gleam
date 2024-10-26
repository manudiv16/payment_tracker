import gleam/dynamic
import gleam/http
import gleam/json
import gleam/result
import payment_tracker/category
import payment_tracker/error
import payment_tracker/web.{type Context}
import wisp.{type Request, type Response}

pub fn categories(request: Request, ctx: Context) -> Response {
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

    use categories <- result.try(category.get_categories(ctx.db, id))
    Ok(
      json.to_string_builder(json.array(categories, category.category_to_json)),
    )
  }

  case result {
    Ok(body) -> wisp.json_response(body, 200)
    Error(_) -> wisp.internal_server_error()
  }
}
