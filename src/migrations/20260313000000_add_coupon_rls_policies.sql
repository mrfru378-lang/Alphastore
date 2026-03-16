-- Enable RLS on coupons table
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;

-- RLS Policies for coupons (read-only for users, full access for admins)
CREATE POLICY "Users can view active coupons" ON public.coupons 
  FOR SELECT TO authenticated 
  USING (status = 'active');

CREATE POLICY "Admins can view all coupons" ON public.coupons 
  FOR SELECT TO authenticated 
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can insert coupons" ON public.coupons 
  FOR INSERT TO authenticated 
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update coupons" ON public.coupons 
  FOR UPDATE TO authenticated 
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete coupons" ON public.coupons 
  FOR DELETE TO authenticated 
  USING (public.has_role(auth.uid(), 'admin'));

-- Enable RLS on coupon_usage table
ALTER TABLE public.coupon_usage ENABLE ROW LEVEL SECURITY;

-- RLS Policies for coupon_usage
CREATE POLICY "Users can view own coupon usage" ON public.coupon_usage 
  FOR SELECT TO authenticated 
  USING (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Users can insert coupon usage" ON public.coupon_usage 
  FOR INSERT TO authenticated 
  WITH CHECK (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can view all coupon usage" ON public.coupon_usage 
  FOR SELECT TO authenticated 
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can manage coupon usage" ON public.coupon_usage 
  FOR UPDATE TO authenticated 
  USING (public.has_role(auth.uid(), 'admin'));
