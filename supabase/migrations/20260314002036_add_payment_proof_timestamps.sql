-- Add upload and expiry timestamps for payment proof to orders
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS payment_proof_uploaded_at timestamptz DEFAULT now();

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS payment_proof_expires_at timestamptz DEFAULT (now() + INTERVAL '3 days');

-- Optional: Add index for cleanup queries
CREATE INDEX IF NOT EXISTS idx_orders_payment_proof_expires_at ON public.orders(payment_proof_expires_at);
