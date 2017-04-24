# atom.project.resolvePath
{CompositeDisposable} = require 'atom'
BrowserPlusModel = require './browser-plus-model'
require 'JSON2'
require 'jstorage'
uuid = require 'node-uuid'
module.exports = BrowserPlus =
  browserPlusView: null
  subscriptions: null
  config:
    samePane:
      title: 'Open in same pane?'
      type: 'boolean'
      default: false
      order: 2
    fav:
      title: 'No of Favorites'
      type: 'number'
      default: 10
    homepage:
      title: 'HomePage'
      type: 'string'
      default: 'browser-plus://blank'
    live:
      title: 'Live Refresh in '
      type: 'number'
      default: 500
    currentFile:
      title: 'Show Current File'
      type: 'boolean'
      default: true
      order: 1
    openInSameWindow:
      title: 'Open URLs in Same Window'
      type: 'array'
      default: ['www.google.com','www.stackoverflow.com','google.com','stackoverflow.com']

  activate: (state) ->
    unless state.noReset
      state.favIcon = {}
      state.title = {}
      state.fav = []
    @resources = "#{atom.packages.getPackageDirPaths()[0]}/browser-plus/resources/"
    window.$.jStorage.set('bp.fav',[]) unless window.$.jStorage.get('bp.fav')
    window.$.jStorage.set('bp.history',[])  unless window.$.jStorage.get('bp.history')
    window.$.jStorage.set('bp.favIcon',{})  unless window.$.jStorage.get('bp.favIcon')
    window.$.jStorage.set('bp.title',{})  unless window.$.jStorage.get('bp.title')

    atom.workspace.addOpener (url,opt={})=>
      path = require 'path'
      if ( url.indexOf('http:') is 0 or url.indexOf('https:') is 0 or
          url.indexOf('localhost') is 0 or url.indexOf('file:') is 0 or
          url.indexOf('browser-plus:') is 0   or #or opt.src
          url.indexOf('browser-plus~') is 0 )
         localhostPattern = ///^
                              (http://)?
                              localhost
                              ///i
         return false unless BrowserPlusModel.checkUrl(url)
         #  check if it need to be open in same window
         unless url is 'browser-plus://blank' or url.startsWith('file:///') or not opt.openInSameWindow
           editor = BrowserPlusModel.getEditorForURI(url,opt.openInSameWindow)
           if editor
             editor.setText(opt.src)
             editor.refresh(url) unless opt.src
             pane = atom.workspace.paneForItem(editor)
             pane.activateItem(editor)
             return editor

         url = url.replace(localhostPattern,'http://127.0.0.1')
         new BrowserPlusModel {browserPlus:@,url:url,opt:opt}

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:open': => @open()
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:newTab': => @open(false, {}, true)
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:openCurrent': => @open(true)
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:history': => @history(true)
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:deleteHistory': => @delete(true)
    @subscriptions.add atom.commands.add 'atom-workspace', 'browser-plus:fav': => @favr()

  favr: ->
    favList = require './fav-view'
    new favList window.$.jStorage.get('bp.fav')

  delete: ->
    $.jStorage.set('bp.history',[])

  history: ->
    # file:///#{@resources}history.html
    atom.workspace.open "browser-plus://history" , {split: 'left',searchAllPanes:true}

  open: (url,opt = {},same)->
    same = same or atom.config.get('browser-plus.samePane')
    if url is true or atom.config.get('browser-plus.currentFile')
      editor = atom.workspace.getActiveTextEditor()
      if url = editor?.buffer?.getUri()
        url = "file:///"+url
    unless url
      url = atom.config.get('browser-plus.homepage')

    opt.split = @getPosition(same) unless opt.split
    # url = "browser-plus://preview~#{url}" if src
    atom.workspace.open url, opt

  getPosition: (same) ->
    activePane = atom.workspace.paneForItem atom.workspace.getActiveTextEditor()
    return unless activePane
    paneAxis = activePane.getParent()
    return unless paneAxis
    paneIndex = paneAxis.getPanes().indexOf(activePane)
    orientation = paneAxis.orientation ? 'horizontal'
    if orientation is 'horizontal'
      if same is true
        if  paneIndex is 0 then 'left' else 'right'
      else
        if  paneIndex is 0 then 'right' else 'left'
    else
      if same is true
        if  paneIndex is 0 then 'up' else 'down'
      else
        if  paneIndex is 0 then 'down' else 'up'

  deactivate: ->
    @browserPlusView?.destroy?()
    @subscriptions.dispose()

  serialize: ->
    noReset: true

  getBrowserPlusUrl: (url)->
    if url.startsWith('browser-plus://history')
      url = "#{@resources}history.html"
    else
      url = ''

  addPlugin: (requires)->
    @plugins ?= {}
    for key,val of requires
      try
        switch key
          when 'onInit' or 'onExit'
            @plugins[key] = (@plugins[key] or []).concat "(#{val.toString()})()"
          when 'js' or 'css'
            unless  pkgPath
              pkgs = Object.keys(atom.packages.activatingPackages).sort()
              pkg = pkgs[pkgs.length - 1]
              pkgPath = atom.packages.activatingPackages[pkg].path + "/"
            if Array.isArray(val)
              for script in val
                unless script.startsWith('http')
                  @plugins[key+"s"] = (@plugins[key] or []).concat 'file:///'+atom.packages.activatingPackages[pkg].path.replace(/\\/g,"/") + "/" + script
            else
              unless val.startsWith('http')
                @plugins[key+"s"] = (@plugins[key] or []).concat 'file:///'+ atom.packages.activatingPackages[pkg].path.replace(/\\/g,"/") + "/" + val

          when 'menus'
            if Array.isArray(val)
              for menu in val
                menu._id = uuid.v1()
                @plugins[key] = (@plugins[key] or []).concat menu
            else
              val._id = uuid.v1()
              @plugins[key] = (@plugins[key] or []).concat val

      catch error



  provideService: ->
    model:require './browser-plus-model'
    addPlugin: @addPlugin.bind(@)
