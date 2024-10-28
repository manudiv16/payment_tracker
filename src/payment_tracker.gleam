import gleam/erlang/os
import gleam/erlang/process
import gleam/int
import gleam/result
import mist
import payment_tracker/database

import cors_builder as cors
import gleam/http
import payment_tracker/router
import payment_tracker/web.{Context}
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let port = load_port()
  let secret_key_base = load_application_secret()
  let assert Ok(priv) = wisp.priv_directory("payment_tracker")
  // let assert Ok(_) = database.with_connection(db_name, database.migrate_schema)

  let handle_request = fn(req) {
    use db <- database.with_pgo_connection()
    use req <- cors.wisp_middleware(req, cors())
    let ctx = Context(user_id: 0, db: db, static_path: priv <> "/static")
    router.handle_request(req, ctx)
  }

  let assert Ok(_) =
    wisp_mist.handler(handle_request, secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}

fn cors() {
  cors.new()
  |> cors.allow_origin("http://localhost:3000")
  |> cors.allow_origin("http://localhost:1234")
  |> cors.allow_method(http.Get)
  |> cors.allow_method(http.Post)
  |> cors.allow_header("Content-Type")
}

fn load_application_secret() -> String {
  os.get_env("APPLICATION_SECRET")
  |> result.unwrap("27434b28994f498182d459335258fb6e")
}

fn load_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(3000)
}
