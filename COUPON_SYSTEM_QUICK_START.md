# Coupon System - Quick Reference

## 🚀 Quick Start (5 minutes)

### 1. Run Migration
```bash
# In your project directory
supabase db push
```

### 2. Access Admin Dashboard
- Go to `/admin` → Click "Coupons" in sidebar
- You'll see three options: "Active Coupons", "Add Coupon", "Analytics"

### 3. Create Your First Coupon
- Click "Add Coupon"
- Follow the 6-step wizard:
  1. Enter code (e.g., "FIRST20")
  2. Select category (Games or OTT & Services) and product
  3. Set discount % (e.g., 20)
  4. Set usage limit (e.g., 100)
  5. Pick expiry date
  6. Confirm

---

## 📋 Integration Example

### Add to Product Purchase Button
```tsx
import { useState } from 'react';
import CouponModal from '@/components/CouponModal';

export function ProductCard({ product }) {
  const [showCoupon, setShowCoupon] = useState(false);
  const [discount, setDiscount] = useState(0);

  return (
    <div>
      <p>Price: ৳{(product.price - discount).toFixed(2)}</p>
      
      <button onClick={() => setShowCoupon(true)}>
        🎟️ Apply Coupon
      </button>

      <CouponModal
        open={showCoupon}
        onOpenChange={setShowCoupon}
        productId={product.id}
        productPrice={product.price}
        onCouponApplied={(discountAmount) => {
          setDiscount(discountAmount);
        }}
      />
    </div>
  );
}
```

---

## 🎯 Key Features at a Glance

| Feature | Admin | User |
|---------|-------|------|
| Create Coupons | ✅ 6-step wizard | - |
| Apply Coupons | - | ✅ Modal dialog |
| View Analytics | ✅ Dashboard | - |
| Manage Status | ✅ Activate/Deactivate | - |
| Track Usage | ✅ Yes | ✅ Shows discount |
| Set Limits | ✅ Yes | ✅ Enforced |
| Track Expiry | ✅ Yes | ✅ Enforced |

---

## 🔍 Validation Rules (What Works)

✅ Coupon code exists in database
✅ Coupon status is "active"
✅ Code matches exactly (CASE SENSITIVE)
✅ Coupon is for THIS specific product
✅ Used count < Usage limit
✅ Current date < Expiry date

❌ Invalid code - Shows "Invalid Coupon Code"
❌ Wrong product - Shows "Coupon not valid for this product"
❌ Expired - Shows "This coupon has expired"
❌ Limit reached - Shows "Coupon usage limit reached"
❌ Inactive - Shows "This coupon is no longer active"

---

## 📊 Admin Sections Explained

### 1️⃣ Active Coupons
- See all coupons at a glance
- Cards show: Code, Product, Category, Discount, Usage, Expiry, Status
- Actions: Deactivate/Activate buttons
- Color-coded status (green = active, gray = inactive)

### 2️⃣ Add Coupon (Multi-Step)
**Step 1**: Coupon code (text input)
**Step 2**: Category selection → Product selection from list
**Step 3**: Discount % (1-100) with price preview
**Step 4**: Usage limit (how many times can be used)
**Step 5**: Expiry date (date picker)
**Step 6**: Summary review + Confirm button

Each step has **Back** and **Next** buttons.

### 3️⃣ Analytics Dashboard
Shows 6 KPI Cards:
- 📊 Total Coupons Created
- 🟢 Active Coupons
- ⚫ Inactive Coupons
- 📈 Total Uses (with average)
- 💰 Total Discount Given (estimated)
- 🌟 Most Used Coupon

Plus:
- Detailed usage breakdown table
- Active vs Inactive status chart
- Category-wise performance

---

## 🗂️ Database Quick Reference

### Create Coupon
```typescript
import { createCoupon } from '@/lib/coupon-service';

await createCoupon({
  coupon_code: 'SUMMER20',
  product_id: 'uc-60',
  product_name: '60 UC',
  category: 'Games',
  discount_percent: 20,
  usage_limit: 100,
  expiry_date: '2026-12-31T23:59:59Z'
});
```

