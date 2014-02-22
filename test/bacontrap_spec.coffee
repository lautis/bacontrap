{expect} = require 'chai'
sinon = require 'sinon'
Bacontrap = require '../src/bacontrap.coffee'

describe "Bacontrap", ->
  describe '.match', ->
    it 'matches to characters', ->
      keyCode = 'A'.charCodeAt(0)
      expect(Bacontrap.match(['a'], which: keyCode)).to.be.ok

    it 'does not match to unexpected characters', ->
      keyCode = 'B'.charCodeAt(0)
      expect(Bacontrap.match(['a'], which: keyCode)).to.not.be.ok

    it 'matches to special keys', ->
      expect(Bacontrap.match(['backspace'], which: 8)).to.be.ok

    it 'matches with modifier keys', ->
      event = {which: 'A'.charCodeAt(0), shiftKey: true}
      expect(Bacontrap.match(['shift', 'a'], event)).to.be.ok

    it 'does not match when unexpected modifiers are present', ->
      event = {which: 'A'.charCodeAt(0), shiftKey: true}
      expect(Bacontrap.match(['a'], event)).to.not.be.ok

    it 'matches to groups', ->
      event = {which: '0'.charCodeAt(0)}
      expect(Bacontrap.match(['num'], event)).to.be.ok

  describe '.trap', ->
    before ->
      @bus = new Bacon.Bus()

    it 'binds to keyboard shortcut', ->
      spy = sinon.spy()
      Bacontrap.trap(@bus, [['ctrl', 'num']]).take(1).onValue spy

      event = {which: '0'.charCodeAt(0), ctrlKey: true}
      @bus.push event
      expect(spy.calledWith(event)).to.be.ok

    it 'handles sequences', ->
      spy = sinon.spy()
      Bacontrap.trap(@bus, [['l'], ['o'], ['l']]).take(1).onValue spy

      @bus.push {which: 'l'.charCodeAt(0)}
      @bus.push {which: 'o'.charCodeAt(0)}
      @bus.push {which: 'l'.charCodeAt(0)}
      expect(spy.called).to.be.ok

    it 'breaks sequence when non-sequence key is pressed', ->
      spy = sinon.spy()
      Bacontrap.trap(@bus, [['l'], ['o'], ['l']]).take(1).onValue spy

      @bus.push {which: 'l'.charCodeAt(0)}
      @bus.push {which: 'o'.charCodeAt(0)}
      @bus.push {which: 'r'.charCodeAt(0)}
      @bus.push {which: 'l'.charCodeAt(0)}
      expect(spy.called).to.not.be.ok

    it 'breaks sequence after idle time', ->
      clock = sinon.useFakeTimers()
      spy = sinon.spy()
      Bacontrap.trap(@bus, [['l'], ['o'], ['l']]).take(1).onValue spy

      @bus.push {which: 'l'.charCodeAt(0)}
      @bus.push {which: 'o'.charCodeAt(0)}
      clock.tick(Bacontrap.defaults.timeout + 1)
      @bus.push {which: 'l'.charCodeAt(0)}
      clock.restore()
      expect(sinon.called).to.not.be.ok

  describe '.bind', ->
    it 'binds to keyboard shortcuts', ->
      spy = sinon.spy()
      Bacontrap.bind('l', 1).take(1).onValue spy
      event = $.Event('keypress', which: 'l'.charCodeAt(0))
      $(document).triggerHandler(event)
      expect(spy.calledWith(event)).to.be.ok

    it 'binds to array of shortcuts', ->
      spy = sinon.spy()
      Bacontrap.bind(['l', 'o']).take(2).onValue spy
      $(document).triggerHandler($.Event('keypress', which: 'l'.charCodeAt(0)))
      $(document).triggerHandler($.Event('keypress', which: 'o'.charCodeAt(0)))
      expect(spy.callCount).to.equal 2

    it 'binds to aliases', ->
      spy = sinon.spy()
      Bacontrap.bind(['cmd+w']).take(1).onValue spy
      $(document).triggerHandler($.Event('keypress', which: 'w'.charCodeAt(0), metaKey: true))
      expect(spy.callCount).to.equal 1

    it 'binds to groups', ->
      spy = sinon.spy()
      Bacontrap.bind(['num']).take(1).onValue spy
      $(document).triggerHandler($.Event('keypress', which: '0'.charCodeAt(0)))
      expect(spy.callCount).to.equal 1


    it 'can handle shortcuts with esc', ->
      spy = sinon.spy()
      Bacontrap.bind('esc a').take(1).onValue spy
      $(document).triggerHandler($.Event('keydown', which: 27)) #esc
      $(document).triggerHandler($.Event('keypress', which: 'a'.charCodeAt(0)))
      expect(spy.called).to.be.ok

    describe 'input fields', ->
      event = $.Event('keypress', which: 'a'.charCodeAt(0), target: document.createElement('input'))

      it 'ignores events from inputs by default', ->
        spy = sinon.spy()
        Bacontrap.bind('a').take(1).onValue spy
        $(document).triggerHandler(event)
        expect(spy.called).to.not.be.ok

      it 'can set global keyboard shortcuts', ->
        spy = sinon.spy()
        Bacontrap.bind('a', global: true).take(1).onValue spy
        $(document).triggerHandler(event)
        expect(spy.called).to.be.ok

  describe '.parse', ->
    it 'splits key sequences', ->
      expect(Bacontrap.parse("esc shift+w")).to.deep.equal([['esc'], ['shift', 'w']])

    it 'resolves aliases', ->
      expect(Bacontrap.parse("cmd command+escape"))
        .to.deep.equal([['meta'], ['meta', 'esc']])

    it 'does not resolve groups', ->
      expect(Bacontrap.parse("num")).to.deep.equal([['num']])
