/* global firebase, JARZ_FIREBASE_WEB_CONFIG */

try {
  importScripts('/firebase-web-config.js');
} catch (error) {
  // The app can deploy this worker before Firebase web push is configured.
}

if (typeof JARZ_FIREBASE_WEB_CONFIG !== 'undefined') {
  importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js');
  importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js');

  firebase.initializeApp(JARZ_FIREBASE_WEB_CONFIG);

  const messaging = firebase.messaging();

  messaging.onBackgroundMessage((payload) => {
    const data = payload.data || {};
    const notification = payload.notification || {};
    const hasBrowserManagedNotification = Boolean(notification.title || notification.body);

    if (hasBrowserManagedNotification) {
      return;
    }

    const title = data.title || notification.title || 'Jarz POS';
    const body = data.body || notification.body || 'New POS update';
    const invoiceId = data.invoice_id || data.notification_id || '';
    const type = data.type || 'pos_update';

    self.registration.showNotification(title, {
      body,
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
      tag: invoiceId || type,
      data: {
        ...data,
        url: invoiceId ? `/?notification=${encodeURIComponent(invoiceId)}` : '/',
      },
      requireInteraction: type === 'new_invoice',
    });
  });
}

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const targetUrl = event.notification?.data?.url || '/';

  event.waitUntil((async () => {
    const windows = await clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const client of windows) {
      if ('focus' in client) {
        await client.focus();
        client.postMessage({ type: 'jarz_pos_notification_click', url: targetUrl });
        return;
      }
    }

    if (clients.openWindow) {
      await clients.openWindow(targetUrl);
    }
  })());
});