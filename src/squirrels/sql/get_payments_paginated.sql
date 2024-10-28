SELECT
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
