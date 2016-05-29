{CompositeDisposable} = require 'atom'

module.exports = BrowserPlus =
  browserPlusView: null
  subscriptions: null
  config:
    fav:
      title: 'No of Favorites'
      type: 'number'
      default: 10
    homepage:
      title: 'HomePage'
      type: 'string'
      default: 'http://www.google.com'
    live:
      title: 'Live Refresh in '
      type: 'number'
      default: 500
    currentFile:
      title: 'Show Current File'
      type: 'boolean'
      default: true

  activate: (state) ->
    unless state.noReset
      state.favIcon = {}
      state.title = {}
      state.fav = []

    @fav = state.fav or []
    @favIcon = state.favIcon or {}
    @title = state.title or {}
    resources = "#{atom.packages.getLoadedPackage('browser-plus').path}/resources"

    @clientJS = "#{resources}bp-client.js"
    atom.workspace.addOpener (url,opt)=>
      BrowserPlusModel = require './browser-plus-model'
      path = require 'path'
      if ( url.indexOf('http:') is 0 or url.indexOf('https:') is 0 or
          url.indexOf('localhost') is 0 or url.indexOf('file:') is 0 or
          url.indexOf('browser-plus:') is 0 ) #or opt.src
         localhostPattern = ///^
                              (http://)?
                              localhost
                              ///i
         return false unless BrowserPlusModel.checkUrl(url)
         url = url.replace(localhostPattern,'http://127.0.0.1')
         new BrowserPlusModel {browserPlus:@,url:url,opt:opt}

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:open': => @open()
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:openCurrent': => @open(true)
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:fav': => @favr()

  favr: ->
    favList = require './fav-view'
    new favList(@fav)

  open: (url,opt = {})->
    if url is true or atom.config.get('browser-plus.currentFile')
      editor = atom.workspace.getActiveTextEditor()
      if url = editor?.buffer?.getUri()
        url = "file:///"+url
    unless url
      url = atom.config.get('browser-plus.homepage')

    opt.split = @getPosition() unless opt.split
    # url = "browser-plus://preview~#{url}" if src
    atom.workspace.open url, opt

  getPosition: ->
    activePane = atom.workspace.paneForItem atom.workspace.getActiveTextEditor()
    return unless activePane
    paneAxis = activePane.getParent()
    return unless paneAxis
    paneIndex = paneAxis.getPanes().indexOf(activePane)
    orientation = paneAxis.orientation ? 'horizontal'
    if orientation is 'horizontal'
      if  paneIndex is 0 then 'right' else 'left'
    else
      if  paneIndex is 0 then 'down' else 'up'

  deactivate: ->
    @browserPlusView.destroy?()
    @subscriptions.dispose()

  serialize: ->
    fav: @fav
    favIcon: @favIcon
    title: @title
    noReset: true

  registerEvt: (cb)->
    debugger

  provideService: ->
    BrowserPlusModel = require './browser-plus-model'
    model:BrowserPlusModel
    open: @open.bind(@)
    evt: @registerEvt.bind(@)
