# Bacontrap [![Build Status](https://travis-ci.org/lautis/bacontrap.png?branch=master)](https://travis-ci.org/lautis/bacontrap)

[Mousetrap](https://github.com/ccampbell/mousetrap) inspired keyboard
shortcuts implemented with [Bacon.js](https://github.com/raimohanska/bacon.js).

Unlike Mousetrap, Bacontrap is not a standalone library: Bacon.js and
jQuery/Zepto are dependencies. Since these provide functionality for
Bacontrap, the library itself is even smaller than Mousetrap.

## Installation

Download the latest [generated
javascript](https://github.com/lautis/bacontrap/raw/master/bacontrap.js) and
include it in your app. JQuery and Bacon.js also need to be included on the page.

Or, if you're using Bower:

    $ bower install bacontrap

## Usage

```javascript
Bacontrap.bind('4').onValue(function() { console.log('4'); });
Bacontrap.bind('?').onValue(function() { console.log('show shortcuts!'); });
Bacontrap.bind('esc').onValue({ console.log('escape'); });

// combinations
Bacontrap.bind('command+shift+k').onValue(function() { console.log('command shift k'); });

Bacontrap.bind(['command+k', 'ctrl+k']).onValue(function(event) {
  console.log('command k or control k');

  // prevent default browser behaviour
  event.preventDefault();
  // and stop event from bubbling
  event.stopPropagation();
  // return value is used by Bacon to control stream end
  return Bacon.more;
});

// gmail style sequences
Bacontrap.bind('g i').onValue(function() { console.log('go to inbox'); });
Bacontrap.bind('* a').onValue(function() { console.log('select all'); });

// shift+letter = LETTER
Bacontrap.bind('G').onValue(function() { console.log('shift+g'); });
Bacontrap.bind('shift+g').onValue(function() { console.log('also triggered'); });

// konami code!
Bacontrap.bind('up up down down left right left right b a enter').onValue(function() {
  console.log('konami code');
});
```

## Hacking

The build process runs on [gulp](http://gulpjs.com). Assuming npm is installed,
dependencies can be installed by running

    $ npm install

After that, you can run use local gulp from `./node_modules/.bin/gulp` or
have it installed globally with

    $ npm install -g gulp

Before running tests, install browser-side dependencies via Bower

    $ gulp bower

Then you should be able to run tests with

    $ gulp test

To continously run tests after file changes use

    $ gulp

There's also a gulp task for compiling distributable JS files.

    $ gulp dist

## TODO

* Test with Internet Explorer
* Escape as modifier key
* Maybe support for different key events (keydown/keyup)
* Keyboard shortcuts using cmd/ctrl are not triggered on Google Chrome, but using
these is probably a bad idea anyway
* Pressing modifier keys do not interrupt shortcut sequences
