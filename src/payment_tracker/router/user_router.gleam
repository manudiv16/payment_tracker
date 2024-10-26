import gleam/http
import gleam/json
import gleam/result
import payment_tracker/error
import payment_tracker/user
import payment_tracker/web.{type Context}
import wisp.{type Request, type Response}

pub fn user(request: Request, ctx: Context) -> Response {
  case request.method {
    http.Post -> create_user(ctx, request)
    _ -> wisp.method_not_allowed([http.Post, http.Get])
  }
}

fn create_user(ctx: Context, request: Request) -> Response {
  use r_json <- wisp.require_json(request)
  let result = {
    use user <- result.try(user.decode_user(r_json))
    use id <- result.try(user.insert_user_squirrel(ctx.db, user))

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
