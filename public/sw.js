// Service Worker for Alpha Store - Handles push notifications

const CACHE_NAME = 'alpha-store-v1';
const urlsToCache = [
  '/',
  '/index.html',
];

// Install event
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(urlsToCache).catch(() => {
        // Ignore cache errors during installation
      });
    })
  );
  self.skipWaiting();
});

// Activate event
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Push notification event
self.addEventListener('push', event => {
  if (!event.data) return;

  let data = {};
  try {
    data = event.data.json();
  } catch {
    data = {
      title: 'Alpha Store',
      message: event.data.text(),
    };
  }

  const title = data.title || 'Alpha Store Notification';
  const options = {
    body: data.message || data.body || 'You have a new notification',
    icon: '/logo.png',
    badge: '/logo.png',
    tag: data.tag || 'alpha-notification',
    requireInteraction: data.requireInteraction || true,
    vibrate: [200, 100, 200],
    data: {
      url: data.url || '/',
      type: data.type || 'notification',
    },
  };

  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});

// Notification click event
self.addEventListener('notificationclick', event => {
  event.notification.close();

  const urlToOpen = event.notification.data?.url || '/';

  event.waitUntil(
    clients.matchAll({
      type: 'window',
      includeUncontrolled: true,
    }).then(clientList => {
      // Check if the app is already open
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i];
        if (client.url === urlToOpen && 'focus' in client) {
          return client.focus();
        }
      }
      // If not open, open a new window
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );
});

// Background sync for offline support
self.addEventListener('sync', event => {
  if (event.tag === 'sync-notifications') {
    event.waitUntil(
      // Handle sync logic if needed
      Promise.resolve()
    );
  }
});
