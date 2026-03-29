const CACHE_SHELL = "rage-reports-shell-v1"
const CACHE_OFFLINE = "rage-reports-offline-v1"
const OFFLINE_URL = "/offline.html"

const SHELL_URLS = ["/", "/offline.html", "/icon.svg", "/icon.png"]

// --- Install: cache app shell ---
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_SHELL).then((cache) => cache.addAll(SHELL_URLS)).catch(() => {})
  )
  self.skipWaiting()
})

// --- Activate: take control immediately ---
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((k) => k !== CACHE_SHELL && k !== CACHE_OFFLINE).map((k) => caches.delete(k))
      )
    )
  )
  self.clients.claim()
})

// --- Push: show notification ---
self.addEventListener("push", (event) => {
  let payload = {}
  try {
    payload = event.data ? event.data.json() : {}
  } catch (_) {}
  const title = payload.title || "Reportes Ciudadanos"
  const options = {
    body: payload.body || "",
    data: payload.data || {},
    icon: "/icon.svg",
    badge: "/icon.svg"
  }
  event.waitUntil(self.registration.showNotification(title, options))
})

// --- Notification click: focus existing window or open URL ---
self.addEventListener("notificationclick", (event) => {
  event.notification.close()
  const pathOrUrl = event.notification.data?.path || "/"
  const url = pathOrUrl.startsWith("http") ? pathOrUrl : new URL(pathOrUrl, self.location.origin).href
  const pathname = new URL(url).pathname

  event.waitUntil(
    clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then((clientList) => {
        for (const client of clientList) {
          if (new URL(client.url).pathname === pathname && "focus" in client) {
            return client.focus()
          }
        }
        if (clients.openWindow) {
          return clients.openWindow(url)
        }
      })
  )
})

// --- Fetch: network-first for navigation, cache-first for app shell ---
self.addEventListener("fetch", (event) => {
  if (event.request.mode === "navigate") {
    event.respondWith(
      fetch(event.request)
        .then((res) => {
          const clone = res.clone()
          caches.open(CACHE_OFFLINE).then((cache) => cache.put(event.request, clone))
          return res
        })
        .catch(() =>
          caches.match(event.request).then(
            (cached) =>
              cached ||
              caches.match(OFFLINE_URL).then((offline) => offline || new Response("Offline", { status: 503, statusText: "Service Unavailable" }))
          )
        )
    )
    return
  }

  if (event.request.method !== "GET") return

  const url = new URL(event.request.url)
  const isShell =
    url.pathname === "/" ||
    url.pathname === "/offline.html" ||
    url.pathname === "/icon.svg" ||
    url.pathname === "/icon.png" ||
    url.pathname.startsWith("/assets/")

  if (isShell) {
    event.respondWith(
      caches.match(event.request).then((cached) =>
        cached
          ? cached
          : fetch(event.request).then((res) => {
              if (res.ok) {
                const clone = res.clone()
                caches.open(CACHE_SHELL).then((cache) => cache.put(event.request, clone))
              }
              return res
            })
      )
    )
  }
})
