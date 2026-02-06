-- Update orders table status constraint to include all valid statuses
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE orders 
  ADD CONSTRAINT orders_status_check 
  CHECK (status IN ('pending', 'assigned', 'in_progress', 'completed', 'cancelled'));
