import envoy
import gleam/int
import gleam/option
import gleam/pgo
import gleam/result

pub type Connection =
  pgo.Connection

const default_host = "localhost"

const default_user = "postgres"

const default_database = "database"

const default_password = ""

const default_port = 5432

fn connection_options_from_variables() -> pgo.Config {
  let host = envoy.get("PGHOST") |> result.unwrap(default_host)
  let user = envoy.get("PGUSER") |> result.unwrap(default_user)
  let password = envoy.get("PGPASSWORD") |> result.unwrap(default_password)
  let database =
    envoy.get("PGDATABASE")
    |> result.unwrap(default_database)
  let port =
    envoy.get("PGPORT")
    |> result.then(int.parse)
    |> result.unwrap(default_port)

  pgo.Config(
    ..pgo.default_config(),
    host: host,
    user: user,
    password: option.Some(password),
    database: database,
    port: port,
  )
}

pub fn with_pgo_connection(f: fn(pgo.Connection) -> a) -> a {
  let db = pgo.connect(connection_options_from_variables())
  f(db)
}
