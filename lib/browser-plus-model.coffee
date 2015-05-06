{Disposable,Emitter} = require 'atom'
{Model} = require 'theorist'
# {CompositeDisposable, Emitter} = require 'event-kit'
path = require 'path'
module.exports =
  class HTMLEditor extends Model
    constructor: (@browserPlus,@uri,@src)->
      @disposable = new Disposable()
      @emitter = new Emitter

    getViewClass: ->
      require './browser-plus-view'

    setText: (text)->
      @view.setSrc(text)

    destroyed: ->
      # @unsubscribe()
      @emitter.emit 'did-destroy'
    onDidDestroy: (cb)->
      @emitter.on 'did-destroy', cb

    getTitle: ->
      @title or path.basename(@uri)

    getURI: ->
      if @src?.includes('data:text/html,')
        # regex = new RegExp("<bp-uri>([\\s\\S]*?)</bp-uri>")
        regex = /<meta\s?\S*?\s?bp-uri=['"](.*?)['"]\S*\/>/
        match = @src.match(regex)
        if match?[1]
          @uri = "browser-plus://preview~#{match[1]}"
        else
          @uri = "browser-plus://preview~#{new Date().getTime()}.html"
      else
        @uri

    getGrammar: ->

    setTitle: (@title)->
      @emit 'title-changed'
