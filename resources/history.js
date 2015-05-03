riot.tag('fav', '<ul id="favorite"> <h3> Favorites </h3> <li each="{ opts.fav }"> <a href="{ uri }" target=_blank > { uri } </a> <img src="unfav.png" onclick="{ parent.delete }"> </img> </li> </ul>', function(opts) {this["delete"] = (function(_this) {
  return function(e) {
    return ipc.sendToHost('remFav', e.item);
  };
})(this);

});


riot.tag('hist', '<label>Search History</label> <input type="text" name="search" onkeyup="{ filter }"> <ul id="history"> <input type="button" name="clear" value="Clearing Browsing Data" onclick="{ clear }"> <h3> History</h3> <hist-date-li each="{ name,i in opts.hist }" data="{ name }"></hist-date-li> </ul>', function(opts) {this.clear = (function(_this) {
  return function(e) {
    return ipc.sendToHost('clearHist');
  };
})(this);

this["delete"] = (function(_this) {
  return function(e) {
    var curr;
    curr =  this.opts.data;
    return ipc.sendToHost('remHistDate', curr);
  };
})(this);

this.filter = (function(_this) {
  return function(e) {
    var date, hide_date, hist, itm, itms, _i, _j, _len, _len1, _ref, _results;
    _ref =  this.opts.hist;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      hist = _ref[_i];
      for (date in hist) {
        itms = hist[date];
        hide_date = true;
        for (_j = 0, _len1 = itms.length; _j < _len1; _j++) {
          itm = itms[_j];
          if (_this.search.value.length < 2) {
            itm.hide = false;
            hide_date = false;
          } else {
            if (itm.uri.indexOf(_this.search.value) < 0) {
              itm.hide = true;
            } else {
              itm.hide = false;
              hide_date = false;
            }
          }
        }
      }
      _results.push(itms.hide_date = hide_date);
    }
    return _results;
  };
})(this);

});

riot.tag('hist-date-li', '<li class="{ hide: itms.hide_date }"> <span>{ getDate(opts.data) }</span> <img src="trash.png" onclick="{ parent.parent.delete }"> </img> <ul> <li each="{ itms }" class="{ hide: hide }"> <a href="#" onclick="window.open(\'{ uri }\')"> { uri } </a> <span> { moment(date).format(\'h:mm A\') } </span> <img src="trash.png" onclick="{ parent.delete }"> </img> </li> </ul> </li>', 'hist-date-li .hide{ display: none; } hist-date-li a{ text-decoration: un } hist-date-li .color{ background-color: yellow; } .octicon-trashcan::before{ font-family:\'Octicons Regular\'; content: "\\f0d0"; }', function(opts) {this.getDate = (function(_this) {
  return function(obj) {
    var date, datum, itms;
    for (date in obj) {
      itms = obj[date];
      _this.date = date;
      _this.itms = itms;
    }
    return datum = moment(date).format('dddd, MMMM Do YYYY');
  };
})(this);

this["delete"] = (function(_this) {
  return function(e) {
    return ipc.sendToHost('remHist', e.item);
  };
})(this);

});
