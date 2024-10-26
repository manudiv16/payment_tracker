SELECT
  id,
  user_id,
  amount,
  description,
  category,
  payment_type,
  timestamp
FROM payments
WHERE user_id = $1 AND category = $2;
