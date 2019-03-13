Bacon = require 'baconjs'

stringify = (event) ->
  keyCode = event.which
  Bacontrap.map[keyCode] || String.fromCharCode(keyCode).toLowerCase()

curry2 = (fun, a) -> (b) -> fun(a, b)

Bacontrap =
  input:
    special:
      Bacon.fromEventTarget(document, 'keydown')
        .filter((event) ->
          key = Bacontrap.map[event.which]
          key && key not in Bacontrap.modifiers)
    keypress: Bacon.fromEventTarget(document, 'keypress')
  defaults:
    timeout: 1500
    global: false
  aliases:
    cmd: 'meta'
    command: 'meta'
    escape: 'esc'
    mod: if /Mac|iPod|iPhone|iPad/.test(navigator.platform) then 'meta' else 'ctrl'
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

matchModifiers = (modifiers, event) ->
  for modifier in Bacontrap.modifiers
    return false if modifierPressed(modifier, event) != (modifier in modifiers)
  true

modifierPressed = (modifier, event) ->
  pressed = event[modifier + 'Key'] || stringify(event) == modifier

  if event.type == 'keypress' && modifier == 'shift'
    key = stringify(event)
    caseSensitive = key.toLowerCase() != key.toUpperCase()
    caseSensitive && pressed
  else
    pressed

matchKey = (key, event) ->
  if Bacontrap.groups[key]
    Bacontrap.groups[key].indexOf(stringify(event)) >= 0
  else
    stringify(event) == key

matchKeys = (keys, event) ->
  for key in keys when key not in Bacontrap.modifiers
    return false unless matchKey(key, event)
  true

Bacontrap.match = (keys, event) ->
  matchKeys(keys, event) && matchModifiers(keys, event)

Bacontrap.notInput = (event) ->
  element = event.target || event.srcElement || {}
  tagName = element.tagName

  !(tagName in ['INPUT', 'SELECT', 'TEXTAREA'] || element.isContentEditable)

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

Bacontrap.parse = (shortcut) ->
  expand = (key) ->
    if alias = Bacontrap.aliases[key]
      [alias]
    else if key.length == 1 && key.toLowerCase() != key
      ['shift', key.toLowerCase()]
    else
      [key]

  for part in shortcut.split(' ')
    combination = []
    for key in part.split('+')
      combination.push(expand(key)...)
    combination

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

module.exports = Bacontrap
