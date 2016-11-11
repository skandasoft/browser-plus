document.addEventListener 'DOMContentLoaded', ->
  window.browserPlus = {}

  browserPlus.menu = (menu) ->
    if !browserPlus.contextMenu
      browserPlus.contextMenu = jQuery("<ul id='bp-menu'></ul>")
      jQuery('body').append browserPlus.contextMenu
      browserPlus.contextMenu.hide()
      jQuery('body').on 'contextmenu', (e) ->
        if !browserPlus.contextMenu.has('li').length
          return false
        browserPlus.contextMenu.css
          top: 'auto'
          left: 'auto'
          bottom: 'auto'
          right: 'auto'
        browserPlus.contextMenu.css({ left: e.pageX , top: e.pageY})
        maxHeight = e.clientY + browserPlus.contextMenu.outerHeight()
        if maxHeight > jQuery(window).height()
          positionY = e.pageY - browserPlus.contextMenu.outerHeight() - 10
        else
          positionY = e.pageY + 10
        maxWidth = e.clientX + browserPlus.contextMenu.outerWidth()
        if maxWidth > jQuery(window).width() + 10
          positionX = e.pageX - browserPlus.contextMenu.outerWidth() - 10
        else
          positionX = e.pageX
        browserPlus.contextMenu.css({top:positionY,left:positionX})
        browserPlus.contextMenu.show()
        jQuery('body').one 'click', ->
          browserPlus.contextMenu.hide()
          children = browserPlus.contextMenu.children('.bp-selector')
          children.off 'click'
          children.remove()
        false
    if menu.name
      if menu.selector
        jQuery('body').on 'contextmenu', menu.selector, (e) ->
          return true if jQuery('#bp-menu').is(':visible')
          return true if browserPlus.contextMenu.children("[data-bpid='#{menu._id}']").length
          return true unless eval("(#{menu.selectorFilter}).bind(this)()") if menu.selectorFilter
          submenu = jQuery("<li class='bp-selector' data-bpid = '#{menu._id}'> #{menu.name} </li>")
          submenu.on 'click', eval('(' + menu.fn + ').bind(this)')
          browserPlus.contextMenu.append submenu
      else
        submenu = jQuery('<li>' + menu.name + '</li>')
        submenu.on 'click', eval('(' + menu.fn + ').bind(this)')
        browserPlus.contextMenu.append submenu
    if menu.event
      if menu.selector
        jQuery('body').on menu.event, menu.selector, eval('(' + menu.fn + ')')
      else
        jQuery('body').on menu.event, eval('(' + menu.fn + ')')
    else if menu.ctrlkey
      menu.keytype = menu.keytype or 'keyup'
      # if(ctrlkey.has('mousewheelup'))
      jQuery('body').on menu.keytype, menu.selector, menu.ctrlkey, eval('(' + menu.fn + ')')
    return

  if location.href.startsWith('data:text/html,')
  else
    console.log '~browser-plus-href~' + location.href + ' ' + document.title
  if typeof jQuery == 'undefined'
    console.log '~browser-plus-jquery~'
  else
    console.log '~browser-plus-menu~'
