/* global firebase, JARZ_FIREBASE_WEB_CONFIG */

const scopeUrl = new URL(self.registration.scope);
let appBasePath = scopeUrl.pathname.endsWith('/')
  ? scopeUrl.pathname
  : `${scopeUrl.pathname}/`;
// The VAPID subscription registers this worker at a dedicated `<base>/push/`
// sub-scope so it never collides with Flutter's root service worker. The app
// assets (icons) and the in-app deep-link URL live one level up, at <base>/, so
// strip the push sub-scope suffix when resolving the app base path.
if (appBasePath.endsWith('/push/')) {
  appBasePath = appBasePath.slice(0, -'push/'.length);
}

// One definition of the tag and the click target for BOTH handlers below (the
// FCM onBackgroundMessage path and the standard VAPID push path), because they
// must agree: a tag REPLACES the notification already on screen, so if the two
// handlers disagree a browser served by both shows one entry or two depending
// on which fired.
//
// The tag must be per-EVENT, not per-type. It used to fall back to data.type
// when there was no invoice_id, which is identical for every expense approval:
// the second pending request silently replaced the first in the tray, and a
// manager answered one of two. notification_id is set by every payload builder
// and equals invoice_id on the invoice paths, so this changes nothing there.
function notificationTagFor(data) {
  return data.invoice_id || data.notification_id || data.type || 'jarz_pos';
}

// A "?notification=<id>" URL means "an INVOICE is waiting" -- the app hands that id
// straight to the POS order-alert path. Sending an expense name through it
// dropped the manager on the till with a JEXP- id masquerading as an invoice,
// so only invoice types may use it.
//
// Approvals deep-link to the expenses screen through the fragment: this app
// does not install Flutter's path URL strategy, so its routes live after a
// '#', and '<base>expenses' would be a 404 on the server.
function notificationUrlFor(data) {
  if (data.type === 'expense_approval_required') {
    return `${appBasePath}#/expenses`;
  }
  const invoiceId = data.invoice_id || '';
  return invoiceId
    ? `${appBasePath}?notification=${encodeURIComponent(invoiceId)}`
    : appBasePath;
}

try {
  importScripts('firebase-web-config.js');
} catch (error) {
  // The app can deploy this worker before Firebase web push is configured.
}

if (typeof JARZ_FIREBASE_WEB_CONFIG !== 'undefined') {
  // The Firebase compat SDK powers the FCM onBackgroundMessage path (Android /
  // desktop Chrome). It is wrapped in try/catch because some firebase-*-compat
  // builds reference `window` at evaluation time and throw in a ServiceWorker
  // (`ReferenceError: window is not defined`). An unhandled throw here would
  // abort the ENTIRE worker script and take down the standard VAPID `push`
  // handler below — which is the ONLY path iOS Safari PWA uses and does not need
  // Firebase at all. Swallowing the failure keeps the push handler alive.
  try {
    // Scripts are bundled locally during build_release.sh to avoid CDN dependency
    // at service worker activation time (critical for iOS PWA offline/poor-network scenarios).
    importScripts('./firebase-app-compat.js');
    importScripts('./firebase-messaging-compat.js');

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
      const invoiceId = data.invoice_id || '';
      const type = data.type || 'pos_update';

      self.registration.showNotification(title, {
        body,
        icon: `${appBasePath}icons/Icon-192.png`,
        badge: `${appBasePath}icons/Icon-192.png`,
        tag: notificationTagFor(data),
        data: { ...data, url: notificationUrlFor(data) },
        requireInteraction: type === 'new_invoice',
      });
    });
  } catch (error) {
    // FCM background messaging unavailable in this worker context. The standard
    // VAPID `push` handler below still delivers notifications on all browsers,
    // including iOS Safari PWA.
  }
}

// Standard VAPID Web Push — fires for pushManager.subscribe() subscriptions.
// Handles all browsers including iOS Safari PWA where FCM onBackgroundMessage
// does not fire. Both handlers use the same tag so concurrent pushes deduplicate.
self.addEventListener('push', (event) => {
  if (!event.data) return;

  let data = {};
  try { data = event.data.json(); } catch (_) { return; }

  const title = data.title || 'Jarz POS';
  const body = data.body || 'New order received';
  const notifUrl = notificationUrlFor(data);

  event.waitUntil(
    self.registration.showNotification(title, {
      body,
      icon: `${appBasePath}icons/Icon-192.png`,
      badge: `${appBasePath}icons/Icon-192.png`,
      tag: notificationTagFor(data),
      requireInteraction: data.type === 'new_invoice',
      data: { ...data, url: notifUrl },
    })
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const targetUrl = event.notification?.data?.url || appBasePath;

  event.waitUntil((async () => {
    const windows = await clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const client of windows) {
      if ('focus' in client) {
        if ('postMessage' in client) {
          client.postMessage({ type: 'jarz_pos_notification_click', url: targetUrl });
        }
        await client.focus();
        return;
      }
    }

    if (clients.openWindow) {
      await clients.openWindow(targetUrl);
    }
  })());
});