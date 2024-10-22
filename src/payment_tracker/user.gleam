import gleam/dynamic.{type Dynamic}
import gleam/result
import payment_tracker/error.{type AppError}
import sqlight

pub type User {
  User(id: String, name: String, email: String)
}

pub fn decode_json_user(json: Dynamic) -> Result(User, AppError) {
  dynamic.decode3(
    User,
    dynamic.field("id", dynamic.string),
    dynamic.field("name", dynamic.string),
    dynamic.field("email", dynamic.string),
  )(json)
  |> result.map_error(fn(_) { error.BadRequest })
  |> result.map(fn(user) { user })
}

pub fn decode_user(json: Dynamic) -> Result(User, AppError) {
  let decoder =
    dynamic.decode3(
      User,
      dynamic.field("id", dynamic.string),
      dynamic.field("name", dynamic.string),
      dynamic.field("email", dynamic.string),
    )
  let result = decoder(json)

  // In this example we are not going to be reporting specific errors to the
  // user, so we can discard the error and replace it with Nil.
  case result {
    Ok(user) -> Ok(user)
    Error(_) -> Error(error.BadRequest)
  }
}

fn get_first(x, err) -> Result(a, AppError) {
  case x {
    Ok([x]) -> Ok(x)
    _ -> Error(err)
  }
}

pub fn check_user_exists(
  db: sqlight.Connection,
  id: String,
) -> Result(String, AppError) {
  let sql =
    "
select
  id
from
  users
where
  id = ?1
"
  sqlight.query(
    sql,
    on: db,
    with: [sqlight.text(id)],
    expecting: dynamic.element(0, dynamic.string),
  )
  |> get_first(error.UserNotFound)
}

pub fn insert_user(
  db: sqlight.Connection,
  user: User,
) -> Result(String, AppError) {
  let sql =
    "
insert into users
  (id, name, email)
  values (?1, ?2, ?3)
  returning id;
"
  let b =
    sqlight.query(
      sql,
      on: db,
      with: [
        sqlight.text(user.id),
        sqlight.text(user.name),
        sqlight.text(user.email),
      ],
      expecting: dynamic.element(0, dynamic.string),
    )
  case b {
    Ok([id]) -> Ok(id)
    Error(a) ->
      case a.code {
        sqlight.ConstraintUnique -> Error(error.UserAlreadyExists)
        _ -> Error(error.SqlightError(a))
      }
    _ -> Error(error.UserNotFound)
  }
}

pub fn get_user(id: String, db: sqlight.Connection) -> Result(String, AppError) {
  let sql =
    "
select
  id
from
  users
where
  id = ?1
"
  sqlight.query(
    sql,
    on: db,
    with: [sqlight.text(id)],
    expecting: dynamic.element(0, dynamic.string),
  )
  |> get_first(error.UserNotFound)
}
