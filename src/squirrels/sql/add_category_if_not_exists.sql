INSERT INTO categories (id, user_id, name)
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
