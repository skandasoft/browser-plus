riot.tag('hist', '<label>Search History</label> <input type="text" name="search" onkeyup="{ filter }"> <ul id="history"> <h3> History</h3> <input type="button" name="clear" value="Clearing Browsing Data" onclick="{ clear }"> <hist-date-li each="{ name,i in opts.hist }" data="{ name }"></hist-date-li> </ul>', function(opts) {this.filter = (function(_this) {
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
              if (_this.opts.title[itm.uri].toLowerCase().indexOf(_this.search.value.toLowerCase()) < 0) {
                itm.hide = true;
              } else {
                itm.hide = false;
                hide_date = false;
              }
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

this.clear = (function(_this) {
  return function(e) {
    _this.opts.hist.length = 0;
    _this.update();
    return console.log('~browser-plus-hist-clear~');
  };
})(this);

});

riot.tag('hist-date-li', '<li class="{ hide: itms.hide_date }"> <span>{ getDate(opts.data) }</span> <img src="trash.png" class="trash" onclick="{ deleteDate }"> </img> <ul> <li each="{ itms }" class="{ hide: hide }"> <input type="checkbox"> <span> { moment(date).format(\'h:mm A\') } </span> <a href="#" onclick="window.open(\'{ uri }\')"> <img class="favicon" riot-src="{ parent.parent.parent.opts.favIcon[uri] }"> { parent.getTitle(parent.parent.parent.opts.title,uri) } </a> <img class="trash" src="trash.png" onclick="{ parent.delete }"> </img> </li> </ul> </li>', 'hist-date-li .hide{ display: none; } hist-date-li a{ text-decoration: un } hist-date-li .color{ background-color: yellow; } .octicon-trashcan::before{ font-family:\'Octicons Regular\'; content: "\\f0d0"; } hist-date-li li img { width: 20px; height: 20px; padding: 0 10px; } hist-date-li li a { text-decoration: none; padding: 0 20px; } hist-date-li li .trash { opacity: 0.3; } hist-date-li li .trash:hover { opacity: 1; padding: 0 10px; }', function(opts) {this.getTitle = (function(_this) {
  return function(title, uri) {
    return title[uri].slice(0, 51);
  };
})(this);

this.getDate = (function(_this) {
  return function(obj) {
    var date, datum, itms, today, weekAgo, yday;
    today = moment().startOf('day');
    yday = moment().subtract(1, 'days').startOf('day');
    weekAgo = moment().subtract(7, 'days').startOf('day');
    for (date in obj) {
      itms = obj[date];
      _this.date = date;
      _this.itms = itms;
    }
    datum = moment(date, 'YYYYMMDD').format('dddd, MMMM Do YYYY');
    if (moment(date, 'YYYYMMDD').isSame(today)) {
      datum = 'Today ' + datum;
    }
    if (moment(date, 'YYYYMMDD').isSame(yday)) {
      datum = 'Yesterday ' + datum;
    }
    if (moment(date, 'YYYYMMDD').isSame(weekAgo)) {
      datum = 'A Week Ago ' + datum;
    }
    return datum;
  };
})(this);

this.deleteDate = (function(_this) {
  return function(e) {
    var date, hist, i, key, obj, _i, _len;
    hist = _this.parent.parent.opts.hist;
    for (i = _i = 0, _len = hist.length; _i < _len; i = ++_i) {
      key = hist[i];
      for (date in key) {
        obj = key[date];
        if (date === _this.date) {
          hist.splice(i, 1);
        }
      }
    }
    _this.unmount();
    return console.log("~browser-plus-hist-del-date~" + _this.date);
  };
})(this);

this["delete"] = (function(_this) {
  return function(e) {
    var idx, itm;
    itm = e.item;
    idx = _this.itms.indexOf(itm);
    _this.itms.splice(idx, 1);
    if (_this.itms.length === 0) {
      return _this.deleteDate();
    } else {
      return console.log("~browser-plus-hist-delete~" + (JSON.stringify(itm)));
    }
  };
})(this);

});
