import "@hotwired/turbo-rails"
import { enablePushNotifications } from "push_notifications"
import "searchable_select"
import "alcaldias_by_state"

document.addEventListener("turbo:load", () => {
  if (document.body.dataset.authenticated === "true") {
    enablePushNotifications().catch(() => {})
  }
})
