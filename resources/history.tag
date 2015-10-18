<hist>
  <label>Search History</label>
  <input type='text' name='search' onKeyup={ filter }>
  <ul id='history'>

    <h3> History</h3>
    <input type='button' name='clear' value='Clearing Browsing Data' onclick={ clear }>
    <hist-date-li  each={ name,i in opts.hist } data={ name }></hist-date-li>
  </ul>
  <script type='coffeescript'>

    @filter = (e)=>

      for hist in ` this`.opts.hist
        for date,itms of hist
          hide_date = true
          for itm in itms
            if @search.value.length < 2
              itm.hide = false
              hide_date = false
            else
              if itm.uri.indexOf(@search.value) < 0
                if @opts.title[itm.uri].toLowerCase().indexOf(@search.value.toLowerCase()) < 0
                    itm.hide = true
                  else
                    itm.hide = false
                    hide_date = false
              else
                itm.hide = false
                hide_date = false


        itms.hide_date = hide_date
    @clear  = (e)=>
      @opts.hist.length = 0
      @update()
      console.log '~browser-plus-hist-clear~'

  </script>

</hist>

<hist-date-li>
  <li class={ hide: itms.hide_date }>
    <span>{ getDate(opts.data) }</span>
    <img src='trash.png' class='trash' onclick={ deleteDate }> </img>
    <ul>
      <li each={ itms } class='{ hide: hide }'>
        <input type='checkbox'>
        <span> { moment(date).format('h:mm A') } </span>
        <a href='#' onclick="window.open('{ uri }')">
          <img class="favicon" src="{ parent.parent.parent.opts.favIcon[uri] }"/>
          { parent.getTitle(parent.parent.parent.opts.title,uri) }
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

    @getTitle = (title,uri)=>
      title[uri][0..50]

    @getDate = (obj)=>
      today = moment().startOf('day')
      yday = moment().subtract(1,'days').startOf('day')
      weekAgo = moment().subtract(7,'days').startOf('day')
      for date,itms of obj
        @date = date
        @itms = itms

      datum = moment(date,'YYYYMMDD').format('dddd, MMMM Do YYYY')
      datum = 'Today '+datum if moment(date,'YYYYMMDD').isSame(today)
      datum = 'Yesterday '+datum if moment(date,'YYYYMMDD').isSame(yday)
      datum = 'A Week Ago '+datum if moment(date,'YYYYMMDD').isSame(weekAgo)
      datum

    @deleteDate = (e)=>
      hist = @parent.parent.opts.hist
      for key,i in hist
        for date,obj of key
          if date is @date
            hist.splice(i,1)
      @unmount()
      console.log "~browser-plus-hist-del-date~#{@date}"

    @delete = (e)=>
      itm = e.item
      idx = @itms.indexOf(itm)
      @itms.splice(idx,1)
      if @itms.length is 0
        @deleteDate()
      else
        console.log "~browser-plus-hist-delete~#{JSON.stringify(itm)}"

  </script>

</hist-date-li>
