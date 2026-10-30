// Cambie la versión cada vez que publique cambios: así cada equipo descarga la copia nueva completa.
const CACHE = 'conversor-v3';
const BASE = ['./', './index.html', './manifest.webmanifest', './icon.svg', './icon-192.png', './icon-512.png', './icon-maskable-512.png',
  './fonts/atkinson-hyperlegible-latin-400-normal.woff2', './fonts/atkinson-hyperlegible-latin-700-normal.woff2',
  './fonts/atkinson-hyperlegible-latin-400-italic.woff2', './fonts/ibm-plex-mono-latin-500-normal.woff2', './fonts/ibm-plex-mono-latin-600-normal.woff2'];

self.addEventListener('install', e => {
  // cache: 'reload' evita guardar una copia vieja de la caché HTTP del navegador
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(BASE.map(u => new Request(u, { cache: 'reload' })))).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys()
    .then(ks => Promise.all(ks.filter(k => k.startsWith('conversor-') && k !== CACHE).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== location.origin) return;
  const guardar = (clave, res) => res && res.ok
    ? caches.open(CACHE).then(c => c.put(clave, res.clone())).then(() => res, () => res)
    : res;
  if (req.mode === 'navigate') {
    // Primero la copia guardada (abre al instante, con o sin señal); en segundo plano se actualiza para la próxima vez
    const limpia = new URL(req.url); limpia.search = ''; limpia.hash = '';
    const red = fetch(req).then(res => guardar(limpia.href, res));
    e.waitUntil(red.then(() => {}, () => {}));
    e.respondWith(caches.match(limpia.href)
      .then(hit => hit || caches.match('./index.html'))
      .then(hit => hit || red));
    return;
  }
  e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(res => guardar(req, res))));
});
