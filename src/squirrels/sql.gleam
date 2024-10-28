import decode
import gleam/pgo

/// Runs the `insert_payment` query
/// defined in `./src/squirrels/sql/insert_payment.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_payment(db, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO payments (id, user_id, amount, description, category, payment_type, timestamp)
VALUES ($1, $2, $3, $4, $5, $6, EXTRACT(EPOCH FROM NOW()));
"
  |> pgo.execute(
    db,
    [
      pgo.text(arg_1),
      pgo.text(arg_2),
      pgo.float(arg_3),
      pgo.text(arg_4),
      pgo.text(arg_5),
      pgo.text(arg_6),
    ],
    decode.from(decoder, _),
  )
}

/// A row you get from running the `get_user` query
/// defined in `./src/squirrels/sql/get_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserRow {
  GetUserRow(id: String)
}

/// Runs the `get_user` query
/// defined in `./src/squirrels/sql/get_user.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      GetUserRow(id: id)
    })
    |> decode.field(0, decode.string)

  "SELECT id
FROM users
WHERE id = $1;
"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// A row you get from running the `get_payments_by_user` query
/// defined in `./src/squirrels/sql/get_payments_by_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPaymentsByUserRow {
  GetPaymentsByUserRow(
    id: String,
    user_id: String,
    amount: Float,
    description: String,
    category: String,
    category_name: String,
    payment_type: String,
    timestamp: Int,
  )
}

/// Runs the `get_payments_by_user` query
/// defined in `./src/squirrels/sql/get_payments_by_user.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_payments_by_user(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      use amount <- decode.parameter
      use description <- decode.parameter
      use category <- decode.parameter
      use category_name <- decode.parameter
      use payment_type <- decode.parameter
      use timestamp <- decode.parameter
      GetPaymentsByUserRow(
        id: id,
        user_id: user_id,
        amount: amount,
        description: description,
        category: category,
        category_name: category_name,
        payment_type: payment_type,
        timestamp: timestamp,
      )
    })
    |> decode.field(0, decode.string)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.float)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.string)
    |> decode.field(5, decode.string)
    |> decode.field(6, decode.string)
    |> decode.field(7, decode.int)

  "SELECT
  payments.id,
  payments.user_id,
  payments.amount,
  payments.description,
  payments.category,
  categories.name AS category_name,
  payments.payment_type,
  payments.timestamp
FROM payments
JOIN categories ON payments.category = categories.id
WHERE payments.user_id = $1
"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// Runs the `set_category` query
/// defined in `./src/squirrels/sql/set_category.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn set_category(db, arg_1, arg_2, arg_3) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO categories (id, user_id, name)
VALUES ($1, $2, $3);
"
  |> pgo.execute(
    db,
    [pgo.text(arg_1), pgo.text(arg_2), pgo.text(arg_3)],
    decode.from(decoder, _),
  )
}

/// A row you get from running the `get_payments_paginated` query
/// defined in `./src/squirrels/sql/get_payments_paginated.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPaymentsPaginatedRow {
  GetPaymentsPaginatedRow(
    id: String,
    user_id: String,
    amount: Float,
    description: String,
    category: String,
    category_name: String,
    payment_type: String,
    timestamp: Int,
  )
}

/// Runs the `get_payments_paginated` query
/// defined in `./src/squirrels/sql/get_payments_paginated.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_payments_paginated(db, arg_1, arg_2, arg_3) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      use amount <- decode.parameter
      use description <- decode.parameter
      use category <- decode.parameter
      use category_name <- decode.parameter
      use payment_type <- decode.parameter
      use timestamp <- decode.parameter
      GetPaymentsPaginatedRow(
        id: id,
        user_id: user_id,
        amount: amount,
        description: description,
        category: category,
        category_name: category_name,
        payment_type: payment_type,
        timestamp: timestamp,
      )
    })
    |> decode.field(0, decode.string)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.float)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.string)
    |> decode.field(5, decode.string)
    |> decode.field(6, decode.string)
    |> decode.field(7, decode.int)

  "SELECT
  payments.id,
  payments.user_id,
  payments.amount,
  payments.description,
  payments.category,
  categories.name AS category_name,
  payments.payment_type,
  payments.timestamp
FROM payments
JOIN categories ON payments.category = categories.id
WHERE payments.user_id = $1
LIMIT $2
OFFSET $3;
"
  |> pgo.execute(
    db,
    [pgo.text(arg_1), pgo.int(arg_2), pgo.int(arg_3)],
    decode.from(decoder, _),
  )
}

/// A row you get from running the `get_categories` query
/// defined in `./src/squirrels/sql/get_categories.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetCategoriesRow {
  GetCategoriesRow(id: String, user_id: String, name: String)
}

/// Runs the `get_categories` query
/// defined in `./src/squirrels/sql/get_categories.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_categories(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      use name <- decode.parameter
      GetCategoriesRow(id: id, user_id: user_id, name: name)
    })
    |> decode.field(0, decode.string)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.string)

  "SELECT
  id,
  user_id,
  name
FROM categories
WHERE user_id = $1
ORDER BY id ASC;
"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// A row you get from running the `insert_user` query
/// defined in `./src/squirrels/sql/insert_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type InsertUserRow {
  InsertUserRow(id: String)
}

