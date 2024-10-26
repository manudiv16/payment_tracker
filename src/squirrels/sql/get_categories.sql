SELECT
  id,
  user_id,
  name
FROM categories
WHERE user_id = $1
ORDER BY id ASC;
