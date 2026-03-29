// Registers the service worker and subscribes to push notifications when the user enables them.
// Requires the page to have meta tag "push-vapid-public-key" or data attributes for the API.

async function registerServiceWorker() {
  if (!("serviceWorker" in navigator) || !("PushManager" in window)) return null
  try {
    const reg = await navigator.serviceWorker.register("/service-worker.js", {
      scope: "/",
      updateViaCache: "none"
    })
    await reg.ready
    return reg
  } catch (err) {
    throw err
  }
}

function urlBase64ToUint8Array(base64String) {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
  const rawData = atob(base64)
  const outputArray = new Uint8Array(rawData.length)
  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i)
  }
  return outputArray
}

async function getVapidPublicKey() {
  const resp = await fetch("/push_subscriptions/vapid_public_key", {
    credentials: "same-origin",
    headers: { Accept: "application/json" }
  })
  if (!resp.ok) {
    if (resp.status === 401) throw new Error("not_authenticated")
    if (resp.status === 500) throw new Error("vapid_not_configured")
    throw new Error(`vapid_fetch_${resp.status}`)
  }
  const data = await resp.json()
  if (!data.publicKey) throw new Error("vapid_empty")
  return data.publicKey
}

async function subscribeUser(registration) {
  const vapidKey = await getVapidPublicKey()

  let subscription
  try {
    subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(vapidKey)
    })
  } catch (e) {
    if (e.name === "NotAllowedError") throw new Error("permission_denied")
    throw e
  }

  const sub = subscription.toJSON()
  const resp = await fetch("/push_subscriptions", {
    method: "POST",
    credentials: "same-origin",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector("[name=csrf-token]")?.content || "",
      Accept: "application/json"
    },
    body: JSON.stringify({
      endpoint: sub.endpoint,
      keys: { p256dh: sub.keys?.p256dh, auth: sub.keys?.auth }
    })
  })

  if (!resp.ok) {
    if (resp.status === 401) throw new Error("not_authenticated")
    const err = await resp.json().catch(() => ({}))
    throw new Error(err.errors?.[0] || `subscribe_${resp.status}`)
  }
  return subscription
}

function isSecureContext() {
  return window.isSecureContext || window.location.protocol === "https:" || /^localhost$|^127\./.test(window.location.hostname)
}

async function enablePushNotifications() {
  try {
    if (!isSecureContext() || !("serviceWorker" in navigator) || !("PushManager" in window)) {
      return { ok: false }
    }
    const registration = await registerServiceWorker()
    if (!registration) return { ok: false }
    await subscribeUser(registration)
    return { ok: true }
  } catch (err) {
    return { ok: false }
  }
}

async function disablePushNotifications() {
  try {
    const registration = await navigator.serviceWorker.ready
    const subscription = await registration.pushManager.getSubscription()
    if (subscription) {
      await fetch("/push_subscriptions", {
        method: "DELETE",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name=csrf-token]")?.content || ""
        },
        body: JSON.stringify({ endpoint: subscription.endpoint })
      })
      await subscription.unsubscribe()
    }
    return true
  } catch (err) {
    console.error("Push unsubscription failed:", err)
    return false
  }
}

export { enablePushNotifications, disablePushNotifications }
