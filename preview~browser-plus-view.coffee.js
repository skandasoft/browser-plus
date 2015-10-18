var $, BrowserPlusView, CompositeDisposable, URL, View, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

CompositeDisposable = require('atom').CompositeDisposable;

_ref = require('atom-space-pen-views'), View = _ref.View, $ = _ref.$;

URL = require('url');

module.exports = BrowserPlusView = (function(_super) {
  __extends(BrowserPlusView, _super);

  function BrowserPlusView(model) {
    this.model = model;
    this.deActivateSelection = __bind(this.deActivateSelection, this);
    this.subscriptions = new CompositeDisposable;
    this.model.view = this;
    BrowserPlusView.__super__.constructor.apply(this, arguments);
  }

  BrowserPlusView.content = function(params) {
    var clientJS, resources, src, srcdir, url;
    srcdir = atom.packages.getActivePackage('browser-plus').path;
    if ((url = params.uri).indexOf('browser-plus://history') >= 0) {
      resources = "" + (atom.packages.getActivePackage('browser-plus').path) + "/resources/";
      url = "file://" + resources + "history.html";
    }
    if (params.src) {
      src = params.src.replace(/"/g, '&quot;');
      if (src.includes("data:text/html,")) {
        url = src;
      } else {
        url = "data:text/html, " + src;
      }
    }
    clientJS = "console.log('hello');";
    return this.div({
      "class": 'browser-plus'
    }, (function(_this) {
      return function() {
        _this.div({
          "class": 'uri native-key-bindings'
        }, function() {
          _this.div({
            "class": 'nav-btns-left'
          }, function() {
            _this.span({
              id: 'back',
              "class": 'mega-octicon octicon-arrow-left',
              outlet: 'back'
            });
            _this.span({
              id: 'forward',
              "class": 'mega-octicon octicon-arrow-right',
              outlet: 'forward'
            });
            _this.span({
              id: 'refresh',
              "class": 'mega-octicon octicon-sync',
              outlet: 'refresh'
            });
            _this.span({
              id: 'select',
              "class": 'mega-octicon octicon-eye',
              outlet: 'select'
            });
            _this.span({
              id: 'history',
              "class": 'mega-octicon octicon-book',
              outlet: 'history'
            });
            return _this.span({
              id: 'fav',
              "class": 'mega-octicon octicon-star',
              outlet: 'fav'
            });
          });
          return _this.div({
            "class": 'nav-btns'
          }, function() {
            _this.div({
              "class": 'nav-btns-right'
            }, function() {
              _this.span({
                id: 'print',
                "class": 'icon-browser-pluss icon-print',
                outlet: 'print'
              });
              _this.span({
                id: 'thumbs',
                "class": 'mega-octicon octicon-thumbsup',
                outlet: 'thumbs'
              });
              _this.span({
                id: 'live',
                "class": 'mega-octicon octicon-zap',
                outlet: 'live'
              });
              return _this.span({
                id: 'devtool',
                "class": 'mega-octicon octicon-tools',
                outlet: 'devtool'
              });
            });
            return _this.div({
              "class": 'input-uri'
            }, function() {
              return _this.input({
                "class": "native-key-bindings",
                type: 'text',
                id: 'uri',
                outlet: 'uri',
                value: "" + params.uri
              });
            });
          });
        });
        if (atom.config.get('browser-plus.node')) {
          return _this.tag('webview', {
            "class": "native-key-bindings",
            outlet: 'htmlv',
            nodeintegeration: 'on',
            plugins: 'on',
            src: "" + url,
            disablewebsecurity: 'on',
            allowfileaccessfromfiles: 'on',
            allowPointerLock: 'on'
          });
        } else {
          return _this.tag('webview', {
            "class": "native-key-bindings",
            outlet: 'htmlv',
            preload: "file:///" + srcdir + "/resources/bp-client.js",
            plugins: 'on',
            src: "" + url,
            disablewebsecurity: 'on',
            allowfileaccessfromfiles: 'on',
            allowPointerLock: 'on'
          });
        }
      };
    })(this));
  };

  BrowserPlusView.prototype.initialize = function() {
    this.subscriptions.add(atom.tooltips.add(this.back, {
      title: 'Back'
    }));
    this.subscriptions.add(atom.tooltips.add(this.forward, {
      title: 'Forward'
    }));
    this.subscriptions.add(atom.tooltips.add(this.refresh, {
      title: 'Refresh'
    }));
    this.subscriptions.add(atom.tooltips.add(this.select, {
      title: 'Select'
    }));
    this.subscriptions.add(atom.tooltips.add(this.history, {
      title: 'View Hist/Fav-ctr+h'
    }));
    this.subscriptions.add(atom.tooltips.add(this.fav, {
      title: 'Favoritize'
    }));
    this.subscriptions.add(atom.tooltips.add(this.live, {
      title: 'Live'
    }));
    this.subscriptions.add(atom.tooltips.add(this.devtool, {
      title: 'Dev Tools-f12'
    }));
    this.liveOn = false;
    this.subscriptions.add(atom.tooltips.add(this.thumbs, {
      title: 'Preview'
    }));
    this.element.onkeydown = (function(_this) {
      return function() {
        return _this.showDevTool(arguments);
      };
    })(this);
    if (this.model.uri.indexOf('browser-plus://history') >= 0) {
      this.hist = true;
      this.model.browserPlus.histView = this;
    } else {
      Array.observe(this.model.browserPlus.fav, (function(_this) {
        return function(ele) {
          return _this.checkFav();
        };
      })(this));
    }
    this.htmlv[0].addEventListener("permissionrequest", function(e) {
      return e.request.allow();
    });
    this.htmlv[0].addEventListener("console-message", (function(_this) {
      return function(e) {
        var uri, _ref1;
        if (e.message.includes('~browser-plus-href~')) {
          console.log(e.message);
          uri = e.message.replace('~browser-plus-href~', '');
          if (uri) {
            _this.uri.val(uri);
            _this.model.uri = uri;
          }
          _this.select.removeClass('active');
          _this.deActivateSelection();
          _this.live.toggleClass('active', _this.liveOn);
          if (!_this.liveOn) {
            if ((_ref1 = _this.liveSubscription) != null) {
              _ref1.dispose();
            }
          }
          _this.checkNav();
          _this.checkFav();
          return _this.addHistory();
        }
      };
    })(this));
    this.htmlv[0].addEventListener("page-favIcon-updated", (function(_this) {
      return function(e) {
        var icon, style;
        icon = e.favIcons[0];
        _this.model.iconName = Math.floor(Math.random() * 10000);
        _this.model.updateIcon();
        style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = ".title.icon.icon-" + _this.model.iconName + " {\n  background-size: 16px 16px;\n  background-repeat: no-repeat;\n  padding-left: 20px;\n  background-image: url('" + icon + "');\n  background-position-y: 5px;\n}";
        return document.getElementsByTagName('head')[0].appendChild(style);
      };
    })(this));
    this.htmlv[0].addEventListener("page-title-set", (function(_this) {
      return function(e) {
        return _this.model.setTitle(e.title);
      };
    })(this));
    this.htmlv[0].addEventListener("ipc-message", (function(_this) {
      return function(evt) {
        var date, hist, uri, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
        switch (evt.channel) {
          case 'selection':
            _this.htmlSrc = (_ref1 = evt.args[0]) != null ? _ref1.html : void 0;
            return _this.css = (_ref2 = evt.args[0]) != null ? _ref2.css : void 0;
          case 'clearHist':
            _this.model.browserPlus.history = [];
            return (_ref3 = _this.model.browserPlus.histView) != null ? _ref3.htmlv[0].send('clearHist') : void 0;
          case 'remHistDate':
            hist = _this.model.browserPlus.history;
            date = Object.keys(evt.args[0])[0];
            _this.model.browserPlus.history = hist.filter(function(ele) {
              if (ele[date]) {
                return false;
              } else {
                return true;
              }
            });
            return (_ref4 = _this.model.browserPlus.histView) != null ? _ref4.htmlv[0].send('updHist', _this.model.browserPlus.history) : void 0;
          case 'remHist':
            hist = _this.model.browserPlus.history;
            date = new Date(evt.args[0].date).toISOString().slice(0, 10);
            hist.forEach(function(ele, idx) {
              var _ref5;
              if (!ele[date]) {
                return;
              }
              ele[date] = (_ref5 = ele[date]) != null ? _ref5.filter(function(entry) {
                if (entry.uri === evt.args[0].uri && entry.date === evt.args[0].date) {
                  return false;
                }
                return true;
              }) : void 0;
              if (ele[date].length === 0) {
                return hist.splice(idx, 1);
              }
            });
            return (_ref5 = _this.model.browserPlus.histView) != null ? _ref5.htmlv[0].send('updHist', hist) : void 0;
          case 'remFav':
            return _this.removeFav(evt.args[0]);
          case 'startup':
            uri = evt.args[0].href;
            if (uri && !_this.model.uri.includes('browser-plus:')) {
              _this.uri.val(uri);
              _this.model.uri = uri;
            }
            _this.model.setTitle(evt.args[0].title);
            _this.select.removeClass('active');
            _this.deActivateSelection();
            _this.live.toggleClass('active', _this.liveOn);
            if (!_this.liveOn) {
              if ((_ref6 = _this.liveSubscription) != null) {
                _ref6.dispose();
              }
            }
            _this.checkNav();
            if (_this.hist) {
              return _this.htmlv[0].send('historyPage', _this.model.browserPlus.history, _this.model.browserPlus.fav);
            } else {
              _this.checkFav();
              _this.addHistory();
              return (_ref7 = _this.model.browserPlus.histView) != null ? _ref7.htmlv[0].send('addHistory', _this.model.browserPlus.history) : void 0;
            }
        }
      };
    })(this));
    this.devtool.on('click', (function(_this) {
      return function(evt) {
        return _this.toggleDevTool();
      };
    })(this));
    this.print.on('click', (function(_this) {
      return function(evt) {
        return _this.htmlv[0].print();
      };
    })(this));
    this.pdf.on('click', (function(_this) {
      return function(evt) {
        return _this.htmlv[0].printToPDF({}, function(data, err) {
          debugger;
        });
      };
    })(this));
    this.live.on('click', (function(_this) {
      return function(evt) {
        if (_this.model.src) {
          return;
        }
        _this.liveOn = !_this.liveOn;
        _this.live.toggleClass('active', _this.liveOn);
        if (_this.liveOn) {
          _this.htmlv[0].executeJavaScript("location.href = '" + _this.model.uri + "'");
          _this.liveSubscription = new CompositeDisposable;
          _this.liveSubscription.add(atom.workspace.observeTextEditors(function(editor) {
            return _this.liveSubscription.add(editor.onDidSave(function() {
              var timeout;
              timeout = atom.config.get('browser-plus.live');
              return setTimeout(function() {
                var _ref1, _ref2;
                return (_ref1 = _this.htmlv) != null ? (_ref2 = _ref1[0]) != null ? typeof _ref2.executeJavaScript === "function" ? _ref2.executeJavaScript("location.href = '" + _this.model.uri + "'") : void 0 : void 0 : void 0;
              }, timeout);
            }));
          }));
          return _this.model.onDidDestroy(function() {
            return _this.liveSubscription.dispose();
          });
        } else {
          return _this.liveSubscription.dispose();
        }
      };
    })(this));
    this.select.on('click', (function(_this) {
      return function(evt) {
        if (!atom.config.get('browser-plus.preview')) {
          alert('change browser-plus config to allow preview');
          return;
        }
        _this.select.toggleClass('active');
        return _this.deActivateSelection();
      };
    })(this));
    this.thumbs.on('click', (function(_this) {
      return function(evt) {
        var className, cssText, html, key, styl, val, _ref1;
        if (!atom.config.get('browser-plus.preview')) {
          alert('change browser-plus config to allow preview');
          return;
        }
        if (!_this.htmlSrc) {
          return;
        }
        cssText = "";
        _ref1 = _this.css;
        for (className in _ref1) {
          styl = _ref1[className];
          cssText += " ." + className + "{  ";
          for (key in styl) {
            val = styl[key];
            cssText += "" + key + ": " + val + ";  ";
          }
          cssText += " }  ";
        }
        html = "data:text/html,\n<html>\n  <head>\n    <meta bp-uri='browser-plus://preview'>\n    <base href='" + (_this.uri.val()) + "'>\n    <style type='text/css'>\n      " + cssText + "\n    </style>\n  </head>\n  <body>\n     " + (_this.htmlSrc.replace(/"/g, '\'')) + "\n  </body>\n</html>";
        return atom.workspace.open('browser-plus://preview', {
          split: 'left',
          searchAllPanes: true,
          src: html
        });
      };
    })(this));
    this.fav.on('click', (function(_this) {
      return function(evt) {
        var delCount, favs, _ref1;
        if (_this.model.src) {
          return;
        }
        if (_this.htmlv[0].getUrl().includes('data:text/html,')) {
          return;
        }
        if (_this.model.uri.includes('browser-plus:')) {
          return;
        }
        favs = _this.model.browserPlus.fav;
        if (_this.fav.hasClass('active')) {
          _this.removeFav(_this.model);
        } else {
          favs.push({
            uri: _this.model.uri
          });
          delCount = favs.length - atom.config.get('browser-plus.fav');
          if (delCount > 0) {
            favs.splice(0, delCount);
          }
        }
        _this.fav.toggleClass('active');
        return (_ref1 = _this.model.browserPlus.histView) != null ? _ref1.htmlv[0].send('updFav', _this.model.browserPlus.fav) : void 0;
      };
    })(this));
    this.htmlv[0].addEventListener('new-window', function(e) {
      return atom.workspace.open(e.url, {
        split: 'left',
        searchAllPanes: true
      });
    });
    this.htmlv[0].addEventListener("did-start-loading", (function(_this) {
      return function() {
        _this.htmlv[0].shadowRoot.firstChild.style.height = '95%';
        if (atom.config.get('browser-plus.node')) {
          return _this.startupCheck();
        }
      };
    })(this));
    this.history.on('click', (function(_this) {
      return function(evt) {
        return atom.workspace.open('browser-plus://history', {
          split: 'left',
          searchAllPanes: true
        });
      };
    })(this));
    this.back.on('click', (function(_this) {
      return function(evt) {
        if (_this.htmlv[0].canGoBack() && $( this).hasClass('active')) {
          return _this.htmlv[0].goBack();
        }
      };
    })(this));
    this.forward.on('click', (function(_this) {
      return function(evt) {
        if (_this.htmlv[0].canGoForward() && $( this).hasClass('active')) {
          return _this.htmlv[0].goForward();
        }
      };
    })(this));
    this.uri.on('keypress', (function(_this) {
      return function(evt) {
        var localhostPattern, url, urls, _ref1, _ref2;
        if (evt.which === 13) {
          urls = URL.parse( this.value);
          url =  this.value;
          if (url.indexOf(' ') >= 0) {
            url = "http://www.google.com/search?as_q=" + url;
          } else {
            localhostPattern = /^(http:\/\/)?localhost/i;
            if (url.search(localhostPattern) < 0 && url.indexOf('.') < 0) {
              url = "http://www.google.com/search?as_q=" + url;
            } else {
              if ((_ref1 = urls.protocol) === 'http' || _ref1 === 'https' || _ref1 === 'file:') {
                if (urls.protocol === 'file:') {
                  url = url.replace(/\\/g, "/");
                } else {
                  url = URL.format(urls);
                }
              } else if (url.indexOf('localhost') !== -1) {
                url = url.replace(localhostPattern, 'http://127.0.0.1');
              } else {
                urls.protocol = 'http';
                url = URL.format(urls);
              }
            }
          }
          _this.select.removeClass('active');
          _this.deActivateSelection();
          _this.liveOn = false;
          _this.live.toggleClass('active', _this.liveOn);
          if (!_this.liveOn) {
            if ((_ref2 = _this.liveSubscription) != null) {
              _ref2.dispose();
            }
          }
          _this.uri.val(url);
          _this.model.uri = url;
          return _this.htmlv.attr('src', url);
        }
      };
    })(this));
    return this.refresh.on('click', (function(_this) {
      return function(evt) {
        return _this.htmlv[0].executeJavaScript("location.href = '" + _this.model.uri + "'");
      };
    })(this));
  };

  BrowserPlusView.prototype.showDevTool = function(evt) {
    if (evt[0].keyIdentifier === "F12") {
      return this.toggleDevTool();
    }
  };

  BrowserPlusView.prototype.deActivateSelection = function() {
    if (this.select.hasClass('active')) {
      return this.htmlv[0].send('select');
    } else {
      return this.htmlv[0].send('deselect');
    }
  };

  BrowserPlusView.prototype.removeFav = function(favorite) {
    var favr, idx, _i, _len, _ref1, _ref2;
    _ref1 = this.model.browserPlus.fav;
    for (idx = _i = 0, _len = _ref1.length; _i < _len; idx = ++_i) {
      favr = _ref1[idx];
      if (favr.uri === favorite.uri) {
        this.model.browserPlus.fav.splice(idx, 1);
      }
    }
    return (_ref2 = this.model.browserPlus.histView) != null ? _ref2.htmlv[0].send('updFav', this.model.browserPlus.fav) : void 0;
  };

  BrowserPlusView.prototype.setSrc = function(text) {
    return this.htmlv[0].src = "data:text/html," + text;
  };

  BrowserPlusView.prototype.checkFav = function() {
    var favr, _i, _len, _ref1, _results;
    if (this.model.browserPlus.fav.length === 0) {
      this.fav.removeClass('active');
    }
    _ref1 = this.model.browserPlus.fav;
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      favr = _ref1[_i];
      if (favr.uri === this.model.uri) {
        _results.push(this.fav.addClass('active'));
      } else {
        _results.push(this.fav.removeClass('active'));
      }
    }
    return _results;
  };

  BrowserPlusView.prototype.toggleDevTool = function() {
    var open;
    open = this.htmlv[0].isDevToolsOpened();
    if (open) {
      this.htmlv[0].closeDevTools();
    } else {
      this.htmlv[0].openDevTools();
    }
    return $(this.devtool).toggleClass('active', !open);
  };

  BrowserPlusView.prototype.startupCheck = function() {
    if (!atom.config.get('browser-plus.preview')) {
      return;
    }
    return process.nextTick((function(_this) {
      return function() {
        var _ref1, _ref2;
        if ((_ref1 = _this.htmlv) != null ? _ref1[0] : void 0) {
          if ((_ref2 = _this.htmlv[0]) != null ? typeof _ref2.isWaitingForResponse === "function" ? _ref2.isWaitingForResponse() : void 0 : void 0) {
            return setTimeout(function() {
              return _this.startupCheck();
            }, 100);
          } else {
            return setTimeout(function() {
              var _ref3, _ref4, _ref5, _ref6;
              if ((_ref3 = _this.htmlv[0]) != null) {
                _ref3.executeJavaScript(_this.model.browserPlus.CSSjs);
              }
              if ((_ref4 = _this.htmlv[0]) != null) {
                _ref4.executeJavaScript(_this.model.browserPlus.Selectorjs);
              }
              if ((_ref5 = _this.htmlv[0]) != null) {
                _ref5.executeJavaScript(_this.model.browserPlus.JQueryjs);
              }
              return (_ref6 = _this.htmlv[0]) != null ? _ref6.executeJavaScript(_this.model.browserPlus.js) : void 0;
            }, 100);
          }
        }
      };
    })(this));
  };

  BrowserPlusView.prototype.checkNav = function() {
    $(this.forward).toggleClass('active', this.htmlv[0].canGoForward());
    $(this.back).toggleClass('active', this.htmlv[0].canGoBack());
    if (this.htmlv[0].canGoForward()) {
      if (this.clearForward) {
        $(this.forward).toggleClass('active', false);
        return this.clearForward = false;
      } else {
        return $(this.forward).toggleClass('active', true);
      }
    }
  };

  BrowserPlusView.prototype.addHistory = function() {
    var histToday, history, obj, today, todays, url, yyyymmdd;
    url = this.htmlv[0].getUrl();
    if (url.includes('browser-plus://') || url.includes('data:text/html,')) {
      return;
    }
    yyyymmdd = function() {
      var date, dd, mm, yyyy;
      date = new Date();
      yyyy = date.getFullYear().toString();
      mm = (date.getMonth() + 1).toString();
      dd = date.getDate().toString();
      return yyyy + (mm[1] ? mm : '0' + mm[0]) + (dd[1] ? dd : '0' + dd[0]);
    };
    today = yyyymmdd();
    history = this.model.browserPlus.history;
    if (!(history || (history.length = 0))) {
      return;
    }
    todays = history.filter(function(ele, idx, arr) {
      if (Object.keys(ele)[0] === today) {
        return true;
      }
    });
    if (todays.length === 0) {
      histToday = [];
      obj = {};
      obj[today] = histToday;
      history.unshift(obj);
    } else {
      histToday = todays[0][today];
    }
    return histToday.unshift({
      date: new Date().toString(),
      uri: this.uri.val()
    });
  };

  BrowserPlusView.prototype.getTitle = function() {
    return this.model.getTitle();
  };

  return BrowserPlusView;

})(View);
