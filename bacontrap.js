/*
  Bacontrap v0.3.3

  Copyright (c) 2013 Ville Lautanala

  Permission is hereby granted, free of charge, to any person
  obtaining a copy of this software and associated documentation
  files (the "Software"), to deal in the Software without
  restriction, including without limitation the rights to use,
  copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the
  Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.

*/
(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    define(["bacon","jquery"], factory);
  } else if (typeof exports === 'object') {
    module.exports = factory(require('baconjs'), require('jquery'));
  } else {
    root.Bacontrap = factory(root.Bacon, root.jQuery);
  }
}(this, function(baconjs, jquery) {

return (function() {
var $, Bacon, Bacontrap, curry2, i, matchKey, matchKeys, matchModifiers, modifierPressed, stringify, __indexOf = [].indexOf || function (item) {
        for (var i = 0, l = this.length; i < l; i++) {
            if (i in this && this[i] === item)
                return i;
        }
        return -1;
    };
Bacon = baconjs;
$ = jquery;
stringify = function (event) {
    var keyCode;
    keyCode = event.which;
    return Bacontrap.map[keyCode] || String.fromCharCode(keyCode).toLowerCase();
};
curry2 = function (fun, a) {
    return function (b) {
        return fun(a, b);
    };
};
Bacontrap = {
    input: {
        special: $(document).asEventStream('keydown').filter(function (event) {
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
        'num': function () {
            var _i, _results;
            _results = [];
            for (i = _i = 0; _i <= 9; i = ++_i) {
                _results.push(i.toString());
            }
            return _results;
        }()
    },
    modifiers: [
        'shift',
        'alt',
        'meta',
        'ctrl'
    ]
};
matchModifiers = function (modifiers, event) {
    var modifier, _i, _len, _ref;
    _ref = Bacontrap.modifiers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        modifier = _ref[_i];
        if (modifierPressed(modifier, event) !== __indexOf.call(modifiers, modifier) >= 0) {
            return false;
        }
    }
    return true;
};
modifierPressed = function (modifier, event) {
    var caseSensitive, key, pressed;
    pressed = event[modifier + 'Key'] || stringify(event) === modifier;
    if (event.type === 'keypress' && modifier === 'shift') {
        key = stringify(event);
        caseSensitive = key.toLowerCase() !== key.toUpperCase();
        return caseSensitive && pressed;
    } else {
        return pressed;
    }
};
matchKey = function (key, event) {
    if (Bacontrap.groups[key]) {
        return Bacontrap.groups[key].indexOf(stringify(event)) >= 0;
    } else {
        return stringify(event) === key;
    }
};
matchKeys = function (keys, event) {
    var key, _i, _len;
    for (_i = 0, _len = keys.length; _i < _len; _i++) {
        key = keys[_i];
        if (__indexOf.call(Bacontrap.modifiers, key) < 0) {
            if (!matchKey(key, event)) {
                return false;
            }
        }
    }
    return true;
};
Bacontrap.match = function (keys, event) {
    return matchKeys(keys, event) && matchModifiers(keys, event);
};
Bacontrap.notInput = function (event) {
    var element, tagName;
    element = event.target || event.srcElement || {};
    tagName = element.tagName;
    return !(tagName === 'INPUT' || tagName === 'SELECT' || tagName === 'TEXTAREA' || element.isContentEditable);
};
Bacontrap.trap = function (input, shortcut, timeout, pressed) {
    var expected, stream;
    if (timeout == null) {
        timeout = Bacontrap.defaults.timeout;
    }
    if (pressed == null) {
        pressed = [];
    }
    expected = shortcut[pressed.length];
    stream = pressed.length === 0 ? input : input.take(1).takeUntil(Bacon.later(timeout, true));
    return stream.filter(curry2(Bacontrap.match, expected)).flatMap(function (event) {
        if (pressed.length + 1 === shortcut.length) {
            return Bacon.once(event);
        } else {
            return Bacontrap.trap(input, shortcut, timeout, pressed.concat(event));
        }
    });
};
Bacontrap.parse = function (shortcut) {
    var combination, expand, key, part, _i, _j, _len, _len1, _ref, _ref1, _results;
    expand = function (key) {
        var alias;
        if (alias = Bacontrap.aliases[key]) {
            return [alias];
        } else if (key.length === 1 && key.toLowerCase() !== key) {
            return [
                'shift',
                key.toLowerCase()
            ];
        } else {
            return [key];
        }
    };
    _ref = shortcut.split(' ');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        part = _ref[_i];
        combination = [];
        _ref1 = part.split('+');
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            key = _ref1[_j];
            combination.push.apply(combination, expand(key));
        }
        _results.push(combination);
    }
    return _results;
};
Bacontrap.bind = function (shortcuts, options) {
    var filteredInput, input, parsed, shortcut, streams;
    if (options == null) {
        options = {};
    }
    input = Bacon.mergeAll([
        Bacontrap.input.keypress,
        Bacontrap.input.special
    ]);
    filteredInput = options.global || Bacontrap.defaults.global ? input : input.filter(Bacontrap.notInput);
    streams = function () {
        var _i, _len, _ref, _results;
        _ref = [].concat(shortcuts);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            shortcut = _ref[_i];
            parsed = Bacontrap.parse(shortcut);
            _results.push(Bacontrap.trap(filteredInput, parsed, options.timeout));
        }
        return _results;
    }();
    return Bacon.mergeAll(streams);
};
module.exports = Bacontrap;
return module.exports;
}());;

}));
