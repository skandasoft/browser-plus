{CompositeDisposable}  = require 'atom'
{View,$} = require 'atom-space-pen-views'

jQ = require 'jquery'
require 'jquery-ui/autocomplete'

module.exports =
class BrowserPlusView extends View
  constructor: (@model)->
    @resources = "#{atom.packages.getLoadedPackage('browser-plus').path}/resources/"
    @subscriptions = new CompositeDisposable
    @model.view = @
    @model.onDidDestroy =>
      @subscriptions.dispose()
      jQ(@url).autocomplete('destroy')
    atom.notifications.onDidAddNotification (notification) ->
      if notification.type == 'info'
        setTimeout () ->
          notification.dismiss()
        , 1000
    super

  @content: (params)->
    srcdir = atom.packages.getPackageDirPaths('browser-plus')[0]+'/browser-plus'
    url  = params.url
    hideURLBar = ''
    if params.opt?.hideURLBar
      hideURLBar = 'hideURLBar'
    if params.opt?.src
      src = params.opt.src.replace(/"/g,'&quot;')
      if src.startsWith "data:text/html,"
        url = src
      else
        url = "data:text/html,#{src}"
    @div class:'browser-plus', =>
      @div class:"url native-key-bindings #{hideURLBar}",outlet:'urlbar', =>
        @div class: 'nav-btns-left', =>
          @span id:'back',class:'mega-octicon octicon-arrow-left',outlet: 'back'
          @span id:'forward',class:'mega-octicon octicon-arrow-right',outlet: 'forward'
          @span id:'refresh',class:'mega-octicon octicon-sync',outlet: 'refresh'
          @span id:'fav',class:'mega-octicon octicon-star',outlet: 'fav'
          @span id:'favList', class:'octicon octicon-arrow-down',outlet: 'favList'
          @a class:"fa fa-spinner", outlet: 'spinner'

        @div class:'nav-btns', =>
          @div class: 'nav-btns-right', =>
            # @span id:'pdf',class:'mega-octicon octicon-file-pdf',outlet: 'pdf'
            @span id:'print',class:'icon-browser-pluss icon-print',outlet: 'print'
            @span id:'live',class:'mega-octicon octicon-zap',outlet:'live'
            @span id:'devtool',class:'mega-octicon octicon-tools',outlet:'devtool'

          @div class:'input-url', =>
            @input class:"native-key-bindings", type:'text',id:'url',outlet:'url',value:"#{params.url}" ##{@url}"
        @input id:'find',class:'find find-hide',outlet:'find'
      @tag 'webview',class:"native-key-bindings",outlet: 'htmlv' ,preload:"file:///#{srcdir}/resources/bp-client.js",
      plugins:'on',src:"#{url}", disablewebsecurity:'on', allowfileaccessfromfiles:'on', allowPointerLock:'on'

  toggleURLBar: ->
    @urlbar.toggle()

  initialize: ->
      src = (req,res)=>
        _ = require 'lodash'
        # check favorites
        pattern = ///
                    #{req.term}
                  ///i
        fav = _.filter @model.browserPlus.fav,(fav)->
                      return fav.url.match(pattern) or fav.title.match(pattern)
        urls = _.pluck(fav,"url")

        res(urls)
        searchUrl = 'http://api.bing.com/osjson.aspx'
        do ->
          jQ.ajax
              url: searchUrl
              dataType: 'json'
              data: {query:req.term, 'web.count': 10}
              success: (data)=>
                urls = urls[0..10]
                search = "http://www.google.com/search?as_q="
                for dat in data[1][0..10]
                  urls.push
                        label: dat
                        value: search+dat
                res(urls)

      select = (event,ui)=>
        @goToUrl(ui.item.value)

      jQ(@url).autocomplete
          source: src
          minLength: 2
          select: select
      @subscriptions.add atom.tooltips.add @back, title: 'Back'
      @subscriptions.add atom.tooltips.add @forward, title: 'Forward'
      @subscriptions.add atom.tooltips.add @refresh, title: 'Refresh'
      @subscriptions.add atom.tooltips.add @print, title: 'Print'
      @subscriptions.add atom.tooltips.add @favList, title: 'View Favorites'
      @subscriptions.add atom.tooltips.add @fav, title: 'Favoritize'
      @subscriptions.add atom.tooltips.add @live, title: 'Live'
      @subscriptions.add atom.tooltips.add @devtool, title: 'Dev Tools-f12'

      @subscriptions.add atom.commands.add '.browser-plus', 'browser-plus-view:toggleURLBar': => @toggleURLBar()

      @liveOn = false
      @element.onkeydown = =>@showDevTool(arguments)
      @checkFav() if @model.url.indexOf('file:///') >= 0
      Array.observe @model.browserPlus.fav, (ele)=>
        @checkFav()

      @htmlv[0]?.addEventListener "permissionrequest", (e)->
        e.request.allow()

      @htmlv[0]?.addEventListener "console-message", (e)=>

        if e.message.includes('~browser-plus-href~')
          data = e.message.replace('~browser-plus-href~','')
          indx = data.indexOf(' ')
          url = data.substr(0,indx)
          title = data.substr(indx + 1)
          BrowserPlusModel = require './browser-plus-model'
          unless BrowserPlusModel.checkUrl(url)
            url = atom.config.get('browser-plus.homepage') or "http://www.google.com"
            atom.notifications.addSuccess("Redirecting to #{url}")
            @htmlv[0]?.executeJavaScript "location.href = '#{url}'"
            return
          if url and url isnt @model.url
            @url.val url
            @model.url = url
          if title
            @model.browserPlus.title[@model.url] = title
            @model.setTitle(title) if title isnt @model.getTitle()
          else
            @model.browserPlus.title[@model.url] = url
            @model.setTitle(url)

          @live.toggleClass 'active',@liveOn
          @liveSubscription?.dispose() unless @liveOn
          @checkNav()
          @checkFav()


      @htmlv[0]?.addEventListener "page-favicon-updated", (e)=>
        @model.browserPlus.favIcon[@model.url] = icon = e.favicons[0]
        @model.iconName = Math.floor(Math.random()*10000)
        @model.updateIcon()
        style = document.createElement('style')
        style.type = 'text/css'
        style.innerHTML = """
            .title.icon.icon-#{@model.iconName} {
              background-size: 16px 16px;
              background-repeat: no-repeat;
              padding-left: 20px;
              background-image: url('#{icon}');
              background-position-y: 50%;
            }
          """
        document.getElementsByTagName('head')[0].appendChild(style)

      @htmlv[0]?.addEventListener "page-title-set", (e)=>
        @model.browserPlus.title[@model.url] = e.title
        @model.setTitle(e.title)

      @devtool.on 'click', (evt)=>
        @toggleDevTool()

      @print.on 'click', (evt)=>
        @htmlv[0]?.print()

      # @pdf.on 'click', (evt)=>
      #   @htmlv[0]?.printToPDF {}, (data,err)->

      @live.on 'click', (evt)=>
        return if @model.src
        @liveOn = !@liveOn
        @live.toggleClass('active',@liveOn)
        if @liveOn
          @refreshPage()
          @liveSubscription = new CompositeDisposable
          @liveSubscription.add atom.workspace.observeTextEditors (editor)=>
                    @liveSubscription.add editor.onDidSave =>
                        timeout = atom.config.get('browser-plus.live')
                        setTimeout =>
                          @htmlv?[0]?.executeJavaScript? "location.href = '#{@model.url}'"
                        , timeout
          @model.onDidDestroy =>
            @liveSubscription.dispose()
        else
          @liveSubscription.dispose()


      @fav.on 'click',(evt)=>
        return if @model.src
        return if @htmlv[0]?.getUrl().startsWith('data:text/html,')
        return if @model.url.startsWith 'browser-plus:'
        favs = @model.browserPlus.fav
        if @fav.hasClass('active')
          @removeFav(@model)
        else
          data = {
            url: @model.url
            title: @model.browserPlus.title[@model.url] or @model.url
            favIcon: @model.browserPlus.favIcon[@model.url]
          }
          favs.push data
          delCount = favs.length - atom.config.get 'browser-plus.fav'
          favs.splice 0, delCount if delCount > 0
        @fav.toggleClass 'active'

      @htmlv[0]?.addEventListener 'new-window', (e)->
        atom.workspace.open e.url, {split: 'left',searchAllPanes:true}

      @htmlv[0]?.addEventListener "did-start-loading", =>
        @spinner.removeClass 'fa-custom'
        @htmlv[0]?.shadowRoot.firstChild.style.height = '95%'

      @htmlv[0]?.addEventListener "did-stop-loading", =>
        @spinner.addClass 'fa-custom'

      @back.on 'click', (evt)=>
        if @htmlv[0]?.canGoBack() and $(` this`).hasClass('active')
          @htmlv[0]?.goBack()

      @favList.on 'click', (evt)=>
        favList = require './fav-view'
        new favList(@model.browserPlus.fav)

      @forward.on 'click', (evt)=>
        if @htmlv[0]?.canGoForward() and $(` this`).hasClass('active')
          @htmlv[0]?.goForward()

      @url.on 'click',(evt)=>
        @url.select()

      @url.on 'keypress',(evt)=>
        URL = require 'url'
        if evt.which is 13
          @url.blur()
          urls = URL.parse(` this.value`)
          url = ` this.value`
          if url.indexOf(' ') >= 0
            url = "http://www.google.com/search?as_q=#{url}"
          else
            localhostPattern = ///^
                                (http://)?
                                localhost
                                ///i
            if url.search(localhostPattern) < 0   and url.indexOf('.') < 0
              url = "http://www.google.com/search?as_q=#{url}"
            else
              if urls.protocol in ['http','https','file:']
                if urls.protocol is 'file:'
                  url = url.replace(/\\/g,"/")
                else
                  url = URL.format(urls)
              else if url.indexOf('localhost') isnt  -1
                url = url.replace(localhostPattern,'http://127.0.0.1')
              else
                urls.protocol = 'http'
                url = URL.format(urls)
          @goToUrl(url)

      @refresh.on 'click', (evt)=>
        @refreshPage()

  refreshPage: ->
      # htmlv = @model.view.htmlv[0]
      @htmlv[0]?.executeJavaScript "location.href = '#{@model.url}'"

  goToUrl: (url)->
      BrowserPlusModel = require './browser-plus-model'
      return unless BrowserPlusModel.checkUrl(url)
      jQ(@url).autocomplete("close")
      @liveOn = false
      @live.toggleClass 'active',@liveOn
      @liveSubscription?.dispose() unless @liveOn
      @url.val url
      @model.url = url
      @htmlv.attr 'src',url

  showDevTool: (evt)->
    @toggleDevTool() if evt[0].keyIdentifier is "F12"


  removeFav: (favorite)->
    for favr,idx in @model.browserPlus.fav
      if favr.url is favorite.url
        return @model.browserPlus.fav.splice idx,1

  setSrc: (text)->
    @htmlv[0]?.src = "data:text/html,#{text}"

  checkFav: ->
    @fav.removeClass 'active'
    for favr in @model.browserPlus.fav
      if favr.url is @model.url
        @fav.addClass 'active'

  toggleDevTool: ->
    open = @htmlv[0]?.isDevToolsOpened()
    if open
      @htmlv[0]?.closeDevTools()
    else
      @htmlv[0]?.openDevTools()

    $(@devtool).toggleClass 'active', !open

  checkNav: ->
      $(@forward).toggleClass 'active',@htmlv[0]?.canGoForward()
      $(@back).toggleClass 'active',@htmlv[0]?.canGoBack()
      if @htmlv[0]?.canGoForward()
        if @clearForward
          $(@forward).toggleClass 'active',false
          @clearForward = false
        else
          $(@forward).toggleClass 'active',true

  getTitle: ->
    @model.getTitle()

  serialize: ->

  destroy: ->
    jQ(@url).autocomplete('destroy')
