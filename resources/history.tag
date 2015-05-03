<fav>
  <ul id='favorite'>
    <h3> Favorites </h3>
    <li each={ opts.fav }>
      <a href="{ uri }" target=_blank > { uri } </a>
      <img src='unfav.png' onclick={ parent.delete }> </img>
    </li>

  </ul>

  <script type='coffeescript'>
    @delete = (e)=>
      ipc.sendToHost 'remFav',e.item
  </script>
</fav>


<hist>
  <label>Search History</label>
  <input type='text' name='search' onKeyup={ filter }>
  <ul id='history'>
    <input type='button' name='clear' value='Clearing Browsing Data' onclick={ clear }>
    <h3> History</h3>
    <hist-date-li  each={ name,i in opts.hist } data={ name }></hist-date-li>
  </ul>
  <script type='coffeescript'>
    @clear  = (e)=>
      ipc.sendToHost 'clearHist'

    @delete = (e)=>
      curr = ` this`.opts.data
      ipc.sendToHost 'remHistDate', curr

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
                itm.hide = true
              else
                itm.hide = false
                hide_date = false
        itms.hide_date = hide_date
  </script>

</hist>

<hist-date-li>
  <li class={ hide: itms.hide_date }>
    <span>{ getDate(opts.data) }</span>
    <img src='trash.png' onclick={ parent.parent.delete }> </img>
    <ul>
      <li each={ itms } class='{ hide: hide }'>
        <a href='#' onclick="window.open('{ uri }')"> { uri } </a>
        <span> { moment(date).format('h:mm A') } </span>
        <img src='trash.png' onclick={ parent.delete }> </img>
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
  </style>
  <script type='coffeescript'>
    @getDate = (obj)=>
      for date,itms of obj
        @date = date
        @itms = itms
      datum = moment(date).format('dddd, MMMM Do YYYY')

    @delete = (e)=>
      ipc.sendToHost 'remHist', e.item

  </script>

</hist-date-li>
