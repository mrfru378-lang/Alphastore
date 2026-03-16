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

-- Create index on coupon code for fast lookups
CREATE INDEX idx_coupon_code ON coupons(coupon_code);
CREATE INDEX idx_product_id ON coupons(product_id);
CREATE INDEX idx_status ON coupons(status);
CREATE INDEX idx_expiry_date ON coupons(expiry_date);

-- Create coupon usage tracking table
CREATE TABLE IF NOT EXISTS coupon_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
  user_id UUID,
  used_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  order_id VARCHAR(100)
);

CREATE INDEX idx_coupon_usage ON coupon_usage(coupon_id);
CREATE INDEX idx_user_usage ON coupon_usage(user_id);
