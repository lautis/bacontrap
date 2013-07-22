# Bacontrap

[Mousetrap](https://github.com/ccampbell/mousetrap) inspired keyboard
shortcuts implemented with [Bacon.js](https://github.com/raimohanska/bacon.js).

Unlike Mousetrap, Bacontrap is not a standalone library: Bacon.js and
jQuery/Zepto are dependencies. Since these provide functionality for
Bacontrap, the library itself is even smaller than Mousetrap.

## Installation

You can download the latest [generated
javascript](https://github.com/lautis/bacontrap/raw/master/bacontrap.js). You 
also need to have jQuery and Bacon.js included on the page.

Of, if you're using Bower:

    $ bower install bacontrap

## Usage

```javascript
Bacontrap.bind('4').onValue(function() { console.log('4'); });
Bacontrap.bind('?').onValue(function() { console.log('show shortcuts!'); });
Bacontrap.bind('esc').onValue({ console.log('escape'); });

// combinations
Bacontrap.bind('command+shift+K').onValue(function() { console.log('command shift k'); });

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

// konami code!
Bacontrap.bind('up up down down left right left right b a enter').onValue(function() {
  console.log('konami code');
});
```

## Hacking

The build process runs on [Grunt](http://gruntjs.com). You should have node
and then install dependencies by

    $ npm install

After that, you can run use local grunt from `./node_modules/.bin/grunt` or
have it installed globally with

    $ npm install -g grunt-cli

Before running tests, install browser-side dependencies via Bower

    $ grunt bower:install

Then you should be able to run tests with

    $ grunt mocha

Watcher is also set up so tests can be run every time source files are
modified.

    $ grunt watch

There's also a Grunt task for compiling distributable JS files.

    $ grunt dist

## TODO

* Test with Internet Explorer
* Escape as modifier key
* Maybe support for different key events (keydown/keyup)