/// Runs the `insert_user` query
/// defined in `./src/squirrels/sql/insert_user.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_user(db, arg_1, arg_2, arg_3) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      InsertUserRow(id: id)
    })
    |> decode.field(0, decode.string)

  "INSERT INTO users (id, name, email)
VALUES ($1, $2, $3)
RETURNING id;
"
  |> pgo.execute(
    db,
    [pgo.text(arg_1), pgo.text(arg_2), pgo.text(arg_3)],
    decode.from(decoder, _),
  )
}

/// A row you get from running the `check_user_exists` query
/// defined in `./src/squirrels/sql/check_user_exists.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CheckUserExistsRow {
  CheckUserExistsRow(id: String)
}

/// Runs the `check_user_exists` query
/// defined in `./src/squirrels/sql/check_user_exists.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn check_user_exists(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      CheckUserExistsRow(id: id)
    })
    |> decode.field(0, decode.string)

  "SELECT id
FROM users
WHERE id = $1;
"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// Runs the `add_category_if_not_exists` query
/// defined in `./src/squirrels/sql/add_category_if_not_exists.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn add_category_if_not_exists(db, arg_1, arg_2, arg_3) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO categories (id, user_id, name)
SELECT $1, $2, $3
WHERE NOT EXISTS (
    SELECT 1
    FROM categories
    WHERE id = $1
) AND EXISTS (
    SELECT 1
    FROM users
    WHERE id = $2
);
"
  |> pgo.execute(
    db,
    [pgo.text(arg_1), pgo.text(arg_2), pgo.text(arg_3)],
    decode.from(decoder, _),
  )
}

/// A row you get from running the `filtered_payments` query
/// defined in `./src/squirrels/sql/filtered_payments.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FilteredPaymentsRow {
  FilteredPaymentsRow(
    id: String,
    user_id: String,
    amount: Float,
    description: String,
    category: String,
    payment_type: String,
    timestamp: Int,
  )
}

/// Runs the `filtered_payments` query
/// defined in `./src/squirrels/sql/filtered_payments.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn filtered_payments(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      use amount <- decode.parameter
      use description <- decode.parameter
      use category <- decode.parameter
      use payment_type <- decode.parameter
      use timestamp <- decode.parameter
      FilteredPaymentsRow(
        id: id,
        user_id: user_id,
        amount: amount,
        description: description,
        category: category,
        payment_type: payment_type,
        timestamp: timestamp,
      )
    })
    |> decode.field(0, decode.string)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.float)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.string)
    |> decode.field(5, decode.string)
    |> decode.field(6, decode.int)

  "SELECT
  id,
  user_id,
  amount,
  description,
  category,
  payment_type,
  timestamp
FROM payments
WHERE user_id = $1 AND payment_type = $2;
"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _))
}

/// A row you get from running the `get_payments_by_id` query
/// defined in `./src/squirrels/sql/get_payments_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPaymentsByIdRow {
  GetPaymentsByIdRow(
    id: String,
    user_id: String,
    amount: Float,
    description: String,
    category: String,
    payment_type: String,
    timestamp: Int,
  )
}

/// Runs the `get_payments_by_id` query
/// defined in `./src/squirrels/sql/get_payments_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_payments_by_id(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      use amount <- decode.parameter
      use description <- decode.parameter
      use category <- decode.parameter
      use payment_type <- decode.parameter
      use timestamp <- decode.parameter
      GetPaymentsByIdRow(
        id: id,
        user_id: user_id,
        amount: amount,
        description: description,
        category: category,
        payment_type: payment_type,
        timestamp: timestamp,
      )
    })
    |> decode.field(0, decode.string)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.float)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.string)
    |> decode.field(5, decode.string)
    |> decode.field(6, decode.int)

  "SELECT
  id,
  user_id,
  amount,
  description,
  category,
  payment_type,
  timestamp
FROM payments
WHERE user_id = $1 AND id = $2;
"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _))
}

/// A row you get from running the `get_payments_by_category` query
/// defined in `./src/squirrels/sql/get_payments_by_category.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPaymentsByCategoryRow {
  GetPaymentsByCategoryRow(
    id: String,
    user_id: String,
    amount: Float,
    description: String,
    category: String,
    payment_type: String,
    timestamp: Int,
  )
}

/// Runs the `get_payments_by_category` query
/// defined in `./src/squirrels/sql/get_payments_by_category.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_payments_by_category(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      use amount <- decode.parameter
      use description <- decode.parameter
      use category <- decode.parameter
      use payment_type <- decode.parameter
      use timestamp <- decode.parameter
      GetPaymentsByCategoryRow(
        id: id,
        user_id: user_id,
        amount: amount,
        description: description,
        category: category,
        payment_type: payment_type,
        timestamp: timestamp,
      )
    })
    |> decode.field(0, decode.string)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.float)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.string)
    |> decode.field(5, decode.string)
    |> decode.field(6, decode.int)

  "SELECT
  id,
  user_id,
  amount,
  description,
  category,
  payment_type,
  timestamp
FROM payments
WHERE user_id = $1 AND category = $2;
"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _))
}
