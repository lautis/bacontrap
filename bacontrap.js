(function() {
  var Bacontrap, curry2, i, stringify,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  stringify = function(event) {
    var keyCode;
    keyCode = event.which;
    return Bacontrap.map[keyCode] || String.fromCharCode(keyCode).toLowerCase();
  };

  curry2 = function(fun, a) {
    return function(b) {
      return fun(a, b);
    };
  };

  Bacontrap = {
    input: {
      special: $(document).asEventStream('keydown').filter(function(event) {
        var key;
        key = Bacontrap.map[event.which];
        return key && __indexOf.call(Bacontrap.modifiers, key) < 0;
      }),
      keypress: $(document).asEventStream('keypress')
    },
    defaults: {
      timeout: 1500,
      global: false
    },
    aliases: {
      cmd: 'meta',
      command: 'meta',
      escape: 'esc',
      mod: /Mac|iPod|iPhone|iPad/.test(navigator.platform) ? 'meta' : 'ctrl',
      option: 'alt'
    },
    map: {
      8: 'backspace',
      9: 'tab',
      13: 'enter',
      16: 'shift',
      17: 'ctrl',
      18: 'alt',
      20: 'capslock',
      27: 'esc',
      32: 'space',
      33: 'pageup',
      34: 'pagedown',
      35: 'end',
      36: 'home',
      37: 'left',
      38: 'up',
      39: 'right',
      40: 'down',
      45: 'ins',
      46: 'del',
      91: 'meta',
      93: 'meta',
      224: 'meta'
    },
    groups: {
      'num': (function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; _i <= 9; i = ++_i) {
          _results.push(i.toString());
        }
        return _results;
      })()
    },
    modifiers: ['shift', 'alt', 'meta', 'ctrl']
  };

  Bacontrap.match = function(match, event) {
    var key, _i, _len, _ref;
    _ref = match.split('+');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      key = _ref[_i];
      if (!(Bacontrap.aliases[key] ? Bacontrap.match(Bacontrap.aliases[key], event) : Bacontrap.groups[key] ? Bacontrap.groups[key].indexOf(stringify(event)) >= 0 : __indexOf.call(Bacontrap.modifiers, key) >= 0 ? event[key + "Key"] || stringify(event) === key : stringify(event) === key)) {
        return false;
      }
    }
    return true;
  };

  Bacontrap.notInput = function(event) {
    var contentEditable, element, tagName;
    element = event.target || event.srcElement || {};
    contentEditable = element.contentEditable;
    tagName = element.tagName;
    return !(tagName === 'INPUT' || tagName === 'SELECT' || tagName === 'TEXTAREA' || (contentEditable && contentEditable === 'true' || contentEditable === 'plaintext-only'));
  };

  Bacontrap.trap = function(input, shortcut, timeout, pressed) {
    var expected, stream;
    if (timeout == null) {
      timeout = Bacontrap.defaults.timeout;
    }
    if (pressed == null) {
      pressed = [];
    }
    expected = shortcut[pressed.length];
    stream = pressed.length === 0 ? input : input.take(1).takeUntil(Bacon.later(timeout, true));
    return stream.filter(curry2(Bacontrap.match, expected)).flatMap(function(event) {
      if (pressed.length + 1 === shortcut.length) {
        return Bacon.once(event);
      } else {
        return Bacontrap.trap(input, shortcut, timeout, pressed.concat(event));
      }
    });
  };

  Bacontrap.parse = function(shortcut) {
    return shortcut.toLowerCase().split(' ');
  };

  Bacontrap.bind = function(shortcuts, options) {
    var filteredInput, input, parsed, shortcut, streams;
    if (options == null) {
      options = {};
    }
    input = Bacon.mergeAll([Bacontrap.input.keypress, Bacontrap.input.special]);
    filteredInput = options.global || Bacontrap.defaults.global ? input : input.filter(Bacontrap.notInput);
    streams = (function() {
      var _i, _len, _ref, _results;
      _ref = [].concat(shortcuts);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        shortcut = _ref[_i];
        parsed = Bacontrap.parse(shortcut);
        _results.push(Bacontrap.trap(filteredInput, parsed, options.timeout));
      }
      return _results;
    })();
    return Bacon.mergeAll(streams);
  };

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Bacontrap;
  } else {
    this.window.Bacontrap = Bacontrap;
  }

}).call(this);
