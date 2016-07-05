<hist>
  <label>Search History</label>
  <input type='text' name='search' onKeyup={ filter }>
  <ul id='history'>

    <h3> History</h3>
    <input type='button' name='clear' value='Clearing Browsing Data' onclick={ clear }>
    <hist-date-li  each={ day,i in getHistory() } data={ day }></hist-date-li>
  </ul>
  <script type='coffeescript'>

    @filter = (e)=>
      history = $.jStorage.get('bp.history')
      title = $.jStorage.get('bp.title')
      for hist in history
        for date,itms of hist
          hide_date = true
          for itm in itms
            if jQuery('[name=search]').val()?.len < 2
              itm.hide = false
              hide_date = false
            else
              if itm.uri.indexOf(jQuery('[name=search]').val()) < 0
                if title[itm.uri]?.toLowerCase().indexOf(jQuery('[name=search]').val().toLowerCase()) < 0
                    itm.hide = true
                  else
                    itm.hide = false
                    hide_date = false
              else
                itm.hide = false
                hide_date = false


        itms.hide_date = hide_date
    @clear  = (e)=>
      history = $.jStorage.get('bp.history')
      history.length = 0
      $.jStorage.set('bp.history',history)
      @update()

    @getHistory = =>
      history = $.jStorage.get('bp.history')

  </script>

</hist>

<hist-date-li>
  <li class={ hide: itms.hide_date }>
    <span>{ getDate(opts.data) }</span>
    <img src='trash.png' class='trash' onclick={ deleteDate }> </img>
    <ul>
      <li each={ getEachDay(opts.data) } class='{ hide: hide }'>
        <span> { parent.showDate(date) } </span>
        <a href='#' onclick="window.open('{ uri }')" title="#{ uri }">
          <img class="favicon" src="{ parent.getFavIcon(uri)}" alt=""  title="#{ uri }"/>
          { parent.getTitle(uri) }
        </a>
        <img class='trash' src='trash.png' onclick={ parent.delete }> </img>
      </li>
    </ul>
  </li>
  <style>
    hist-date-li .hide{
      display: none;
    }
    hist-date-li a{
      text-decoration: un
    }
    hist-date-li .color{
      background-color: yellow;
    }
    .octicon-trashcan::before{
      font-family:'Octicons Regular';
      content: "\f0d0";
    }
    hist-date-li li img {
      width: 20px;
      height: 20px;
      padding: 0 10px;
    }
    hist-date-li li a {
      text-decoration: none;
      padding: 0 20px;
    }
    hist-date-li li .trash {
      opacity: 0.3;
    }
    hist-date-li li .trash:hover {
      opacity: 1;
      padding: 0 10px;
    }

  </style>
  <script type='coffeescript'>

    @showDate = (date)=>
      moment(date).format('h:mm A')

    @getTitle = (uri)=>
      title = $.jStorage.get('bp.title')
      if title[uri]
        title[uri][0..50]
      else
        uri[0..50]

    @getFavIcon = (uri)=>
      favIcon = $.jStorage.get('bp.favIcon')
      icon =  favIcon[uri]
      unless icon
        for url,ico of favIcon
          aurl = document.createElement('a')
          aurl.href = url
          auri = document.createElement('a')
          auri.href = uri
          if auri.hostname is aurl.hostname
            icon = ico
            return icon
      icon

    @getEachDay = (obj)=>
      for date,itms of obj
        @date = date
        @itms = itms
      @itms

    @getDate = (obj)=>
      today = moment().startOf('day')
      yday = moment().subtract(1,'days').startOf('day')
      weekAgo = moment().subtract(7,'days').startOf('day')
      for date,itms of obj
        @date = date
        @itms = itms

      datum = moment(date,'YYYYMMDD').format('dddd, MMMM Do YYYY')
      datum = 'Today '+datum if moment(@date,'YYYYMMDD').isSame(today)
      datum = 'Yesterday '+datum if moment(@date,'YYYYMMDD').isSame(yday)
      datum = 'A Week Ago '+datum if moment(@date,'YYYYMMDD').isSame(weekAgo)
      datum

    @deleteDate = (e)=>
      hist = $.jStorage.get('bp.history')
      for key,i in hist
        for date,obj of key
          if date is @date
            hist.splice(i,1)
      $.jStorage.set('bp.history',hist)
      @unmount()

    @delete = (e)=>
      hist = $.jStorage.get('bp.history')
      itm = e.item
      idx = @itms.indexOf(itm)
      history = $.jStorage.get('bp.history')
      for hist in history
        if thatDay = hist[@date]
          thatDay.splice(idx, 1)
          break
      # @itms.splice(idx,1)
      $.jStorage.set('bp.history',history)
      if thatDay.length is 0
        @deleteDate()

  </script>

</hist-date-li>
