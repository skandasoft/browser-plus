{CompositeDisposable}  = require 'atom'
{View,$} = require 'atom-space-pen-views'
URL = require 'url'
module.exports =
class BrowserPlusView extends View
  constructor: (@model)->
    @subscriptions = new CompositeDisposable
    @model.view = @
    super

  @content: (params)->
    srcdir = atom.packages.getActivePackage('browser-plus').path
    if (url  = params.uri).indexOf('browser-plus://history') >= 0
      resources = "#{atom.packages.getActivePackage('browser-plus').path}/resources/"
      url = "file://#{resources}history.html"
    if params.src
      src = params.src.replace(/"/g,'&quot;')
      if src.includes "data:text/html,"
        url = src
      else
        url = "data:text/html, #{src}"

    @div class:'browser-plus', =>
      @div class:'uri native-key-bindings', =>
        @div class: 'nav-btns-left', =>
          @span id:'back',class:'mega-octicon octicon-arrow-left',outlet: 'back'
          @span id:'forward',class:'mega-octicon octicon-arrow-right',outlet: 'forward'
          @span id:'refresh',class:'mega-octicon octicon-sync',outlet: 'refresh'
          @span id:'select',class:'mega-octicon octicon-eye',outlet: 'select'
          @span id:'history',class:'mega-octicon octicon-book',outlet: 'history'
          @span id:'fav',class:'mega-octicon octicon-star',outlet: 'fav'

        @div class:'nav-btns', =>
          @div class: 'nav-btns-right', =>
            @span id:'thumbs',class:'mega-octicon octicon-thumbsup',outlet: 'thumbs'
            @span id:'live',class:'mega-octicon octicon-zap',outlet:'live'
            @span id:'devtool',class:'mega-octicon octicon-tools',outlet:'devtool'

          @div class:'input-uri', =>
            @input class:"native-key-bindings",type:'text',id:'uri',outlet:'uri',value:"#{params.uri}" ##{@uri}"

      @tag 'webview',class:"native-key-bindings",outlet: 'htmlv'#,preload:"file:///#{srcdir}/resources/browser-plus-client.js"
      ,nodeintegration:'on',plugins:'on',src:"#{url}", disablewebsecurity:'on', allowfileaccessfromfiles:'on', allowPointerLock:'on'

  initialize: ->
      @subscriptions.add atom.tooltips.add @back, title: 'Back'
      @subscriptions.add atom.tooltips.add @forward, title: 'Forward'
      @subscriptions.add atom.tooltips.add @refresh, title: 'Refresh'
      @subscriptions.add atom.tooltips.add @select, title: 'Select'
      @subscriptions.add atom.tooltips.add @history, title: 'View Hist/Fav-ctr+h'
      @subscriptions.add atom.tooltips.add @fav, title: 'Favoritize'
      @subscriptions.add atom.tooltips.add @live, title: 'Live'
      @subscriptions.add atom.tooltips.add @devtool, title: 'Dev Tools-f12'
      @liveOn = false
      @subscriptions.add atom.tooltips.add @thumbs, title: 'Preview'

      @element.onkeydown = =>@showDevTool(arguments)
      if @model.uri.indexOf('browser-plus://history') >= 0
        @hist = true
        @model.browserPlus.histView = @
      else
        Array.observe @model.browserPlus.fav, (ele)=>
          @checkFav()

      @htmlv[0].addEventListener "permissionrequest", (e)->
        e.request.allow()

      @htmlv[0].addEventListener "page-favicon-updated", (e)->
        debugger

      @htmlv[0].addEventListener "page-title-set", (e)->
        debugger


      @htmlv[0].addEventListener "ipc-message", (evt)=>
        switch evt.channel

          when 'selection'
            @htmlSrc = evt.args[0]?.html
            @css = evt.args[0]?.css

          when 'clearHist'
            @model.browserPlus.history = []
            @model.browserPlus.histView?.htmlv[0].send('clearHist')

          when 'remHistDate'
            hist = @model.browserPlus.history
            date = Object.keys(evt.args[0])[0]
            @model.browserPlus.history = hist.filter (ele)=>
                        if ele[date] then return false else return true
            @model.browserPlus.histView?.htmlv[0].send('updHist',@model.browserPlus.history)

          when 'remHist'
            hist = @model.browserPlus.history
            date = new Date(evt.args[0].date).toISOString().slice(0,10)
            hist.forEach (ele,idx)=>
                return unless ele[date]
                ele[date] =  ele[date]?.filter (entry)=>
                        if entry.uri is evt.args[0].uri and entry.date is evt.args[0].date
                          return false
                        return true
                hist.splice idx,1 if ele[date].length is 0
            @model.browserPlus.histView?.htmlv[0].send('updHist',hist)

          when 'remFav'
            @removeFav evt.args[0]

          when 'startup'
            uri = evt.args[0].href
            if uri and not @model.uri.includes('browser-plus:')
              @uri.val uri
              @model.uri = uri
            @model.setTitle evt.args[0].title
            @select.removeClass 'active'
            @deActivateSelection()
            @live.toggleClass 'active',@liveOn
            @liveSubscription?.dispose() unless @liveOn
            @checkNav()
            if @hist
              @htmlv[0].send 'historyPage',@model.browserPlus.history,@model.browserPlus.fav
            else
              @checkFav()
              @addHistory()
              @model.browserPlus.histView?.htmlv[0].send 'addHistory',@model.browserPlus.history

      @devtool.on 'click', (evt)=>
        @toggleDevTool()

      @live.on 'click', (evt)=>
        return if @model.src
        @liveOn = !@liveOn
        @live.toggleClass('active',@liveOn)
        if @liveOn
          @htmlv[0].executeJavaScript "location.href = '#{@model.uri}'"
          @liveSubscription = new CompositeDisposable
          @liveSubscription.add atom.workspace.observeTextEditors (editor)=>
                    @liveSubscription.add editor.onDidSave =>
                        @htmlv?[0]?.executeJavaScript? "location.href = '#{@model.uri}'"
          @model.onDidDestroy =>
            @liveSubscription.dispose()
        else
          @liveSubscription.dispose()

      @select.on 'click', (evt)=>
        unless atom.config.get('browser-plus.preview')
          alert 'change browser-plus config to allow preview'
          return

        @select.toggleClass('active')
        @deActivateSelection()

      @thumbs.on 'click', (evt)=>
        unless atom.config.get('browser-plus.preview')
          alert 'change browser-plus config to allow preview'
          return
        return unless @htmlSrc
        cssText = ""
        for className,styl of @css
          cssText += " .#{className}{  "
          for key,val of styl
            cssText += "#{key}: #{val};  "
          cssText +=" }  "

        html = """
                data:text/html,
                <html>
                  <head>
                    <meta bp-uri='browser-plus://preview'>
                    <base href='#{@uri.val()}'>
                    <style type='text/css'>
                      #{cssText}
                    </style>
                  </head>
                  <body>
                     #{@htmlSrc.replace(/"/g,'\'')}
                  </body>
                </html>
                """

        atom.workspace.open 'browser-plus://preview' , {split: 'left',searchAllPanes:true,src:html}

      @fav.on 'click',(evt)=>
        return if @model.src
        return if @htmlv[0].getUrl().includes('data:text/html,')
        return if @model.uri.includes 'browser-plus:'
        favs = @model.browserPlus.fav
        if @fav.hasClass('active')
          @removeFav(@model)
        else
          favs.push uri: @model.uri
          delCount = favs.length - atom.config.get 'browser-plus.fav'
          favs.splice 0, delCount if delCount > 0
        @fav.toggleClass 'active'
        @model.browserPlus.histView?.htmlv[0].send('updFav',@model.browserPlus.fav)

      @htmlv[0].addEventListener 'new-window', (e)->
        #require('shell').openExternal(e.url)
        atom.workspace.open e.url, {split: 'left',searchAllPanes:true}
      #
      # #
      @htmlv[0].addEventListener "did-start-loading", =>
        @htmlv[0].shadowRoot.firstChild.style.height = '95%'
        @startupCheck()

      @history.on 'click',(evt)=>
        atom.workspace.open 'browser-plus://history' , {split: 'left',searchAllPanes:true}
      #
      #
      @back.on 'click', (evt)=>
        if @htmlv[0].canGoBack() and $(` this`).hasClass('active')
          @htmlv[0].goBack()


      @forward.on 'click', (evt)=>
        if @htmlv[0].canGoForward() and $(` this`).hasClass('active')
          @htmlv[0].goForward()

      @uri.on 'keypress',(evt)=>
        if evt.which is 13
          urls = URL.parse(` this.value`)
          url = ` this.value`
          if url.indexOf(' ') >= 0
            url = "http://www.google.com/search?as_q=#{url}"
          else
            if url.search(/^localhost/i) < 0 and url.indexOf('.') < 0
              url = "http://www.google.com/search?as_q=#{url}"
            else
              if urls.protocol in ['http','https','file:']
                if urls.protocol is 'file:'
                  url = url.replace(/\\/g,"/")
                else
                  url = URL.format(urls)
              else if url.indexOf('localhost') is 0
                url = url.replace(/localhost?/,'http://127.0.0.1')
              else
                urls.protocol = 'http'
                url = URL.format(urls)
          @select.removeClass 'active'
          @deActivateSelection()
          @liveOn = false
          @live.toggleClass 'active',@liveOn
          @liveSubscription?.dispose() unless @liveOn
          @uri.val url
          @model.uri = url
          @htmlv.attr 'src',url

      @refresh.on 'click', (evt)=>
        @htmlv[0].executeJavaScript "location.href = '#{@model.uri}'"

  showDevTool: (evt)->
    @toggleDevTool() if evt[0].keyIdentifier is "F12"

  deActivateSelection: =>
    if @select.hasClass('active')
      @htmlv[0].send 'select'
    else
      @htmlv[0].send 'deselect'

  removeFav: (favorite)->
    for favr,idx in @model.browserPlus.fav
      @model.browserPlus.fav.splice idx,1 if favr.uri is favorite.uri
    @model.browserPlus.histView?.htmlv[0].send('updFav',@model.browserPlus.fav)

  setSrc: (text)->
    @htmlv[0].src = "data:text/html,#{text}"

  checkFav: ->
    @fav.removeClass 'active' if @model.browserPlus.fav.length is 0
    for favr in @model.browserPlus.fav
      if favr.uri is @model.uri
        @fav.addClass 'active'
      else
        @fav.removeClass 'active'

  toggleDevTool: ->
    open = @htmlv[0].isDevToolsOpened()
    if open
      @htmlv[0].closeDevTools()
    else
      @htmlv[0].openDevTools()

    $(@devtool).toggleClass 'active', !open

  startupCheck: ->
    return unless atom.config.get('browser-plus.preview')
    process.nextTick =>
        if @htmlv?[0]
          if @htmlv[0]?.isWaitingForResponse?()
            setTimeout =>
              @startupCheck()
            ,100
          else
            setTimeout =>
              @htmlv[0]?.executeJavaScript @model.browserPlus.CSSjs
              @htmlv[0]?.executeJavaScript @model.browserPlus.Selectorjs
              @htmlv[0]?.executeJavaScript @model.browserPlus.JQueryjs
              @htmlv[0]?.executeJavaScript @model.browserPlus.js
            ,100      #

  liveReload: ->
      @htmlv[0].executeJavaScript "location.href = '#{@model.uri}'"
  checkNav: ->
      $(@forward).toggleClass 'active',@htmlv[0].canGoForward()
      $(@back).toggleClass 'active',@htmlv[0].canGoBack()
      if @htmlv[0].canGoForward()
        if @clearForward
          $(@forward).toggleClass 'active',false
          @clearForward = false
        else
          $(@forward).toggleClass 'active',true

  addHistory: ->
    url = @htmlv[0].getUrl()
    return if url.includes('browser-plus://') or url.includes('data:text/html,')
    today = new Date().toISOString().slice(0,10)
    history = @model.browserPlus.history
    return unless history or history.length = 0
    todays = history.filter (ele,idx,arr)->
      return true if Object.keys(ele)[0] is today
    if todays.length is 0
      histToday = []
      obj = {}
      obj[today] = histToday
      history.unshift obj
    else
      histToday = todays[0][today]
    histToday.unshift date: (new Date().toString()),uri: @uri.val()
    @model.browserPlus.histView?.htmlv[0].send('updHist',@model.browserPlus.history)

  getTitle: ->
    @model.getTitle()
  # Tear down any state and detach

  # destroy: ->
    # @element.remove()
    #
