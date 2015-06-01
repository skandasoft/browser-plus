var jQ, href, ipc;

if (window['browser-plus'] == null) {
  ipc = require('ipc');
  href = location.href;
  if (href.includes('data:text/html,')) {
    href = null;
  }
  ipc.sendToHost('startup', {
    href: href,
    title: document.title
  });
  jQ = jQuery.noConflict();
  jQ(function() {
    var jQselector, bp, style;
    CSSUtilities.define('async', false);
    CSSUtilities.init();
    if (jQ('body').find('#bp-selector').length !== 0) {
      return;
    }
    bp = window['browser-plus'] || (window['browser-plus'] = {});
    bp.selector = jQ("<div id=\"bp-selector\">\n    <div id=\"bp-selector-top\"></div>\n    <div id=\"bp-selector-left\"></div>\n    <div id=\"bp-selector-right\"></div>\n    <div id=\"bp-selector-bottom\"></div>\n</div>");
    style = "<style type='text/css'>\n  #bp-selector-top, #bp-selector-bottom {\n	background: blue;\n	height:3px;\n	position: fixed;o\n	transition:all 300ms ease;\n  z-index:9999;\n}\n#bp-selector-left, #bp-selector-right {\n	background: blue;\n	width:3px;\n	position: fixed;\n	transition:all 300ms ease;\n  z-index:9999;\n}\n\n.n{\n -webkit-transform: scale(3) translateX(100px)\n}\n</style>";
    jQ('head').append(style);
    jQselector = jQ('body').append(bp.selector);
    bp.selector.hide();
    bp.clicked = false;
    bp.elements = {
      top: jQselector.find('#bp-selector-top'),
      left: jQselector.find('#bp-selector-left'),
      right: jQselector.find('#bp-selector-right'),
      bottom: jQselector.find('#bp-selector-bottom')
    };
    bp.click = function(evt) {
      var count, css, target, traverse;
      bp = window['browser-plus'];
      if (bp.clicked) {
        jQ(document).on('mousemove', bp.mouseMove);
      } else {
        jQ(document).off('mousemove', bp.mouseMove);
        count = 100;
        css = {};
        target = jQ(bp.target[0].outerHTML);
        css["bp-" + count] = CSSUtilities.getCSSProperties(bp.target[0], "screen");
        target[0].className += " bp-" + count;
        traverse = function(root) {
          var ele, orgEle, _i, _len, _ref, _results;
          _ref = root.children();
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            ele = _ref[_i];
            orgEle = jQ(bp.target[0]).find(ele.nodeName).filter(function() {
              return this.outerHTML === ele.outerHTML;
            });
            count += 1;
            ele.className = ele.className + (" bp-" + count);
            css["bp-" + count] = CSSUtilities.getCSSProperties(orgEle[0], "screen");
            _results.push(traverse(jQ(ele)));
          }
          return _results;
        };
        traverse(target);
        this.html = target[0].outerHTML;
        this.css = css;
        ipc.sendToHost('selection', {
          css: this.css,
          html: this.html
        });
      }
      bp.clicked = !bp.clicked;
      return false;
    };
    bp.mouseMove = function(evt) {
      var jQtarget, elements, targetHeight, targetOffset, targetWidth;
      if (evt.target.id.indexOf("bp-selector") !== -1 || evt.target.tagName === "BODY" || evt.target.tagName === "HTML") {
        return;
      }
      bp = window['browser-plus'];
      bp.target = jQtarget = jQ(evt.target);
      targetOffset = jQtarget[0].getBoundingClientRect();
      targetHeight = targetOffset.height;
      targetWidth = targetOffset.width;
      elements = bp.elements;
      elements.top.css({
        left: targetOffset.left - 4,
        top: targetOffset.top - 4,
        width: targetWidth + 5
      });
      elements.bottom.css({
        top: targetOffset.top + targetHeight + 1,
        left: targetOffset.left - 3,
        width: targetWidth + 4
      });
      elements.left.css({
        left: targetOffset.left - 5,
        top: targetOffset.top - 4,
        height: targetHeight + 8
      });
      return elements.right.css({
        left: targetOffset.left + targetWidth + 1,
        top: targetOffset.top - 4,
        height: targetHeight + 8
      });
    };
    ipc.on('select', function() {
      bp = window['browser-plus'];
      bp.selector.show();
      jQ(document).mousemove(bp.mouseMove);
      return jQ(document).click(bp.click);
    });
    ipc.on('deselect', function() {
      bp = window['browser-plus'];
      bp.selector.hide();
      jQ(document).off('mousemove', bp.mouseMove);
      return jQ(document).off('click', bp.click);
    });
    ipc.on('selection', function() {
      var css, div, doc, html, rn, selection, styl, traverse;
      html = null;
      css = [];
      selection = window.getSelection();
      if (selection.rangeCount > 0) {
        rn = selection.getRangeAt(0);
        if (!rn) {
          return ipc.sendToHost('preview', {
            url: location.href
          });
        }
        div = document.createElement('div');
        div.appendChild(rn.cloneContents());
        doc = jQ(rn.commonAncestorContainer);
        styl = document.defaultView.getComputedStyle;
        css.push(styl(doc, null));
        traverse = function(div) {
          var docEle, ele, key, val, _i, _len, _ref, _ref1, _results;
          _ref = div.children;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            ele = _ref[_i];
            docEle = doc.find(ele.nodeName).filter(function() {
              return this.outerHTML === ele.outerHTML;
            });
            if (docEle.length) {
              _ref1 = styl(docEle[0], null);
              for (key in _ref1) {
                val = _ref1[key];
                ele.style[key] = val;
              }
            }
            _results.push(traverse(ele));
          }
          return _results;
        };
        traverse(div);
      }
      return ipc.sendToHost('selection', {
        css: css,
        html: div.innerHTML
      });
    });
    return ipc.on('unclick', function() {
      jQ('a').css({
        'cursor': 'text'
      });
      return jQ('a').click(function() {
        return false;
      });
    });
  });
  ipc.on('updHist', function(hist) {
    window.histTag.opts.hist = hist;
    return window.histTag.update();
  });
  ipc.on('updFav', function(fav) {
    window.favTag.opts.fav = fav;
    return window.favTag.update();
  });
  ipc.on('historyPage', function(hist, fav) {
    window.favTag = riot.mount('fav', {
      fav: fav
    })[0];
    return window.histTag = riot.mount('hist', {
      hist: hist
    })[0];
  });
  ipc.on('clearHist', function() {
    window.histTag.unmount(false);
    return window.histTag = riot.mount('hist', []);
  });
}
