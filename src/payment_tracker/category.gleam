import gleam/dynamic.{type Dynamic}
import gleam/json
import gleam/result
import payment_tracker/error.{type AppError}
import sqlight

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
    #("category_user_id", json.string(category.user_id)),
    #("category_name", json.string(category.name)),
  ])
}

pub fn category_json_decoder(json: Dynamic) -> Result(Category, AppError) {
  let decoder =
    dynamic.decode3(
      Category,
      dynamic.field("category_id", dynamic.string),
      dynamic.field("category_user_id", dynamic.string),
      dynamic.field("category_name", dynamic.string),
    )

  decoder(json)
  |> result.map_error(fn(_) { error.BadRequest })
  |> result.map(fn(category) { category })
}

pub fn add_category_if_not_exists(
  category: Category,
  db: sqlight.Connection,
) -> Result(Nil, AppError) {
  let sql =
    "
  insert into categories
  (id, user_id, name)
  select ?1, ?2, ?3
  where not exists (
    select 1
    from categories
    where id = ?1
    );
  and exists (
    select 1
    from users
    where id = ?2
  );
"

  sqlight.query(
    sql,
    on: db,
    with: [
      sqlight.text(category.id),
      sqlight.text(category.user_id),
      sqlight.text(category.name),
    ],
    expecting: category_row_decoder(),
  )
  |> result.map(fn(_) { Nil })
  |> result.map_error(fn(_) { error.CategoryNotFoundAndNotInserted })
}

pub fn set_category(
  id: String,
  user_id: String,
  name: String,
  db: sqlight.Connection,
) -> Result(Nil, AppError) {
  let sql =
    "
insert into categories
  (id, user_id, name)
  values (?1, ?2, ?3);
"

  sqlight.query(
    sql,
    on: db,
    with: [sqlight.text(id), sqlight.text(user_id), sqlight.text(name)],
    expecting: category_row_decoder(),
  )
  |> result.map(fn(_) { Nil })
  |> result.map_error(fn(_) { error.BadRequest })
}

pub fn get_categories(
  user_id: String,
  db: sqlight.Connection,
) -> Result(List(Category), AppError) {
  let sql =
    "
select
  id,
  user_id,
  name
from
  categories
where
  user_id = ?1
order by
  id asc
"
  sqlight.query(
    sql,
    on: db,
    with: [sqlight.text(user_id)],
    expecting: category_row_decoder(),
  )
  |> result.map_error(fn(_) { error.CategoryNotFound })
}
