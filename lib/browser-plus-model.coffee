# http://www.skandasoft.com/
{Disposable,Emitter} = require 'atom'
{Model} = require 'theorist'
path = require 'path'
module.exports =
  class HTMLEditor extends Model
    atom.deserializers.add(this)
    constructor: ({@browserPlus,@url,@opt})->
      @disposable = new Disposable()
      @emitter = new Emitter

    getViewClass: ->
      require './browser-plus-view'

    setText: (text)->
      @view.setSrc(text)

    refresh: ->
      @view.refreshPage()

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
      debugger;
      @url
    getGrammar: ->

    setTitle: (@title)->
      @emit 'title-changed'

    updateIcon: ->
      @emit 'icon-changed'

    serialize: ->
      data:
        browserPlus: @browserPlus
        url: @url
        src:  @src
        iconName: @iconName
        title: @title
      deserializer: 'HTMLEditor'
    @deserialize: ({data}) ->
      new HTMLEditor(data)

    @checkUrl: (url)->
      if @checkBlockUrl? and @checkBlockUrl(url)
        atom.notifications.addSuccess("#{url} Blocked~~Maintain Blocked URL in Browser-Plus Settings")
        return false
      return true
