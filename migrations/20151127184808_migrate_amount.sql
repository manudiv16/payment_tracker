-- migrate:up
ALTER TABLE payments
ALTER COLUMN amount TYPE REAL USING amount::REAL;

-- migrate:down
ALTER TABLE payments
ALTER COLUMN amount TYPE INTEGER USING amount::INTEGER;
