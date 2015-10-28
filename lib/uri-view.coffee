jQ = require '../node_modules/jquery/dist/jquery.js'
require 'jquery-ui/autocomplete'
_ = require 'lodash'
module.exports =
class URIView extends View

  @content: (params)->
      @div class:'uri', =>
        @input class:"native-key-bindings", type:'text',id:'search',outlet:'search'

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
