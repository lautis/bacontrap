stringify = (event) ->
  keyCode = event.which
  Bacontrap.map[keyCode] || String.fromCharCode(keyCode).toLowerCase()

curry2 = (fun, a) -> (b) -> fun(a, b)

Bacontrap =
  input:
    special: $(document).asEventStream('keydown')
      .filter((event) ->
        key = Bacontrap.map[event.which]
        key && key not in Bacontrap.modifiers)
    keypress: $(document).asEventStream('keypress')
  defaults:
    timeout: 1500
    global: false
  aliases:
    cmd: 'meta'
    command: 'meta'
    escape: 'esc'
    mod: /Mac|iPod|iPhone|iPad/.test(navigator.platform) ? 'meta' : 'ctrl'
    option: 'alt'
  map:
    8: 'backspace'
    9: 'tab'
    13: 'enter'
    16: 'shift'
    17: 'ctrl'
    18: 'alt'
    20: 'capslock'
    27: 'esc'
    32: 'space'
    33: 'pageup'
    34: 'pagedown'
    35: 'end'
    36: 'home'
    37: 'left'
    38: 'up'
    39: 'right'
    40: 'down'
    45: 'ins'
    46: 'del'
    91: 'meta'
    93: 'meta'
    224: 'meta'
  groups:
    'num': (i.toString() for i in [0..9])
  modifiers: ['shift', 'alt', 'meta', 'ctrl']

Bacontrap.match = (match, event) ->
  for key in match.split('+')
    return false unless (if Bacontrap.aliases[key]
      Bacontrap.match(Bacontrap.aliases[key], event)
    else if Bacontrap.groups[key]
      Bacontrap.groups[key].indexOf(stringify(event)) >= 0
    else if key in Bacontrap.modifiers
      event[key + "Key"] || stringify(event) == key
    else
      stringify(event) == key)
  true

Bacontrap.notInput = (event) ->
  element = event.target || event.srcElement || {}
  contentEditable = element.contentEditable
  tagName = element.tagName

  !(tagName == 'INPUT' || tagName == 'SELECT' || tagName == 'TEXTAREA' ||
    (contentEditable && contentEditable == 'true' || contentEditable == 'plaintext-only'))

Bacontrap.trap = (input, shortcut, timeout = Bacontrap.defaults.timeout, pressed = []) ->
  expected = shortcut[pressed.length]
  stream = if pressed.length == 0
    input
  else
    input.take(1).takeUntil(Bacon.later(timeout, true))

  stream.filter(curry2(Bacontrap.match, expected)).flatMap (event) ->
    if pressed.length + 1 == shortcut.length
      Bacon.once(event)
    else
      Bacontrap.trap(input, shortcut, timeout, pressed.concat(event))

Bacontrap.parse = (shortcut) -> shortcut.toLowerCase().split(' ')

Bacontrap.bind = (shortcuts, options = {}) ->
  input = Bacon.mergeAll([Bacontrap.input.keypress, Bacontrap.input.special])
  filteredInput = if options.global || Bacontrap.defaults.global
    input
  else
     input.filter(Bacontrap.notInput)

  streams = for shortcut in [].concat(shortcuts)
    parsed = Bacontrap.parse(shortcut)
    Bacontrap.trap(filteredInput, parsed, options.timeout)
  Bacon.mergeAll(streams)

if module?
  module.exports = Bacontrap
else
  @window.Bacontrap = Bacontrap
