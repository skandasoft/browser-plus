unless window['browser-plus']?
  ipc = require 'ipc'
  href = location.href
  href = null if href.includes 'data:text/html,'
  ipc.sendToHost 'startup',{ href:href, title: document.title }


  jQ = require 'jquery'
  jQ ->
    CSSUtilities.define 'async',false
    CSSUtilities.init()
    return unless jQ('body').find('#bp-selector').length is 0
    bp = window['browser-plus'] or= {}
    bp.selector = jQ """
              <div id="bp-selector">
                  <div id="bp-selector-top"></div>
                  <div id="bp-selector-left"></div>
                  <div id="bp-selector-right"></div>
                  <div id="bp-selector-bottom"></div>
              </div>
            """
    style = """
        <style type='text/css'>
          #bp-selector-top, #bp-selector-bottom {
        	background: blue;
        	height:3px;
        	position: fixed;o
        	transition:all 300ms ease;
          z-index:9999;
        }
        #bp-selector-left, #bp-selector-right {
        	background: blue;
        	width:3px;
        	position: fixed;
        	transition:all 300ms ease;
          z-index:9999;
        }

        .n{
         -webkit-transform: scale(3) translateX(100px)
        }
        </style>
    """
    jQ('head').append style
    jQselector = jQ('body').append bp.selector
    bp.selector.hide()
    bp.clicked = false
    bp.elements =
        top: jQselector.find('#bp-selector-top')
        left: jQselector.find('#bp-selector-left')
        right: jQselector.find('#bp-selector-right')
        bottom: jQselector.find('#bp-selector-bottom')


    bp.click = (evt)->
        bp = window['browser-plus']
        if bp.clicked
          jQ(document).on 'mousemove', bp.mouseMove
        else
          jQ(document).off 'mousemove', bp.mouseMove
          count = 100
          css = {}
          target = jQ(bp.target[0].outerHTML)
          css["bp-#{count}"] = CSSUtilities.getCSSProperties bp.target[0],"screen"
          target[0].className += " bp-#{count}"
          traverse = (root)->
                        for ele in root.children()
                          orgEle = jQ(bp.target[0]).find(ele.nodeName).filter ->
                            @outerHTML is ele.outerHTML
                          count += 1
                          ele.className = ele.className + " bp-#{count}"
                          css["bp-#{count}"] = CSSUtilities.getCSSProperties orgEle[0],"screen"
                          traverse jQ(ele)
          traverse(target)
          @htmlSrc = target[0].outerHTML
          @css = css
          ipc.sendToHost 'selection', css: @css, html: @htmlSrc

        bp.clicked = !bp.clicked
        false


    bp.mouseMove = (evt)->
        return  if evt.target.id.indexOf("bp-selector") isnt -1 or evt.target.tagName is "BODY" or evt.target.tagName is "HTML"
        bp = window['browser-plus']
        bp.target = jQtarget = jQ(evt.target)
        targetOffset = jQtarget[0].getBoundingClientRect()
        targetHeight = targetOffset.height
        targetWidth = targetOffset.width
        elements = bp.elements
        elements.top.css
          left: (targetOffset.left - 4)
          top: (targetOffset.top - 4)
          width: (targetWidth + 5)

        elements.bottom.css
          top: (targetOffset.top + targetHeight + 1)
          left: (targetOffset.left - 3)
          width: (targetWidth + 4)

        elements.left.css
          left: (targetOffset.left - 5)
          top: (targetOffset.top - 4)
          height: (targetHeight + 8)

        elements.right.css
          left: (targetOffset.left + targetWidth + 1)
          top: (targetOffset.top - 4)
          height: (targetHeight + 8)

    ipc.on 'select', ->
      bp = window['browser-plus']
      bp.selector.show()
      jQ(document).mousemove bp.mouseMove
      jQ(document).click bp.click

    ipc.on 'deselect', ->
      bp = window['browser-plus']
      bp.selector.hide()
      jQ(document).off 'mousemove', bp.mouseMove
      jQ(document).off 'click', bp.click

    ipc.on 'selection', ->
      html  = null
      css = []
      selection = window.getSelection()
      if selection.rangeCount > 0
        rn = selection.getRangeAt(0)
        return ipc.sendToHost 'preview', url: location.href unless rn
        div = document.createElement('div')
        div.appendChild rn.cloneContents()
        doc = jQ(rn.commonAncestorContainer)
        styl = document.defaultView.getComputedStyle
        css.push styl doc,null
        traverse = (div)->
                  for ele in div.children
                    # css.push styl ele,null
                    # jQhtml.find(ele)?.css styl ele,null
                    docEle = doc.find(ele.nodeName).filter ->
                              @outerHTML is ele.outerHTML
                    if docEle.length
                      for key,val of styl docEle[0],null
                        # return if val is 'none' or val is '0px' or val is '0' or val is 'normal'
                        ele.style[key] = val
                    traverse(ele)
        traverse(div)
      ipc.sendToHost 'selection', css: css, html: div.innerHTML

    ipc.on 'unclick', ->
      jQ('a').css 'cursor':'text'
      jQ('a').click -> false

  ipc.on 'updHist', (hist)->
    window.histTag.opts.hist = hist
    window.histTag.update()

  ipc.on 'updFav', (fav)->
    window.favTag.opts.fav = fav
    window.favTag.update()

  ipc.on 'historyPage', (hist,fav)->
    window.favTag = riot.mount('fav',{fav:fav})[0]
    window.histTag = riot.mount('hist',{hist:hist})[0]

  ipc.on 'clearHist', ->
    window.histTag.unmount(false)
    window.histTag = riot.mount('hist',[])
