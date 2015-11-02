{CompositeDisposable}  = require 'atom'
{View,$} = require 'atom-space-pen-views'
loophole = require './eval'
URL = require 'url'
jQ = require '../node_modules/jquery/dist/jquery.js'
require 'jquery-ui/autocomplete'
BrowserPlusModel = require './browser-plus-model'
_ = require 'lodash'
# riot = require 'riot'
# require 'riotgear'
favList = require './fav-view'
module.exports =
class BrowserPlusView extends View
  constructor: (@model)->
    @subscriptions = new CompositeDisposable
    @model.view = @
    @model.onDidDestroy =>
      jQ(@uri).autocomplete('destroy')
    super

  @content: (params)->
    srcdir = atom.packages.getPackageDirPaths('browser-plus')[0]+'/browser-plus'
    if (url  = params.uri).indexOf('browser-plus://history') >= 0
      resources = "#{srcdir}/resources/"
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
          @span id:'favList', class:'octicon octicon-arrow-down',outlet: 'favList'

        @div class:'nav-btns', =>
          @div class: 'nav-btns-right', =>
            # @span id:'pdf',class:'mega-octicon octicon-file-pdf',outlet: 'pdf'
            @span id:'print',class:'icon-browser-pluss icon-print',outlet: 'print'
            @span id:'thumbs',class:'mega-octicon octicon-thumbsup',outlet: 'thumbs'
            @span id:'live',class:'mega-octicon octicon-zap',outlet:'live'
            @span id:'devtool',class:'mega-octicon octicon-tools',outlet:'devtool'

          @div class:'input-uri', =>
            @input class:"native-key-bindings", type:'text',id:'uri',outlet:'uri',value:"#{params.uri}" ##{@uri}"
            # @tag 'rg-select', autocomplete:"true", type:'text',options="{ countries }", class:"native-key-bindings",type:'text',id:'uri',outlet:'uri',value:"#{params.uri}" ##{@uri}"
      if atom.config.get('browser-plus.node')
        @tag 'webview',class:"native-key-bindings",outlet: 'htmlv',
        nodeintegration:'on',plugins:'on',src:"#{url}", disablewebsecurity:'on', allowfileaccessfromfiles:'on', allowPointerLock:'on',preload:"file:///#{srcdir}/resources/bp-client.js",
      else
        @tag 'webview',class:"native-key-bindings",outlet: 'htmlv' ,preload:"file:///#{srcdir}/resources/bp-client.js",
        # @tag 'webview',class:"native-key-bindings",outlet: 'htmlv' ,preload:clientJS
        plugins:'on',src:"#{url}", disablewebsecurity:'on', allowfileaccessfromfiles:'on', allowPointerLock:'on'

  initialize: ->
      src = (req,res)=>
        # check favorites
        pattern = ///
                    #{req.term}
                  ///i
        history = []
        fav = _.filter @model.browserPlus.fav,(fav)->
                      return fav.uri.match(pattern) or fav.title.match(pattern)
        for histDate in @model.browserPlus.history
          for key,hists of histDate
            for hist in hists
              title = @model.browserPlus.title[hist.uri]
              history.push hist.uri if hist.uri.match(pattern) or title?.match(pattern)
        uris = _.union _.pluck(fav,"uri"), history

        res(uris)
        # searchUrl = 'http://api.bing.com/osjson.aspx?JsonType=callback&JsonCallback=?'
        searchUrl = 'http://api.bing.com/osjson.aspx'
        # jQ.getJSON searchUrl,
        #     query: req.term
        #   ,(data)->
        #     # jQ(@uri).removeClass('ui-autocomplete-loading')
        #     debugger
        #     search = "http://www.google.com/search?as_q="
        #     for dat in data
        #       uris.push { dat: search+dat}
        #     res(uris)
        do ->
          jQ.ajax
              url: searchUrl
              dataType: 'json'
              data: {query:req.term, 'web.count': 10}
              success: (data)=>
                # jQ(@uri).removeClass('ui-autocomplete-loading')
                uris = uris[0..10]
                search = "http://www.google.com/search?as_q="
                for dat in data[1][0..10]
                  uris.push
                        label: dat
                        value: search+dat
                res(uris)

      select = (event,ui)=>
        @goToUrl(ui.item.value)

      jQ(@uri).autocomplete
          source: src
          minLength: 2
          select: select
      @subscriptions.add atom.tooltips.add @back, title: 'Back'
      @subscriptions.add atom.tooltips.add @forward, title: 'Forward'
      @subscriptions.add atom.tooltips.add @refresh, title: 'Refresh'
      @subscriptions.add atom.tooltips.add @select, title: 'Select'
      @subscriptions.add atom.tooltips.add @history, title: 'View Hist/ctrl+h'
      @subscriptions.add atom.tooltips.add @print, title: 'Print'
      @subscriptions.add atom.tooltips.add @favList, title: 'View Favorites'
      @subscriptions.add atom.tooltips.add @fav, title: 'Favoritize'
      @subscriptions.add atom.tooltips.add @live, title: 'Live'
      @subscriptions.add atom.tooltips.add @devtool, title: 'Dev Tools-f12'
      @liveOn = false
      @subscriptions.add atom.tooltips.add @thumbs, title: 'Preview'
      @element.onkeydown = =>@showDevTool(arguments)
      @checkFav() if @model.uri.indexOf('file:///') >= 0
      if @model.uri.indexOf('browser-plus://history') >= 0
        @hist = true
        @model.browserPlus.histView = @
      else
        Array.observe @model.browserPlus.fav, (ele)=>
          @checkFav()

      @htmlv[0]?.addEventListener "permissionrequest", (e)->
        e.request.allow()

      @htmlv[0]?.addEventListener "console-message", (e)=>
        if @model.uri is 'browser-plus://history'
          if e.message.includes('~browser-plus-hist-clear~')
            @model.browserPlus.history = []
            @htmlv[0]?.executeJavaScript "riot.mount('hist',eval(#{data})); histTag = (riot.update())[0]"

          if e.message.includes('~browser-plus-hist-del-date~')
            delDate = e.message.replace('~browser-plus-hist-del-date~','')
            hist = @model.browserPlus.history
            for key,i in hist
              for date,obj of key
                if date is delDate
                  hist.splice(i,1)

          if e.message.includes('~browser-plus-hist-delete~')
            item = e.message.replace('~browser-plus-hist-delete~','')
            item = loophole.allowUnsafeEval ->
                      eval "(#{item})"
            MOMENT = require "../resources/moment.min.js"
            moment = MOMENT(item.date).format('YYYYMMDD')
            hist = @model.browserPlus.history
            return unless hist or hist.length is 0
            for his in hist
              for date,itms of his
                if date is moment
                  for idx,itm of itms
                    itms.splice(idx,1) if itm.date is item.date

        # return if @model.uri.indexOf('browser-plus://') is 0
        if e.message.includes('~browser-plus-href~')
          if @model.uri is 'browser-plus://history'
            data =
                    hist : @model.browserPlus.history
                    fav: @model.browserPlus.fav
                    title: @model.browserPlus.title
                    favIcon: @model.browserPlus.favIcon
            data = JSON.stringify(data)
            @htmlv[0]?.executeJavaScript "riot.mount('hist',eval(#{data})); histTag = (riot.update())[0]"
          else
            data = e.message.replace('~browser-plus-href~','')
            indx = data.indexOf(' ')
            uri = data.substr(0,indx)
            title = data.substr(indx + 1)
            unless BrowserPlusModel.checkUrl(uri)
              uri = atom.config.get('browser-plus.homepage') or "http://www.google.com"
              atom.notifications.addSuccess("Redirecting to #{uri}")
              @htmlv[0]?.executeJavaScript "location.href = '#{uri}'"
              return
            if uri and uri isnt @model.uri
              @uri.val uri
              @model.uri = uri
            if title
              @model.browserPlus.title[@model.uri] = title
              @model.setTitle(title) if title isnt @model.getTitle()
            else
              @model.browserPlus.title[@model.uri] = uri
              @model.setTitle(uri)

            @select.removeClass 'active'
            @deActivateSelection()
            @live.toggleClass 'active',@liveOn
            @liveSubscription?.dispose() unless @liveOn
            @checkNav()
            @checkFav()
            @addHistory()
            if atom.config.get('browser-plus.node')
              setTimeout =>
                    @htmlv[0]?.executeJavaScript @model.browserPlus.CSSjs
                    @htmlv[0]?.executeJavaScript @model.browserPlus.Selectorjs
                    @htmlv[0]?.executeJavaScript @model.browserPlus.JQueryjs
                    @htmlv[0]?.executeJavaScript @model.browserPlus.js
                  ,100      #


      @htmlv[0]?.addEventListener "page-favicon-updated", (e)=>
        @model.browserPlus.favIcon[@model.uri] = icon = e.favicons[0]
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
              background-position-y: 5px;
            }
          """
        document.getElementsByTagName('head')[0].appendChild(style)
        @liveHistory()

      @htmlv[0]?.addEventListener "page-title-set", (e)=>
        @model.browserPlus.title[@model.uri] = e.title
        @liveHistory()
        @model.setTitle(e.title)
        #@htmlv?[0]?.executeJavaScript? 'console.log("~browser-plus-href~"+location.href + " "+document.title);'

      @htmlv[0]?.addEventListener "ipc-message", (evt)=>
        switch evt.channel

          when 'selection'
            @htmlSrc = evt.args[0]?.html
            @css = evt.args[0]?.css

      @devtool.on 'click', (evt)=>
        # return if @model.uri is 'browser-plus://history'
        @toggleDevTool()

      @print.on 'click', (evt)=>
        @htmlv[0]?.print()

      # @pdf.on 'click', (evt)=>
      #   @htmlv[0]?.printToPDF {}, (data,err)->

      @live.on 'click', (evt)=>
        return if @model.uri is 'browser-plus://history'
        return if @model.src
        @liveOn = !@liveOn
        @live.toggleClass('active',@liveOn)
        if @liveOn
          @htmlv[0]?.executeJavaScript "location.href = '#{@model.uri}'"
          @liveSubscription = new CompositeDisposable
          @liveSubscription.add atom.workspace.observeTextEditors (editor)=>
                    @liveSubscription.add editor.onDidSave =>
                        timeout = atom.config.get('browser-plus.live')
                        setTimeout =>
                          @htmlv?[0]?.executeJavaScript? "location.href = '#{@model.uri}'"
                        , timeout
          @model.onDidDestroy =>
            @liveSubscription.dispose()
        else
          @liveSubscription.dispose()

      @select.on 'click', (evt)=>
        unless atom.config.get('browser-plus.node')
          alert 'change browser-plus config to allow node integeration'
          return

        @select.toggleClass('active')
        @deActivateSelection()

      @thumbs.on 'click', (evt)=>
        unless atom.config.get('browser-plus.node')
          alert 'change browser-plus config to allow node integeration/ preview'
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
        return if @htmlv[0]?.getUrl().includes('data:text/html,')
        return if @model.uri.includes 'browser-plus:'
        favs = @model.browserPlus.fav
        if @fav.hasClass('active')
          @removeFav(@model)
        else
          data = {
            uri: @model.uri
            title: @model.browserPlus.title[@model.uri] or @model.uri
            favIcon: @model.browserPlus.favIcon[@model.uri]
          }
          favs.push data
          delCount = favs.length - atom.config.get 'browser-plus.fav'
          favs.splice 0, delCount if delCount > 0
        @fav.toggleClass 'active'
        @model.browserPlus.histView?.htmlv[0].send('updFav',@model.browserPlus.fav)

      @htmlv[0]?.addEventListener 'new-window', (e)->
        #require('shell').openExternal(e.url)
        atom.workspace.open e.url, {split: 'left',searchAllPanes:true}
      #
      # #
      @htmlv[0]?.addEventListener "did-start-loading", =>
        @htmlv[0]?.shadowRoot.firstChild.style.height = '95%'

      @history.on 'click',(evt)=>
        atom.workspace.open 'browser-plus://history' , {split: 'left',searchAllPanes:true}
      #
      #
      @back.on 'click', (evt)=>
        if @htmlv[0]?.canGoBack() and $(` this`).hasClass('active')
          @htmlv[0]?.goBack()

      @favList.on 'click', (evt)=>
        new favList(@model.browserPlus.fav)

      @forward.on 'click', (evt)=>
        if @htmlv[0]?.canGoForward() and $(` this`).hasClass('active')
          @htmlv[0]?.goForward()

      @uri.on 'keypress',(evt)=>
        if evt.which is 13
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
        return if @model.uri is 'browser-plus://history'
        @htmlv[0]?.executeJavaScript "location.href = '#{@model.uri}'"

  goToUrl: (url)->
      return unless BrowserPlusModel.checkUrl(url)
      jQ(@uri).autocomplete("close")
      @select.removeClass 'active'
      @deActivateSelection()
      @liveOn = false
      @live.toggleClass 'active',@liveOn
      @liveSubscription?.dispose() unless @liveOn
      @uri.val url
      @model.uri = url
      @htmlv.attr 'src',url

  showDevTool: (evt)->
    @toggleDevTool() if evt[0].keyIdentifier is "F12"

  deActivateSelection: =>
    if @select.hasClass('active')
      @htmlv[0]?.send 'select'
    else
      @htmlv[0]?.send 'deselect'

  removeFav: (favorite)->
    for favr,idx in @model.browserPlus.fav
      if favr.uri is favorite.uri
        return @model.browserPlus.fav.splice idx,1

  setSrc: (text)->
    @htmlv[0]?.src = "data:text/html,#{text}"

  checkFav: ->
    @fav.removeClass 'active'
    for favr in @model.browserPlus.fav
      if favr.uri is @model.uri
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

  addHistory: ->
    url = @htmlv[0]?.getUrl()
    return if url.includes('browser-plus://') or url.includes('data:text/html,')
    yyyymmdd = ->
      date = new Date()
      yyyy = date.getFullYear().toString()
      mm = (date.getMonth() + 1).toString()
      # getMonth() is zero-based
      dd = date.getDate().toString()
      yyyy + (if mm[1] then mm else '0' + mm[0]) + (if dd[1] then dd else '0' + dd[0])
    today = yyyymmdd()
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
    @liveHistory()
  getTitle: ->
    @model.getTitle()
  # Tear down any state and detach

  liveHistory: ->
    histJSON = JSON.stringify @model.browserPlus.history
    titleJSON = JSON.stringify @model.browserPlus.title
    favIconJSON = JSON.stringify @model.browserPlus.favIcon
    setTimeout =>
      @model.browserPlus.histView?.htmlv[0].executeJavaScript " histTag.opts.hist = eval(#{histJSON}); histTag.opts.title = eval(#{titleJSON});histTag.opts.favIcon = eval(#{favIconJSON});histTag.update();"
    , 2000

  serialize: ->

  destroy: ->
    # @element.remove()
    jQ(@uri).autocomplete('destroy')
    #
