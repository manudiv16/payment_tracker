INSERT INTO payments (id, user_id, amount, description, category, payment_type, timestamp)
VALUES ($1, $2, $3, $4, $5, $6, EXTRACT(EPOCH FROM NOW()));
