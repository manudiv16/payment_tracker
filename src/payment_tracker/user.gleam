import gleam/dynamic.{type Dynamic}
import gleam/pgo.{type Returned}
import gleam/result
import payment_tracker/database
import payment_tracker/error.{type AppError}
import squirrels/sql

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

pub fn check_user_exists_squirrel(
  db: database.Connection,
  id: String,
) -> Result(String, AppError) {
  use get <- result.try(
    sql.check_user_exists(db, id)
    |> result.map_error(fn(_) { error.UserNotFound }),
  )
  case get {
    pgo.Returned(count, rows) ->
      case count < 1 {
        True -> Error(error.UserNotFound)
        False ->
          case rows {
            [sql.CheckUserExistsRow(id)] -> Ok(id)
            _ -> Error(error.UserNotFound)
          }
      }
  }
}

pub fn insert_user_squirrel(db: database.Connection, user: User) {
  use insert <- result.try(
    sql.insert_user(db, user.id, user.name, user.email)
    |> result.map_error(fn(_) { error.UserNotFound }),
  )
  case insert {
    pgo.Returned(count, rows) ->
      case count < 1 {
        True -> Error(error.UserNotFound)
        False ->
          case rows {
            [sql.InsertUserRow(id)] -> Ok(id)
            _ -> Error(error.UserNotFound)
          }
      }
  }
}

pub fn get_user_squirrel(
  db: database.Connection,
  id: String,
) -> Result(String, AppError) {
  use get <- result.try(
    sql.get_user(db, id)
    |> result.map_error(fn(_) { error.UserNotFound }),
  )
  case get {
    pgo.Returned(count, rows) ->
      case count < 1 {
        True -> Error(error.UserNotFound)
        False ->
          case rows {
            [sql.GetUserRow(id)] -> Ok(id)
            _ -> Error(error.UserNotFound)
          }
      }
  }
}
