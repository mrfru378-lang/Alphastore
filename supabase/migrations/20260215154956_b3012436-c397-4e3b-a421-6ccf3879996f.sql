-- Change default order status to 'Pending' for new orders
ALTER TABLE public.orders ALTER COLUMN status SET DEFAULT 'Pending';
