import gleam/http.{Http}
import gleam/http/cookie
import gleam/http/response
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import payment_tracker/database
import payment_tracker/error.{type AppError}
import wisp.{type Response}

pub type Context {
  Context(db: database.Connection, user_id: Int, static_path: String)
}

pub fn parse_int(string: String) -> Result(Int, AppError) {
  string
  |> int.parse
  |> result.replace_error(error.BadRequest)
}

pub fn require_ok(t: Result(t, AppError), next: fn(t) -> Response) -> Response {
  case t {
    Ok(t) -> next(t)
    Error(error) -> error_to_response(error)
  }
}

pub fn error_to_response(error: AppError) -> Response {
  case error {
    error.UserNotFound -> user_not_found()
    error.NotFound -> wisp.not_found()
    error.MethodNotAllowed -> wisp.method_not_allowed([])
    error.BadRequest -> wisp.bad_request()
    error.UnprocessableEntity | error.ContentRequired ->
      wisp.unprocessable_entity()
    error.SqlightError(_) -> wisp.internal_server_error()
    _ -> wisp.internal_server_error()
  }
}

pub fn user_not_found() -> Response {
  let attributes =
    cookie.Attributes(..cookie.defaults(Http), max_age: option.Some(0))
  wisp.not_found()
  |> response.set_cookie("uid", "", attributes)
}

pub fn key_find(list: List(#(k, v)), key: k) -> Result(v, AppError) {
  list
  |> list.key_find(key)
  |> result.replace_error(error.UnprocessableEntity)
}
