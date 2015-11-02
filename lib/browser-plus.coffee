{CompositeDisposable} = require 'atom'
BrowserPlusModel = require './browser-plus-model'
BrowserPlusView = require './browser-plus-view'
favList = require './fav-view'
fs = require 'fs'
module.exports = BrowserPlus =
  browserPlusView: null
  subscriptions: null
  config:
    fav:
      title: 'No of Favorites'
      type: 'number'
      default: 10
    history:
      title: 'No of Days of History'
      type: 'number'
      default: 5
    homepage:
      title: 'HomePage'
      type: 'string'
      default: 'http://www.google.com'
    live:
      title: 'Live Refresh in '
      type: 'number'
      default: 500
    node:
      title: 'Node Integration '
      type: 'boolean'
      default: false
    currentFile:
      title: 'Show Current File'
      type: 'boolean'
      default: true
    blockUri:
      title: 'Block URIs keywords'
      type: 'array'
      default: ['youtube']
    alert:
      title: 'Alert message'
      type: 'boolean'
      default: true

  activate: (state) ->
    unless state.resetAgain
      state.history = []
      state.favIcon = {}
      state.title = {}
      state.fav = []

    @history = state.history or []
    @fav = state.fav or []
    @favIcon = state.favIcon or {}
    @title = state.title or {}
    resources = "#{atom.packages.getLoadedPackage('browser-plus').path}/resources/"
    @js = fs.readFileSync "#{resources}browser-plus-client.js",'utf-8'
    @CSSjs = fs.readFileSync "#{resources}CSSUtilities.js",'utf-8'
    # @JQueryjs = fs.readFileSync "#{resources}jquery-2.1.4.min.js",'utf-8'
    @JQueryjs = fs.readFileSync "#{resources}jquery-1.11.3.min.js",'utf-8'
    @Selectorjs = fs.readFileSync "#{resources}selector.js",'utf-8'
    @clientJS = "#{resources}bp-client.js"
    atom.workspace.addOpener (uri,opt)=>
      path = require 'path'
      if ( path.extname(uri) is '.htmlp' or
          uri.indexOf('http:') is 0 or uri.indexOf('https:') is 0 or
          uri.indexOf('localhost') is 0 or uri.indexOf('file:') is 0 or
          uri.indexOf('browser-plus:') is 0 ) #or opt.src
         localhostPattern = ///^
                              (http://)?
                              localhost
                              ///i
         return false unless BrowserPlusModel.checkUrl(uri)
         uri = uri.replace(localhostPattern,'http://127.0.0.1')
         bp = new BrowserPlusModel {browserPlus:@,uri:uri,src:opt.src}
         if uri.indexOf('browser-plus://history') is 0
           bp.on 'destroyed', =>
             @histView = undefined
          return bp
    oneDay = 24*60*60*1000
    for date,val of history
      d = new Date(date)
      today = new Date()
      days = Math.round Math.abs (today.getTime() - d.getTime()) / oneDay
      delete history[date] if  days > atom.config.get('browser-plus.history')

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:open': => @open()
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:openCurrent': => @open(null,null,true)
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:history': => @hist()
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:fav': => @favr()

  favr: ->
    new favList(@fav)

  open: (split,src,current)->

    if atom.config.get('browser-plus.currentFile') or current
      editor = atom.workspace.getActiveTextEditor()
      if uri = editor?.buffer?.getUri()
        uri = "file:///"+uri
    unless uri
      uri = atom.config.get('browser-plus.homepage')

    split = @getPosition()  unless split
    atom.workspace.open uri, {split:split,src:src}

  hist: (uri='browser-plus://history',side='right')->
    atom.workspace.open uri, split:side

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
      if  paneIndex is 0 then 'down' else 'top'

  deactivate: ->
    # @browserPlusView.destroy?()
    @subscriptions.dispose()

  serialize: ->
    history : @history
    fav: @fav
    favIcon: @favIcon
    title: @title
    resetAgain: true

  provideService: ->
    BrowserPlusModel