### Validate & Apply Coupon
```typescript
import { validateCoupon, useCoupon, getCouponByCode } from '@/lib/coupon-service';

// Validate first
const validation = await validateCoupon('SUMMER20', 'uc-60');
if (validation.valid) {
  // Apply
  const coupon = await getCouponByCode('SUMMER20');
  await useCoupon(coupon.id, userId, orderId);
}
```

### Get Analytics
```typescript
import { getCouponAnalytics } from '@/lib/coupon-service';

const analytics = await getCouponAnalytics();
console.log(analytics.total_coupons); // Total created
console.log(analytics.total_uses); // Total applied
console.log(analytics.most_used_coupon); // Top coupon
```

---

## 🧪 Testing Scenarios

### Test 1: Create & Apply Valid Coupon
✅ Create coupon "TEST20" for product "uc-60" with 20% discount
✅ Apply it on uc-60 product → Should show "Coupon Applied!"
✅ Check used_count increased by 1

### Test 2: Product Restriction
✅ Create coupon "GAME10" for "pubg" product
✅ Try applying on "netflix" product → Should fail
✅ Should show "This coupon is not valid for this product"

### Test 3: Expiry Date
✅ Create coupon with yesterday's expiry date
✅ Try to apply → Should fail
✅ Should show "This coupon has expired"

### Test 4: Usage Limit
✅ Create coupon with limit "1"
✅ Apply once → Success
✅ Try again → Should show "Coupon usage limit reached"

### Test 5: Case Sensitivity
✅ Create coupon "SUMMER20"
✅ Try apply with "summer20" → Should fail
✅ Try apply with "SUMMER20" → Should work

---

## 🚨 Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Coupon not appearing | Migration didn't run | Run `supabase db push` |
| Validation always fails | Wrong product_id | Check product ID matches exact value |
| "Invalid Coupon Code" | Coupon doesn't exist | Create coupon first in admin |
| "Not valid for product" | Applied on wrong product | Use on the correct product |
| Used count not updating | useCoupon() not called | Call after validation passes |
| Analytics shows 0 | No coupons used yet | Apply coupons to update counts |

---

## 💡 Pro Tips

1. **Naming Convention**: Use descriptive codes
   - ✅ "SUMMER20", "NEWYEAR10", "VIP30"
   - ❌ "ABC123", "TEST", "111"

2. **Test Before Launch**: Create test coupons first
   - Set short expiry dates for testing
   - Use low usage limits

3. **Monitor Analytics**: Check dashboard regularly
   - Watch for unused coupons
   - Deactivate expired ones
   - See which coupons are most popular

4. **Seasonal Campaigns**: Create coupons for events
   - Holiday discounts
   - Birthday month special
   - Referral bonuses

5. **Gradual Rollout**: Start with limited coupons
   - Create a few initially
   - Monitor usage patterns
   - Expand based on data

---

## 📱 Component Props Reference

### CouponModal
```tsx
<CouponModal
  open={boolean}                    // Dialog visibility
  onOpenChange={(open) => {}}       // Close handler
  productId={string}                // Required: Product to validate for
  productPrice={number}             // Required: For discount preview
  onCouponApplied={(discount, code) => {}}  // Success callback
/>
```

---

## 🔐 Security Notes

✅ Codes are case-sensitive (prevents easy guessing)
✅ Product-specific (prevents cross-product abuse)  
✅ Usage limits prevent excessive discounts
✅ Expiry dates auto-disable old coupons
✅ Admin-only creation prevents unauthorized coupons
✅ Real-time validation prevents cheating
✅ Complete audit in coupon_usage table

---

## 📞 Need Help?

See full documentation:
- `COUPON_SYSTEM_IMPLEMENTATION.md` - Complete guide, troubleshooting, future features
- `COUPON_SYSTEM_FILES.md` - List of all created/modified files

Files created:
1. `supabase/migrations/20260315000000_create_coupons_table.sql`
2. `src/lib/coupon-service.ts`
3. `src/components/admin/AdminActiveCoupons.tsx`
4. `src/components/admin/AdminAddCoupon.tsx`
5. `src/components/admin/AdminCouponAnalytics.tsx`
6. `src/components/CouponModal.tsx`

File modified:
1. `src/pages/Admin.tsx`

