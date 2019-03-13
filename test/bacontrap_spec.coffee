{expect} = require 'chai'
sinon = require 'sinon'
Bacon = require 'baconjs'

Bacontrap = require '../src/bacontrap.coffee'

keyEvent = (key, modifiers = []) ->
  keyCode = if typeof(key) == "string"
    key.charCodeAt(0)
  else
    key

  event = new CustomEvent('keydown', bubbles: true)
  for modifier in modifiers
    event[modifier + 'Key'] = true
  event.keyCode = keyCode
  event

describe "Bacontrap", ->
  describe '.match', ->
    it 'matches to characters', ->
      expect(Bacontrap.match(['a'], keyEvent('a'))).to.be.ok

    it 'does not match to unexpected characters', ->
      expect(Bacontrap.match(['a'], keyEvent('b'))).to.not.be.ok

    it 'matches to special keys', ->
      expect(Bacontrap.match(['backspace'], keyEvent(8))).to.be.ok

    it 'matches with modifier keys', ->
      event = keyEvent('a', ['alt'])
      expect(Bacontrap.match(['alt', 'a'], event)).to.be.ok

    it 'matches to uppercase characters', ->
      expect(Bacontrap.match(['a'], keyEvent('A', ['shift']))).to.not.be.ok
      expect(Bacontrap.match(['shift', 'a'], keyEvent('A', ['shift']))).to.be.ok

    it 'matches to ? on keydown', ->
      event = keyEvent('?', ['shift'])
      expect(Bacontrap.match(['?'], event)).to.be.ok

    it 'does not match when unexpected modifiers are present', ->
      event = keyEvent('a', ['alt'])
      expect(Bacontrap.match(['a'], event)).to.not.be.ok

    it 'matches to groups', ->
      event = keyEvent('0')
      expect(Bacontrap.match(['num'], event)).to.be.ok

  describe '.trap', ->
    before ->
      @bus = new Bacon.Bus()

    it 'binds to keyboard shortcut', ->
      spy = sinon.spy()
      Bacontrap.trap(@bus, [['ctrl', 'num']]).take(1).onValue spy

      event = keyEvent('0', ['ctrl'])
      @bus.push event
      expect(spy.calledWith(event)).to.be.ok

    it 'handles sequences', ->
      spy = sinon.spy()
      Bacontrap.trap(@bus, [['l'], ['o'], ['l']]).take(1).onValue spy

      @bus.push keyEvent('l')
      @bus.push keyEvent('o')
      @bus.push keyEvent('l')
      expect(spy.called).to.be.ok

    it 'breaks sequence when non-sequence key is pressed', ->
      spy = sinon.spy()
      Bacontrap.trap(@bus, [['l'], ['o'], ['l']]).take(1).onValue spy

      @bus.push keyEvent('l')
      @bus.push keyEvent('o')
      @bus.push keyEvent('r')
      @bus.push keyEvent('l')
      expect(spy.called).to.not.be.ok

    it 'breaks sequence after idle time', ->
      clock = sinon.useFakeTimers()
      spy = sinon.spy()
      Bacontrap.trap(@bus, [['l'], ['o'], ['l']]).take(1).onValue spy

      @bus.push keyEvent('l')
      @bus.push keyEvent('o')
      clock.tick(Bacontrap.defaults.timeout + 1)
      @bus.push keyEvent('l')
      clock.restore()
      expect(sinon.called).to.not.be.ok

  describe '.bind', ->
    it 'binds to keyboard shortcuts', ->
      spy = sinon.spy()
      Bacontrap.bind('l', 1).take(1).onValue spy
      event = keyEvent('l')
      document.dispatchEvent(event)
      expect(spy.calledWith(event)).to.be.ok

    it 'binds to array of shortcuts', ->
      spy = sinon.spy()
      Bacontrap.bind(['l', 'o']).take(2).onValue spy
      document.dispatchEvent(keyEvent('l'))
      document.dispatchEvent(keyEvent('o'))
      expect(spy.callCount).to.equal 2

    it 'binds to aliases', ->
      spy = sinon.spy()
      Bacontrap.bind(['cmd+w']).take(1).onValue spy
      document.dispatchEvent(keyEvent('w', ['meta']))
      expect(spy.callCount).to.equal 1

    it 'binds to groups', ->
      spy = sinon.spy()
      Bacontrap.bind(['num']).take(1).onValue spy
      document.dispatchEvent(keyEvent('0'))
      expect(spy.callCount).to.equal 1


    it 'can handle shortcuts with esc', ->
      spy = sinon.spy()
      Bacontrap.bind('esc a').take(1).onValue spy
      document.dispatchEvent(keyEvent(27)) #esc
      document.dispatchEvent(keyEvent('a'))
      expect(spy.called).to.be.ok

    describe 'input fields', ->
      it 'ignores events from inputs by default', ->
        spy = sinon.spy()
        Bacontrap.bind('a').take(1).onValue spy
        target = document.createElement('input')
        document.body.appendChild(target)
        target.dispatchEvent(keyEvent('a'))
        expect(spy.called).to.not.be.ok
        document.dispatchEvent(keyEvent('a'))
        expect(spy.called).to.be.ok

      it 'can set global keyboard shortcuts', ->
        spy = sinon.spy()
        Bacontrap.bind('a', global: true).take(1).onValue spy
        target = document.createElement('input')
        document.body.appendChild(target)
        target.dispatchEvent(keyEvent('a'))
        expect(spy.called).to.be.ok

  describe '.parse', ->
    it 'splits key sequences', ->
      expect(Bacontrap.parse("esc shift+w")).to.deep.equal([['esc'], ['shift', 'w']])

    it 'resolves aliases', ->
      expect(Bacontrap.parse("cmd command+escape"))
        .to.deep.equal([['meta'], ['meta', 'esc']])

    it 'expands uppercase characters', ->
      expect(Bacontrap.parse('A'))
        .to.deep.equal([['shift', 'a']])

    it 'does not resolve groups', ->
      expect(Bacontrap.parse("num")).to.deep.equal([['num']])
