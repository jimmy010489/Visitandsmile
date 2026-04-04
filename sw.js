// ===== VISIT & SMILE — Service Worker (PWA) =====
const CACHE_NAME = 'visitandsmile-v1';
const ASSETS = [
    '/',
    '/index.html',
    '/css/style.css',
    '/js/config.js',
    '/js/supabase.js',
    '/js/app.js',
    '/manifest.json',
    'https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Outfit:wght@200;300;400;500;600;700&family=JetBrains+Mono:wght@300;400;500;600&display=swap',
    'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css'
];

// Install — cache les assets
self.addEventListener('install', (e) => {
    e.waitUntil(
        caches.open(CACHE_NAME).then(cache => {
            return cache.addAll(ASSETS).catch(err => {
                console.warn('Cache addAll partial failure:', err);
            });
        })
    );
    self.skipWaiting();
});

// Activate — nettoie les anciens caches
self.addEventListener('activate', (e) => {
    e.waitUntil(
        caches.keys().then(keys =>
            Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
        )
    );
    self.clients.claim();
});

// Fetch — network first, fallback to cache
self.addEventListener('fetch', (e) => {
    // Ne pas cacher les appels API Supabase et n8n
    if (e.request.url.includes('supabase.co') ||
        e.request.url.includes('webhook') ||
        e.request.url.includes('n8n')) {
        return;
    }

    e.respondWith(
        fetch(e.request)
            .then(response => {
                const clone = response.clone();
                caches.open(CACHE_NAME).then(cache => cache.put(e.request, clone));
                return response;
            })
            .catch(() => caches.match(e.request))
    );
});
