var Bacontrap = require("../bacontrap");
var Bacon = require("baconjs");
var shortcuts = Bacon.mergeAll([
  Bacontrap.bind("?").map("?"),
  Bacontrap.bind("pageup").map("pageup"),
  Bacontrap.bind("pagedown").map("pagedown"),
  Bacontrap.bind("mod+k").map("mod+k"),
  Bacontrap.bind("command+shift+k").map("command+shift+k"),
  Bacontrap.bind("esc w").map("esc w")
])

Bacontrap.bind("esc").onValue(function(e) {
  e.preventDefault()
  return Bacon.more;
})

document.addEventListener("DOMContentLoaded", function() {
  shortcuts.flatMapLatest(function(shortcut) {
    return Bacon.once(shortcut).merge(Bacon.later(2000, "(nothing)"))
  }).onValue(function(text) {
    document.querySelector("#shortcut").textContent = text
    return Bacon.more
  })
})
