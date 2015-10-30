{View,SelectListView} = require 'atom-space-pen-views'

$ = require 'jquery'
class FavView extends SelectListView
  initialize: (@items)->
    super
    @addClass 'overlay from-top'
    @setItems items
    @panel ?= atom.workspace.addModalPanel item:@
    @panel.show()
    @focusFilterEditor()

  viewForItem: (item)->
      "<li><img src='#{item.favIcon}'width='20' height='20' >&nbsp; &nbsp; #{item.title?[0..30]}</li>"

  confirmed: (item)->
      atom.workspace.open item.uri, {split:'left',searchAllPanes:true}
      @parent().remove()

  cancelled: ->
    @parent().remove()

  getFilterKey: ->
    "title"
module.exports = FavView
