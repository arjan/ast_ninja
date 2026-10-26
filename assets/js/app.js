import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import { hooks as colocatedHooks } from "phoenix-colocated/ast_ninja"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...colocatedHooks },
})

liveSocket.connect()

// Expose for debugging from the browser console: liveSocket.enableDebug()
window.liveSocket = liveSocket
