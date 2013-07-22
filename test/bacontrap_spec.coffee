Bacontrap = require '../src/bacontrap.coffee'
window.Bacontrap = Bacontrap
{expect} = require 'chai'

describe "Bacontrap", ->
  describe '.match', ->
    it 'matches to characters', ->
      keyCode = 'A'.charCodeAt(0)
      expect(Bacontrap.match('a', which: keyCode)).to.be.ok

    it 'does not match to unexpected characters', ->
      keyCode = 'B'.charCodeAt(0)
      expect(Bacontrap.match('a', which: keyCode)).to.not.be.ok

    it 'matches to special keys', ->
      expect(Bacontrap.match('backspace', which: 8)).to.be.ok

    it 'matches with modifier keys', ->
      event = {which: 'A'.charCodeAt(0), shiftKey: true}
      expect(Bacontrap.match('shift+a', event)).to.be.ok

    it 'supports aliases', ->
      event = {which: 91} # meta
      expect(Bacontrap.match('command', event)).to.be.ok

    it 'supports as modifiers', ->
      event = {which: 'A'.charCodeAt(0), metaKey: true}
      expect(Bacontrap.match('command+a', event)).to.be.ok

    it 'supports aliases with multiple matches', ->
      event = {which: '0'.charCodeAt(0)}
      expect(Bacontrap.match('num', event)).to.be.ok

  describe '.trap', ->
    before ->
      @bus = new Bacon.Bus()

    it 'binds to keyboard shortcut', ->
      trapped = null
      Bacontrap.trap(@bus, ['ctrl+num']).take(1)
        .onValue (event) -> trapped = event

      event = {which: '0'.charCodeAt(0), ctrlKey: true}
      @bus.push event
      expect(trapped).to.equal event

    it 'handles sequences', ->
      trapped = null
      Bacontrap.trap(@bus, ['l', 'o', 'l']).take(1)
        .onValue (event) -> trapped = event

      @bus.push {which: 'l'.charCodeAt(0)}
      @bus.push {which: 'o'.charCodeAt(0)}
      @bus.push {which: 'l'.charCodeAt(0)}
      expect(trapped.which).to.equal 'l'.charCodeAt(0)

    it 'breaks sequence when non-sequence key is pressed', ->
      trapped = null
      Bacontrap.trap(@bus, ['l', 'o', 'l']).take(1)
        .onValue (event) -> trapped = event

      @bus.push {which: 'l'.charCodeAt(0)}
      @bus.push {which: 'o'.charCodeAt(0)}
      @bus.push {which: 'r'.charCodeAt(0)}
      @bus.push {which: 'l'.charCodeAt(0)}
      expect(trapped).to.equal null

    it 'breaks sequence after idle time', (done) ->
      trapped = null
      Bacontrap.trap(@bus, ['l', 'o', 'l'], 1).take(1)
        .onValue (event) -> trapped = event

      @bus.push {which: 'l'.charCodeAt(0)}
      @bus.push {which: 'o'.charCodeAt(0)}
      setTimeout =>
        @bus.push {which: 'l'.charCodeAt(0)}
        expect(trapped).to.equal null
        done()
      , 10

  describe '.bind', ->
    it 'binds to keyboard shortcuts', ->
      trapped = null
      Bacontrap.bind('l', 1).take(1)
        .onValue (event) -> trapped = event
      event = $.Event('keypress', which: 'l'.charCodeAt(0))
      $(document).triggerHandler(event)
      expect(trapped).to.equal event

    it 'binds to array of shortcuts', ->
      called = 0
      Bacontrap.bind(['l', 'o']).take(2).onValue (event) -> called += 1
      $(document).triggerHandler($.Event('keypress', which: 'l'.charCodeAt(0)))
      $(document).triggerHandler($.Event('keypress', which: 'o'.charCodeAt(0)))
      expect(called).to.equal 2

    it 'can handle shortcuts with esc', ->
      called = false
      Bacontrap.bind('esc a').take(1).onValue (event) -> called = true
      $(document).triggerHandler($.Event('keyup', which: 27)) #esc
      $(document).triggerHandler($.Event('keypress', which: 'a'.charCodeAt(0)))
      expect(called).to.be.ok

    describe 'input fields', ->
      event = $.Event('keypress', which: 'a'.charCodeAt(0), target: document.createElement('input'))
      it 'ignores events from inputs by default', ->
        called = false
        Bacontrap.bind('a').take(1).onValue (event) -> called = true
        $(document).triggerHandler(event)
        expect(called).to.not.be.ok

      it 'can set global keyboard shortcuts', ->
        called = false
        Bacontrap.bind('a', global: true).take(1).onValue (event) -> called = true
        $(document).triggerHandler(event)
        expect(called).to.be.ok
