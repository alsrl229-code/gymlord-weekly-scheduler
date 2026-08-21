// 짐로드 주간 스케줄 - 오프라인 지원
// 앱 파일은 네트워크 우선(배포 즉시 반영), 실패하면 캐시로 폴백한다.
const CACHE = "gymlord-scheduler-v1";
const SUPABASE_CDN = "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.112.3";
const ASSETS = ["./", "./index.html", "./config.js", "./manifest.webmanifest", "./icon-180.png", SUPABASE_CDN];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE)
      .then((cache) => Promise.allSettled(ASSETS.map((asset) => cache.add(asset))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

function cacheCopy(request, response) {
  if (!response || !response.ok) return response;
  const copy = response.clone();
  caches.open(CACHE).then((cache) => cache.put(request, copy)).catch(() => {});
  return response;
}

self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET") return;
  const url = new URL(request.url);

  // 앱 파일: 네트워크 우선
  if (url.origin === self.location.origin) {
    event.respondWith(
      fetch(request)
        .then((response) => cacheCopy(request, response))
        .catch(() => caches.match(request).then((cached) => cached || caches.match("./index.html")))
    );
    return;
  }

  // Supabase 라이브러리(CDN): 캐시 우선
  if (url.hostname === "cdn.jsdelivr.net") {
    event.respondWith(
      caches.match(request).then((cached) => cached || fetch(request).then((response) => cacheCopy(request, response)))
    );
  }

  // 그 외(Supabase API 등)는 가로채지 않는다.
});
