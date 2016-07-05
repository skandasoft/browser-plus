# http://www.skandasoft.com/
{Disposable,Emitter} = require 'atom'
{Model} = require 'theorist'
path = require 'path'
fs = require 'fs'
module.exports =
  class HTMLEditor extends Model
    atom.deserializers.add(this)
    constructor: ({ @browserPlus,@url,@opt }) ->
      @opt = {} unless @opt
      @disposable = new Disposable()
      @emitter = new Emitter
      @src = @opt.src
      @orgURI = @opt.orgURI
      @_id = @opt._id
      unless @browserPlus.setContextMenu
        @browserPlus.setContextMenu = true
        for menu in atom.contextMenu.itemSets
          if menu.selector is 'atom-pane'
            for item in menu.items
              item.shouldDisplay = (evt)->
                return false if event.target.constructor.name = 'webview'
                return true

    getViewClass: ->
      require './browser-plus-view'

    setText: (@src)->
      @view.setSrc(@src) if @src

    refresh: (url)->
        @view.refreshPage(url)

    destroyed: ->
      # @unsubscribe()
      @emitter.emit 'did-destroy'

    onDidDestroy: (cb)->
      @emitter.on 'did-destroy', cb

    getTitle: ->
      if @title?.length > 20
        @title = @title[0...20]+'...'
      @title or path.basename(@url)

    getIconName: ->
      @iconName

    getURI: ->
      return false if @url is 'browser-plus://blank'
      @url

    getGrammar: ->

    setTitle: (@title)->
      @emit 'title-changed'

    updateIcon: (@favIcon)->
      @emit 'icon-changed'

    serialize: ->
      ss = require('simplestorage.js')
      data:
        browserPlus: @browserPlus
        url: @url
        opt:
          src:  @src
          iconName: @iconName
          title: @title

      deserializer:  'HTMLEditor'

    @deserialize: ({data}) ->
      new HTMLEditor(data)

    @checkUrl: (url)->
      if @checkBlockUrl? and @checkBlockUrl(url)
        atom.notifications.addSuccess("#{url} Blocked~~Maintain Blocked URL in Browser-Plus Settings")
        return false
      return true

    @getEditorForURI: (url,sameWindow)->
      return if url.startsWith('file:///')
      a = document.createElement("a")
      a.href = url
      if not sameWindow and (urls = atom.config.get('browser-plus.openInSameWindow')).length
        sameWindow = a.hostname in urls

      return unless sameWindow
      panes = atom.workspace.getPaneItems()
      a1 = document.createElement("a")
      for editor in panes
        uri = editor.getURI()
        a1.href = uri
        return editor if a1.hostname is a.hostname
      return false
