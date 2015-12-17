visible_words = jQ('span.highlight:visible');
visible_words.each(function(i) {
  if (jQ(this).hasClass('browser-plus-find')) {
    if (i != 0) {
      jQ(visible_words[i-1]).removeClass('browser-plus-previous');
    } else {
      visible_words.last().removeClass('browser-plus-previous')
    }
    jQ(this).removeClass('browser-plus-find');
    jQ(this).addClass('browser-plus-previous');
    if (i == visible_words.length - 1) {
      jQ(visible_words[0]).addClass('browser-plus-find');
      jQ(visible_words[0]).removeClass('browser-plus-previous');
    } else {
      jQ(visible_words[i+1]).addClass('browser-plus-find');
    }
    return false;
  }
})
jQ('body').scrollTop(
   jQ('span.browser-plus-find').offset().top - jQ('body').offset().top - 50
)
