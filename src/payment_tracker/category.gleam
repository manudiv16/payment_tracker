import gleam/dynamic.{type Dynamic}
import gleam/json
import gleam/result
import payment_tracker/database
import payment_tracker/error.{type AppError}
import payment_tracker/utils
import squirrels/sql

pub type Category {
  Category(id: String, user_id: String, name: String)
}

pub fn category_row_decoder() -> dynamic.Decoder(Category) {
  dynamic.decode3(
    Category,
    dynamic.element(0, dynamic.string),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
  )
}

pub fn category_to_json(category: Category) -> json.Json {
  json.object([
    #("category_id", json.string(category.id)),
    #("user_id", json.string(category.user_id)),
    #("category_name", json.string(category.name)),
  ])
}

pub fn category_json_decoder(json: Dynamic) -> Result(Category, AppError) {
  let decoder =
    dynamic.decode3(
      Category,
      dynamic.field("category_id", dynamic.string),
      dynamic.field("user_id", dynamic.string),
      dynamic.field("category_name", dynamic.string),
    )

  decoder(json)
  |> result.map_error(fn(_) { error.BadRequest })
  |> result.map(fn(category) { category })
}

pub fn add_category_if_not_exists(
  db: database.Connection,
  category: Category,
) -> Result(Nil, AppError) {
  let query =
    sql.add_category_if_not_exists(
      db,
      category.id,
      category.user_id,
      category.name,
    )
  let rows = {
    use _ <- utils.get_id_entity(query, error.CategoryNotInserted)
    Ok(category.id)
  }
  case rows {
    [] -> Ok(Nil)
    _ -> Error(error.CategoryNotInserted)
  }
}

pub fn set_category(
  db: database.Connection,
  category: Category,
) -> Result(String, AppError) {
  let query = sql.set_category(db, category.id, category.user_id, category.name)
  let rows = {
    use _ <- utils.get_if_not_empty_entity(query, error.CategoryNotInserted)
    Ok(category.id)
  }
  case rows {
    [Ok(s)] -> Ok(s)
    _ -> Error(error.CategoryNotInserted)
  }
}

pub fn get_categories(
  db: database.Connection,
  user_id: String,
) -> Result(List(Category), AppError) {
  let query = sql.get_categories(db, user_id)
  let error = error.CategoryNotFound
  use row <- utils.get_entity(query, error)
  let sql.GetCategoriesRow(id, user_id, name) = row
  Category(id, user_id, name)
}
