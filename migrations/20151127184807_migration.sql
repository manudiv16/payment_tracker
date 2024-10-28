-- migrate:up
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY NOT NULL,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  CONSTRAINT fk_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
  id TEXT PRIMARY KEY NOT NULL,
  user_id TEXT NOT NULL,
  amount INTEGER NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  payment_type TEXT NOT NULL,
  timestamp BIGINT NOT NULL,
  CONSTRAINT fk_user_payment
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_category
    FOREIGN KEY (category) REFERENCES categories(id)
);

-- migrate:down
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;
