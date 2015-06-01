{CompositeDisposable} = require 'atom'
BrowserPlusModel = require './browser-plus-model'
BrowserPlusView = require './browser-plus-view'
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
    preview:
      title: 'Allow Preview'
      type: 'boolean'
      default: true
      
  activate: (state) ->
    @history = state.history or []
    @fav = state.fav or []
    # resources = "#{atom.packages.getPackageDirPaths()[0]}/browser-plus/resources/"
    resources = "#{atom.packages.getLoadedPackage('browser-plus').path}/resources/"
    @js = fs.readFileSync "#{resources}browser-plus-client.js",'utf-8'
    @CSSjs = fs.readFileSync "#{resources}CSSUtilities.js",'utf-8'
    @JQueryjs = fs.readFileSync "#{resources}jquery-1.11.3.min.js",'utf-8'
    # @JQueryjs = fs.readFileSync "#{resources}jquery-1.11.3.js",'utf-8'
    @Selectorjs = fs.readFileSync "#{resources}selector.js",'utf-8'

    atom.workspace.addOpener (uri,opt)=>
      path = require 'path'
      if ( path.extname(uri) is '.htmlp' or
          uri.indexOf('http:') is 0 or uri.indexOf('https:') is 0 or
          uri.indexOf('localhost') is 0 or uri.indexOf('file:') is 0 or
          uri.indexOf('browser-plus:') is 0 ) #or opt.src
         uri = uri.replace('localhost','http://127.0.0.1')
         bp = new BrowserPlusModel @,uri,opt.src
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
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:history': => @hist()

  open: (uri = atom.config.get('browser-plus.homepage'),split,src)->
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
