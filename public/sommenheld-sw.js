/* Service worker voor Sommenheld: laat de app ook zonder internet werken.
   - De app zelf (HTML): eerst het netwerk proberen, zodat updates meteen binnenkomen; zonder netwerk de bewaarde versie.
   - Iconen en manifest: uit de cache.
   - Google Fonts: uit de cache, op de achtergrond bijgewerkt.
   Verhoog VERSION bij een wijziging in dit bestand of in de lijst met vaste bestanden. */
const VERSION = 'sommenheld-v1';
const SHELL = [
  '/sommenheld.html',
  '/sommenheld.webmanifest',
  '/icons/sommenheld-192.png',
  '/icons/sommenheld-512.png',
  '/icons/sommenheld-maskable-512.png',
  '/icons/sommenheld-180.png',
  '/icons/sommenheld-64.png'
];
const FONTS = 'sommenheld-fonts';

self.addEventListener('install', event => {
  event.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== VERSION && k !== FONTS).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

async function networkFirst(request) {
  const cache = await caches.open(VERSION);
  try {
    const fresh = await fetch(request);
    if (fresh && fresh.ok) cache.put('/sommenheld.html', fresh.clone());
    return fresh;
  } catch (e) {
    return (await cache.match('/sommenheld.html')) || Response.error();
  }
}

async function cacheFirst(request) {
  const hit = await caches.match(request);
  if (hit) return hit;
  const res = await fetch(request);
  if (res && res.ok) (await caches.open(VERSION)).put(request, res.clone());
  return res;
}

async function staleWhileRevalidate(request) {
  const cache = await caches.open(FONTS);
  const hit = await cache.match(request);
  const update = fetch(request).then(res => {
    if (res && (res.ok || res.type === 'opaque')) cache.put(request, res.clone());
    return res;
  }).catch(() => hit);
  return hit || update;
}

self.addEventListener('fetch', event => {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);

  if (url.origin === 'https://fonts.googleapis.com' || url.origin === 'https://fonts.gstatic.com') {
    event.respondWith(staleWhileRevalidate(req));
    return;
  }
  if (url.origin !== self.location.origin) return;

  if (req.mode === 'navigate' || url.pathname === '/sommenheld.html' || url.pathname === '/sommenheld') {
    event.respondWith(networkFirst(req));
    return;
  }
  if (SHELL.includes(url.pathname)) event.respondWith(cacheFirst(req));
});
