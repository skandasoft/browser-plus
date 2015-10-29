{Disposable,Emitter} = require 'atom'
{Model} = require 'theorist'
# {CompositeDisposable, Emitter} = require 'event-kit'
path = require 'path'
module.exports =
  class HTMLEditor extends Model
    atom.deserializers.add(this)
    constructor: (obj)->
      @browserPlus = obj.browserPlus
      @uri = obj.uri
      @src = obj.src
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

    getIconName: ->
      @iconName

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

    updateIcon: ->
      @emit 'icon-changed'

    serialize: ->
      data:
        browserPlus: @browserPlus
        uri: @uri
        src:  @src
        iconName: @iconName
        title: @title
      deserializer: 'HTMLEditor'
    @deserialize: ({data}) ->
      new HTMLEditor(data)

    @checkUrl: (url)->
      for uri in atom.config.get('browser-plus.blockUri')
        pattern = ///
                    #{uri}
                  ///i
        if url.match(pattern) or ( @checkBlockUrl? and @checkBlockUrl(url) )
          if atom.config.get('browser-plus.alert')
            atom.notifications.addSuccess("#{url} Blocked~~Maintain Blocked URL in Browser-Plus Settings")
          else
            console.log "#{url} Blocked~~Maintain Blocked URL in Browser-Plus Settings"
          return false
        return true
