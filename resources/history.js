riot.tag('hist', '<label>Search History</label> <input type="text" name="search" onkeyup="{ filter }"> <ul id="history"> <h3> History</h3> <input type="button" name="clear" value="Clearing Browsing Data" onclick="{ clear }"> <hist-date-li each="{ day,i in getHistory() }" data="{ day }"></hist-date-li> </ul>', function(opts) {this.filter = (function(_this) {
  return function(e) {
    var date, hide_date, hist, history, itm, itms, title, _i, _j, _len, _len1, _ref, _ref1, _results;
    history = $.jStorage.get('bp.history');
    title = $.jStorage.get('bp.title');
    _results = [];
    for (_i = 0, _len = history.length; _i < _len; _i++) {
      hist = history[_i];
      for (date in hist) {
        itms = hist[date];
        hide_date = true;
        for (_j = 0, _len1 = itms.length; _j < _len1; _j++) {
          itm = itms[_j];
          if (((_ref = jQuery('[name=search]').val()) != null ? _ref.len : void 0) < 2) {
            itm.hide = false;
            hide_date = false;
          } else {
            if (itm.uri.indexOf(jQuery('[name=search]').val()) < 0) {
              if (((_ref1 = title[itm.uri]) != null ? _ref1.toLowerCase().indexOf(jQuery('[name=search]').val().toLowerCase()) : void 0) < 0) {
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
    var history;
    history = $.jStorage.get('bp.history');
    history.length = 0;
    $.jStorage.set('bp.history', history);
    return _this.update();
  };
})(this);

this.getHistory = (function(_this) {
  return function() {
    var history;
    return history = $.jStorage.get('bp.history');
  };
})(this);

});

riot.tag('hist-date-li', '<li class="{ hide: itms.hide_date }"> <span>{ getDate(opts.data) }</span> <img src="trash.png" class="trash" onclick="{ deleteDate }"> </img> <ul> <li each="{ getEachDay(opts.data) }" class="{ hide: hide }"> <span> { parent.showDate(date) } </span> <a href="#" onclick="window.open(\'{ uri }\')" title="#{ uri }"> <img class="favicon" riot-src="{ parent.getFavIcon(uri)}" alt="" title="#{ uri }"> { parent.getTitle(uri) } </a> <img class="trash" src="trash.png" onclick="{ parent.delete }"> </img> </li> </ul> </li>', 'hist-date-li .hide{ display: none; } hist-date-li a{ text-decoration: un } hist-date-li .color{ background-color: yellow; } .octicon-trashcan::before{ font-family:\'Octicons Regular\'; content: "\\f0d0"; } hist-date-li li img { width: 20px; height: 20px; padding: 0 10px; } hist-date-li li a { text-decoration: none; padding: 0 20px; } hist-date-li li .trash { opacity: 0.3; } hist-date-li li .trash:hover { opacity: 1; padding: 0 10px; }', function(opts) {this.showDate = (function(_this) {
  return function(date) {
    return moment(date).format('h:mm A');
  };
})(this);

this.getTitle = (function(_this) {
  return function(uri) {
    var title;
    title = $.jStorage.get('bp.title');
    if (title[uri]) {
      return title[uri].slice(0, 51);
    } else {
      return uri.slice(0, 51);
    }
  };
})(this);

this.getFavIcon = (function(_this) {
  return function(uri) {
    var auri, aurl, favIcon, ico, icon, url;
    favIcon = $.jStorage.get('bp.favIcon');
    icon = favIcon[uri];
    if (!icon) {
      for (url in favIcon) {
        ico = favIcon[url];
        aurl = document.createElement('a');
        aurl.href = url;
        auri = document.createElement('a');
        auri.href = uri;
        if (auri.hostname === aurl.hostname) {
          icon = ico;
          return icon;
        }
      }
    }
    return icon;
  };
})(this);

this.getEachDay = (function(_this) {
  return function(obj) {
    var date, itms;
    for (date in obj) {
      itms = obj[date];
      _this.date = date;
      _this.itms = itms;
    }
    return _this.itms;
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
    if (moment(_this.date, 'YYYYMMDD').isSame(today)) {
      datum = 'Today ' + datum;
    }
    if (moment(_this.date, 'YYYYMMDD').isSame(yday)) {
      datum = 'Yesterday ' + datum;
    }
    if (moment(_this.date, 'YYYYMMDD').isSame(weekAgo)) {
      datum = 'A Week Ago ' + datum;
    }
    return datum;
  };
})(this);

this.deleteDate = (function(_this) {
  return function(e) {
    var date, hist, i, key, obj, _i, _len;
    hist = $.jStorage.get('bp.history');
    for (i = _i = 0, _len = hist.length; _i < _len; i = ++_i) {
      key = hist[i];
      for (date in key) {
        obj = key[date];
        if (date === _this.date) {
          hist.splice(i, 1);
        }
      }
    }
    $.jStorage.set('bp.history', hist);
    return _this.unmount();
  };
})(this);

this["delete"] = (function(_this) {
  return function(e) {
    var hist, history, idx, itm, thatDay, _i, _len;
    hist = $.jStorage.get('bp.history');
    itm = e.item;
    idx = _this.itms.indexOf(itm);
    history = $.jStorage.get('bp.history');
    for (_i = 0, _len = history.length; _i < _len; _i++) {
      hist = history[_i];
      if (thatDay = hist[_this.date]) {
        thatDay.splice(idx, 1);
        break;
      }
    }
    $.jStorage.set('bp.history', history);
    if (thatDay.length === 0) {
      return _this.deleteDate();
    }
  };
})(this);

});
