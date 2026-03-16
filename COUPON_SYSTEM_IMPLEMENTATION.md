# Coupon System Implementation Guide

## Overview
A complete coupon/voucher system has been integrated into your e-commerce website. This system supports both Games and OTT & Services product categories with comprehensive admin controls and analytics.

---

## Files Created

### 1. **Database Migration**
- **File**: `supabase/migrations/20260315000000_create_coupons_table.sql`
- **Purpose**: Creates `coupons` and `coupon_usage` tables in Supabase
- **Action Required**: Run this migration in Supabase CLI or dashboard

### 2. **Coupon Service Library**
- **File**: `src/lib/coupon-service.ts`
- **Purpose**: Core service for all coupon operations (CRUD, validation, analytics)
- **Key Functions**:
  - `createCoupon()` - Create new coupons
  - `validateCoupon()` - Validate coupon on checkout
  - `useCoupon()` - Track coupon usage
  - `getCouponAnalytics()` - Get analytics data
  - `deactivateCoupon()` / `activateCoupon()` - Toggle coupon status

### 3. **Admin Components**

#### a. AdminActiveCoupons.tsx
- **File**: `src/components/admin/AdminActiveCoupons.tsx`
- **Purpose**: Display all coupons with status, usage, and expiry info
- **Features**:
  - List all coupons
  - Activate/Deactivate coupons
  - View usage statistics
  - See expiry dates

#### b. AdminAddCoupon.tsx
- **File**: `src/components/admin/AdminAddCoupon.tsx`
- **Purpose**: Multi-step modal for creating coupons
- **Steps**:
  1. Enter Coupon Code
  2. Select Product Category & Product
  3. Set Discount Percentage
  4. Set Usage Limit
  5. Select Expiry Date
  6. Confirm Coupon
- **Features**:
  - Back button on each step
  - Real-time discount calculation preview
  - Validation at each step
  - Confirmation summary

#### c. AdminCouponAnalytics.tsx
- **File**: `src/components/admin/AdminCouponAnalytics.tsx`
- **Purpose**: Dashboard with coupon analytics and metrics
- **Metrics Displayed**:
  - Total coupons created
  - Active vs Inactive count
  - Total coupon uses
  - Most used coupon
  - Estimated total discount given
  - Usage breakdown table
  - Status summary charts

### 4. **User-Facing Coupon Modal**
- **File**: `src/components/CouponModal.tsx`
- **Purpose**: Modal for users to apply coupon codes during checkout
- **Features**:
  - Enter coupon code
  - Real-time validation
  - Shows discount amount & new price
  - Case-sensitive code entry
  - Error messages for invalid codes

---

## Files Updated

### 1. **Admin Dashboard** (Main Admin Page)
- **File**: `src/pages/Admin.tsx`
- **Changes**:
  - Added `Gift` icon import from lucide-react
  - Added `'coupons'` to Tab type
  - Added `CouponSubPage` type for sub-navigation
  - Added coupon state variables:
    - `couponSubPage` - Track current coupon view (active/add/analytics)
    - `showAddCoupon` - Control Add Coupon modal
  - Added "Coupons" item to sidebar with Gift icon
  - Added Coupons tab content with sub-navigation
  - Integrated all three coupon admin components

---

## Integration Steps

### Step 1: Run Database Migration
```bash
# Using Supabase CLI
supabase db push

# Or manually in Supabase dashboard:
# 1. Go to SQL Editor
# 2. Paste the migration SQL
# 3. Run the migration
```

### Step 2: Test in Admin Dashboard
1. Navigate to Admin Dashboard
2. Click "Coupons" in the sidebar
3. Use "Add Coupon" to create test coupons
4. View in "Active Coupons"
5. Check analytics in "Analytics" tab

### Step 3: Integrate in Product Purchase Pages
Add CouponModal to any purchase flow:

```tsx
import CouponModal from '@/components/CouponModal';

// In your component:
const [showCoupon, setShowCoupon] = useState(false);
const [appliedDiscount, setAppliedDiscount] = useState(0);
const [finalPrice, setFinalPrice] = useState(productPrice);

const handleCouponApplied = (discount: number, code: string) => {
  setAppliedDiscount(discount);
  setFinalPrice(productPrice - discount);
  // Store couponCode for order creation
};

// In your JSX:
<Button onClick={() => setShowCoupon(true)}>
  Apply Coupon Code
</Button>

<CouponModal
  open={showCoupon}
  onOpenChange={setShowCoupon}
  productId={productId}
  productPrice={productPrice}
  onCouponApplied={handleCouponApplied}
/>

// Show final price
<p>Final Price: ৳{finalPrice.toFixed(2)}</p>
```

---

## Coupon System Features

