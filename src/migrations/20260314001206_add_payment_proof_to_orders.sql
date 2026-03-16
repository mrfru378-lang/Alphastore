-- Add payment_proof_url column to orders table
ALTER TABLE public.orders ADD COLUMN payment_proof_url TEXT;

-- Add comment for documentation
COMMENT ON COLUMN public.orders.payment_proof_url IS 'URL to uploaded payment proof image for bKash/Nagad transactions';