import gleam/erlang/os
import gleam/erlang/process
import gleam/int
import gleam/result
import mist
import payment_tracker/database

import payment_tracker/router
import payment_tracker/web.{Context}
import wisp
import wisp/wisp_mist

const db_name = "payment_tracker.sqlite3"

pub fn main() {
  wisp.configure_logger()

  let port = load_port()
  let secret_key_base = load_application_secret()
  let assert Ok(priv) = wisp.priv_directory("payment_tracker")
  let assert Ok(_) = database.with_connection(db_name, database.migrate_schema)

  let handle_request = fn(req) {
    use db <- database.with_connection(db_name)
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

fn load_application_secret() -> String {
  os.get_env("APPLICATION_SECRET")
  |> result.unwrap("27434b28994f498182d459335258fb6e")
}

fn load_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(3000)
}
