// Smart Somiti Service Worker - PWA Offline Caching Engine v2.8.18
const CACHE_NAME = 'smart-somiti-cache-v2.8.18';
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/verify.html',
  '/logo.webp',
  '/logo.jpg',
  '/swapno_chowa_logo.webp',
  '/swapno_chowa_logo.jpg',
  '/smart_somiti_logo.webp',
  '/smart_somiti_logo.jpg',
  '/pad_header.webp',
  '/pad_header.jpg',
  '/manifest.json',
  '/version.json'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS).catch((err) => {
        console.warn('[SW] Pre-caching non-fatal issue:', err);
      });
    }).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) {
            return caches.delete(key);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  // Bypass Firestore, Auth, Storage, Google APIs to prevent stale auth state
  if (
    url.hostname.includes('firestore.googleapis.com') ||
    url.hostname.includes('firebaseio.com') ||
    url.hostname.includes('googleapis.com') ||
    url.hostname.includes('identitytoolkit.googleapis.com')
  ) {
    return;
  }

  // Cache-First strategy for images to eliminate redundant mobile data downloads
  const isImage = /\.(webp|jpg|jpeg|png|ico|svg)$/i.test(url.pathname);
  if (isImage) {
    event.respondWith(
      caches.match(req).then((cached) => {
        if (cached) return cached;
        return fetch(req).then((res) => {
          if (res && res.status === 200) {
            const clone = res.clone();
            caches.open(CACHE_NAME).then(c => c.put(req, clone));
          }
          return res;
        });
      })
    );
    return;
  }

  // Network-First with Cache fallback strategy for local static assets
  event.respondWith(
    fetch(req)
      .then((networkResponse) => {
        if (networkResponse && networkResponse.status === 200) {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(req, responseToCache);
          });
        }
        return networkResponse;
      })
      .catch(() => {
        return caches.match(req).then((cachedResponse) => {
          if (cachedResponse) {
            return cachedResponse;
          }
          if (req.mode === 'navigate') {
            return caches.match('/index.html');
          }
          return new Response('Offline resource not available', { status: 503, statusText: 'Offline' });
        });
      })
  );
});
