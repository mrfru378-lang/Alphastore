
-- Alpha Points balance table
CREATE TABLE public.alpha_points (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  balance integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Alpha Points transaction history
CREATE TABLE public.alpha_points_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  amount integer NOT NULL,
  type text NOT NULL CHECK (type IN ('topup', 'purchase', 'refund', 'admin_add')),
  description text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.alpha_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alpha_points_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies for alpha_points
CREATE POLICY "Users can view own points" ON public.alpha_points FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Admins can view all points" ON public.alpha_points FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can update points" ON public.alpha_points FOR UPDATE TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert points" ON public.alpha_points FOR INSERT TO authenticated WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Users can insert own points" ON public.alpha_points FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- RLS Policies for alpha_points_history
CREATE POLICY "Users can view own history" ON public.alpha_points_history FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Admins can view all history" ON public.alpha_points_history FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Users can insert own history" ON public.alpha_points_history FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can insert history" ON public.alpha_points_history FOR INSERT TO authenticated WITH CHECK (public.has_role(auth.uid(), 'admin'));

-- Updated_at trigger
CREATE TRIGGER update_alpha_points_updated_at BEFORE UPDATE ON public.alpha_points
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Auto-create points record for new users
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  INSERT INTO public.profiles (user_id, name, email, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', ''),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  );
  INSERT INTO public.alpha_points (user_id, balance)
  VALUES (NEW.id, 0);
  RETURN NEW;
END;
$function$;

-- Enable realtime for points
ALTER PUBLICATION supabase_realtime ADD TABLE public.alpha_points;
