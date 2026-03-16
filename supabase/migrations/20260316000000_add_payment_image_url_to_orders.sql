-- Add payment_image_url to orders table for latest proof field
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS payment_image_url TEXT;

COMMENT ON COLUMN public.orders.payment_image_url IS 'Public URL to uploaded payment proof image (new field, preferred over payment_proof_url)';
