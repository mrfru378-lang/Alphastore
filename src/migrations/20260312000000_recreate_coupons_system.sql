-- Recreate coupons table (replacement for deleted migration)
-- This recreates the coupons system that was lost when the previous migration was deleted

-- Create coupons table
CREATE TABLE IF NOT EXISTS coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_code VARCHAR(50) NOT NULL UNIQUE,
  product_id VARCHAR(100) NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  category VARCHAR(50) NOT NULL,
  discount_percent DECIMAL(5,2) NOT NULL,
  usage_limit INTEGER NOT NULL,
  used_count INTEGER NOT NULL DEFAULT 0,
  expiry_date TIMESTAMP NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_coupon_code ON coupons(coupon_code);
CREATE INDEX IF NOT EXISTS idx_product_id ON coupons(product_id);
CREATE INDEX IF NOT EXISTS idx_status ON coupons(status);
CREATE INDEX IF NOT EXISTS idx_expiry_date ON coupons(expiry_date);

-- Create coupon usage tracking table
CREATE TABLE IF NOT EXISTS coupon_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
  user_id UUID,
  used_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  order_id VARCHAR(100)
);

-- Create indexes for coupon usage
CREATE INDEX IF NOT EXISTS idx_coupon_usage ON coupon_usage(coupon_id);
CREATE INDEX IF NOT EXISTS idx_user_usage ON coupon_usage(user_id);

-- Enable RLS on coupons table
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;

-- RLS Policies for coupons (read-only for users, full access for admins)
CREATE POLICY "Users can view active coupons" ON coupons
  FOR SELECT TO authenticated
  USING (status = 'active');

CREATE POLICY "Admins can view all coupons" ON coupons
  FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can insert coupons" ON coupons
  FOR INSERT TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update coupons" ON coupons
  FOR UPDATE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete coupons" ON coupons
  FOR DELETE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Enable RLS on coupon_usage table
ALTER TABLE coupon_usage ENABLE ROW LEVEL SECURITY;

-- RLS Policies for coupon_usage
CREATE POLICY "Users can view own coupon usage" ON coupon_usage
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Users can insert coupon usage" ON coupon_usage
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can view all coupon usage" ON coupon_usage
  FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can manage coupon usage" ON coupon_usage
  FOR UPDATE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));