### Admin Features
✅ Create coupons with multi-step wizard
✅ Case-sensitive coupon codes
✅ Product-specific discounts (only work on assigned product)
✅ Percentage-based discounts (1-100%)
✅ Usage limits and tracking
✅ Expiry date management
✅ Activate/Deactivate coupons
✅ Comprehensive analytics dashboard
✅ Usage tracking and history

### User Features
✅ Apply coupon codes at checkout
✅ Real-time validation
✅ See discount amount before purchase
✅ Clear error messages
✅ Case-sensitive code entry
✅ Prevents usage after expiry date
✅ Prevents usage beyond limit

### Validation Rules
The system validates:
1. ✅ Coupon code exists
2. ✅ Coupon is active
3. ✅ Code matches exactly (case-sensitive)
4. ✅ Coupon is for this specific product
5. ✅ Usage limit not exceeded
6. ✅ Coupon hasn't expired

---

## Database Schema

### Coupons Table
```sql
- id (UUID, PRIMARY KEY)
- coupon_code (VARCHAR 50, UNIQUE)
- product_id (VARCHAR 100)
- product_name (VARCHAR 255)
- category (VARCHAR 50) - 'Games' or 'OTT & Services'
- discount_percent (DECIMAL 5,2) - 1-100%
- usage_limit (INTEGER)
- used_count (INTEGER)
- expiry_date (TIMESTAMP)
- status (VARCHAR 20) - 'active' or 'inactive'
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### Coupon Usage Table
```sql
- id (UUID, PRIMARY KEY)
- coupon_id (UUID, FOREIGN KEY)
- user_id (UUID, OPTIONAL)
- used_at (TIMESTAMP)
- order_id (VARCHAR 100, OPTIONAL)
```

---

## API Endpoints (Service Functions)

### Create Coupon
```ts
createCoupon(data: CreateCouponData)
```

### Get All Coupons
```ts
getAllCoupons()
```

### Get Coupons by Status
```ts
getCouponsByStatus(status: 'active' | 'inactive')
```

### Validate Coupon
```ts
validateCoupon(couponCode: string, productId: string)
```

### Use Coupon (Update Usage)
```ts
useCoupon(couponId: string, userId?: string, orderId?: string)
```

### Deactivate/Activate
```ts
deactivateCoupon(couponId: string)
activateCoupon(couponId: string)
```

### Get Analytics
```ts
getCouponAnalytics()
```

---

## Testing Checklist

- [ ] Run database migration successfully
- [ ] Navigate to Admin > Coupons
- [ ] Create a test coupon using "Add Coupon"
- [ ] Verify coupon appears in "Active Coupons"
- [ ] Check analytics dashboard shows the new coupon
- [ ] Deactivate a coupon and verify status changes
- [ ] Create another active coupon
- [ ] Test applying coupon on product page
- [ ] Verify used count increases after applying
- [ ] Test with expired coupon date (should fail validation)
- [ ] Test with different product ID (should fail validation)
- [ ] Test case sensitivity of coupon code
- [ ] Verify discount calculation is correct
- [ ] Test usage limit enforcement
- [ ] Check all error messages display correctly

---

## Key Security Features

✅ Case-sensitive coupon codes prevent guessing
✅ Product-specific restrictions prevent abuse
✅ Usage limits cap potential losses
✅ Expiry dates auto-disable old coupons
✅ Admin-only creation and management
✅ Real-time validation on checkout
✅ Complete audit trail in coupon_usage table

---

## Notes for Implementation

1. **OTT Products**: The system includes mock OTT products. Update `AdminAddCoupon.tsx` with real product data from your Supabase if needed.

2. **Product Linking**: Ensure product IDs in the coupon system match your actual product database.

3. **Discount Calculation**: Currently percentage-based. To add flat amount discounts, modify `validateCoupon()` response type.

4. **Analytics Revenue**: The "Total Discount Given" is an estimate. For accurate values, calculate using actual product prices.

5. **Email Notifications**: Consider adding email notifications when coupons are about to expire.

---

## Troubleshooting

### Migration Fails
- Ensure Supabase project is connected
- Check table doesn't already exist
- Verify SQL syntax is correct

### Coupon Not Working
- Check product_id matches exactly
- Verify coupon status is 'active'
- Ensure expiry date hasn't passed
- Confirm usage limit not reached

### Analytics Shows 0
- Create test coupons first
- Ensure coupons have been used at least once
- Check database connection

---

## Future Enhancements

- [ ] Flat-amount discounts (not just percentage)
- [ ] Coupon usage restrictions by user/email
- [ ] Bulk coupon code generation
- [ ] Referral coupon system
- [ ] Seasonal coupon templates
- [ ] Email notifications on coupon expiry
- [ ] Export analytics to CSV
- [ ] A/B testing different discount rates
- [ ] Auto-apply best coupon for users
- [ ] Social sharing bonuses

