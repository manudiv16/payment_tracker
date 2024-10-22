import gleam/result
import payment_tracker/error.{type AppError}
import sqlight

pub type Connection =
  sqlight.Connection

pub fn with_connection(name: String, f: fn(sqlight.Connection) -> a) -> a {
  use db <- sqlight.with_connection(name)
  let assert Ok(_) = sqlight.exec("PRAGMA foreign_keys = ON;", db)
  f(db)
}

/// Run some idempotent DDL to ensure we have the PostgreSQL database schema
/// that we want. This should be run when the application starts.
pub fn migrate_schema(db: sqlight.Connection) -> Result(Nil, AppError) {
  sqlight.exec(
    "
create table if not exists users (
  id text primary key not null,
  name text not null,
  email text not null unique
) strict;
create table if not exists categories (
  id text primary key not null,
  user_id text not null,
  name text not null,
  foreign key (user_id) references users(id)
) strict;
create table if not exists payments (
  id text primary key not null,
  user_id text not null,
  ammount integer not null,
  description text not null,
  category text not null,
  payment_type text not null,
  timestamp integer not null,
  foreign key (user_id) references users(id),
  foreign key (category) references categories(id)
) strict;

    ",
    db,
  )
  |> result.map_error(error.SqlightError)
}
