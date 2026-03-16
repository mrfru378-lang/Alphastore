# Browser Notifications Setup for Alpha Store

This document explains the notification system that has been implemented for the Alpha Store PWA.

## Overview

The application now supports:
- **Push notifications** for orders and messages
- **Service Worker** for background notifications
- **PWA support** for home screen installation
- **Real-time notifications** when messages or orders arrive

## What Was Added

### 1. Service Worker (`public/sw.js`)
- Handles push notifications in the background
- Manages notification clicks and interactions
- Supports offline functionality with caching

### 2. Notification Library (`src/lib/notifications.ts`)
- Core notification functions
- Service worker registration
- Permission management
- Order and message notification helpers

### 3. Notifications Hook (`src/hooks/useNotifications.tsx`)
- React hook for managing notifications in components
- Provides permission status and request functionality
- Easy integration with React components

### 4. Web Manifest (`public/manifest.json`)
- PWA configuration for home screen installation
- App icons, colors, and shortcuts
- Desktop app experience

### 5. Updated Components
- **main.tsx** - Auto-registers service worker on app load
- **index.html** - Added PWA meta tags
- **Admin.tsx** - Notifications for new orders
- **LiveChat.tsx** - Notifications for admin messages
- **AdminChat.tsx** - Notifications for user messages

## How It Works

### Order Notifications
When a new order arrives in the admin dashboard:
```
1. Order is received via Supabase real-time subscription
2. System detects it's a new pending order
3. Browser notification is shown with:
   - Order product name
   - Amount (৳)
   - Link to admin dashboard
```

### Message Notifications
When a new message arrives:
```
1. Chat subscription detects new message
2. System checks if it's from admin (for users) or user (for admins)
3. Browser notification is shown with:
   - Sender name
   - Message preview (first 100 chars)
   - Sound and vibration
```

## Installation & Use

### For End Users

#### Option 1: Add to Home Screen (Android)
1. Open the website in Chrome
2. Tap the menu (⋮) → "Install app"
3. Tap "Install"
4. The app is now on your home screen
5. Grant notification permission when prompted

#### Option 2: Add to Home Screen (iOS/Safari)
1. Open the website in Safari
2. Tap the Share button
3. Tap "Add to Home Screen"
4. Grant notification permission when prompted

#### Option 3: Desktop (Chrome/Edge)
1. Visit the website
2. Click the "Install" button (appears in address bar)
3. Grant notification permission when prompted

### For Developers

#### Using Notifications in Code

```typescript
// Import the notification functions
import { notifyNewOrder, notifyNewMessage } from '@/lib/notifications';

// Notify about a new order
notifyNewOrder({
  orderId: '123',
  productName: 'PUBG UC 500',
  amount: 5000,
  status: 'Pending',
});

// Notify about a new message
notifyNewMessage({
  userId: 'user123',
  userName: 'John Doe',
  message: 'Hello, is this product still available?',
  isAdmin: false,
});
```

#### Using the Hook

```typescript
import { useNotifications } from '@/hooks/useNotifications';

export function MyComponent() {
  const { isGranted, requestPermission, notify } = useNotifications();

  const handleNotify = async () => {
    if (!isGranted) {
      const granted = await requestPermission();
      if (!granted) return;
    }

    notify({
      title: 'Custom Notification',
      message: 'This is a custom notification',
      type: 'general',
    });
  };

  return (
    <button onClick={handleNotify}>
      Send Notification
    </button>
  );
}
```

## Notification Types

### Order Notifications
- **Title**: 🛒 New Order!
- **Body**: Product name and amount
- **Action**: Click redirects to admin orders
- **Interaction Required**: Yes (stays on screen until dismissed)

### Message Notifications
- **Title**: 💬 New Message from [Sender]
- **Body**: Message preview
- **Action**: Click redirects to chat
- **Interaction Required**: No (auto-closes after 10s)

## Browser Compatibility

| Browser | Desktop | Mobile |
|---------|---------|--------|
| Chrome | ✅ Full | ✅ Full |
| Edge | ✅ Full | ✅ Full |
| Firefox | ✅ Full | ✅ Full |
| Safari | ⚠️ Limited | ⚠️ Limited* |

*Safari on iOS has limited notification support (in-app only)

## Technical Details

### Service Worker Registration
- Registered automatically on app load
- Scope: `/` (full app)
- Updates checked every 60 seconds

### Notification Permissions
- `default` - Not yet requested
- `granted` - User allowed notifications
- `denied` - User declined notifications

### Real-time Updates
- Uses Supabase PostgreSQL subscriptions
- Detects new rows in `orders` and `chat_messages` tables
- Instantaneous notification delivery

## Customization

### Change Notification Sound
Edit `public/sw.js` and modify the notification options:
```javascript
const options = {
  // ... other options
  tag: 'order-notification', // Group similar notifications
  vibrate: [200, 100, 200],   // Custom vibration pattern
};
```

### Change App Icon
Replace `/public/logo.png` with your custom icon and update `manifest.json`

### Change Theme Color
Edit the `theme_color` in `public/manifest.json`:
```json
{
  "theme_color": "#e41d60"
}
```

## Testing

### Test in Development
1. Run the dev server: `npm run dev`
2. Open in Chrome/Chromium
3. Grant notification permission when prompted
4. Manually insert test data in Supabase to trigger notifications

### Test PWA Features
1. Open DevTools (F12)
2. Go to Application → Manifest
3. Click "Add to shelf" (desktop) or use mobile menu

## Troubleshooting

### Notifications Not Showing
- Check permission status: `Notification.permission`
- Ensure service worker registered: DevTools → Application → Service Workers
- Check browser notification settings (OS level)

### Service Worker Not Updating
- Hard refresh: Ctrl+Shift+R (Windows) / Cmd+Shift+R (Mac)
- Clear site data in DevTools → Application → Storage
- Wait for 60-second update interval

### PWA Not Installing
- Must be served over HTTPS (or localhost for testing)
- Manifest must be valid JSON
- Service worker must be registered successfully

## Files Modified/Created

- ✅ `/public/sw.js` - Service Worker
- ✅ `/public/manifest.json` - PWA Manifest
- ✅ `/src/lib/notifications.ts` - Notification Library
- ✅ `/src/hooks/useNotifications.tsx` - Notifications Hook
- ✅ `/src/main.tsx` - Service Worker Registration
- ✅ `/index.html` - PWA Meta Tags
- ✅ `/src/pages/Admin.tsx` - Order Notifications
- ✅ `/src/components/LiveChat.tsx` - Message Notifications (User)
- ✅ `/src/components/admin/AdminChat.tsx` - Message Notifications (Admin)

## Support

For issues or questions about the notification system, check:
1. Browser DevTools console for errors
2. Application tab → Service Workers status
3. Notification permission settings
4. Server logs for real-time subscription issues
