# browser-plus package

Real Browser in ATOM

Here are some feature...

1. Live Preview
2. Back/Forward Button
3. DevTool
4. Refresh
5. History
6. Preview
7. Favorites..

-![Browser-Plus](https://raw.github.com/skandasoft/browser-plus/master/browser.gif)]

The real user of browser plus is with Navigate package--> https://atom.io/packages/navigate

This package help in navigating/links to html file. when you press f2 on a html file it opens up the browser
The browser url can be provided added in the config against the keys. The default key combinations are now

'F1':
  title: 'F1 - Help'
  type: 'string'
  default: 'http://devdocs.io/#q=&searchterm'

'CTRL-F1':
  title: 'F1 - Help'
  type: 'string'
  default: 'https://www.google.com/search?q=&searchterm'

'CTRL-F2':
  title: 'Stack Overflow Search'
  type: 'string'
  default: 'http://stackoverflow.com/search?q=&searchterm'

'CTRL-F3':
  title: 'AtomIO Search'
  type: 'string'
  default: 'https://atom.io/docs/api/search/latest?q=&searchterm'

  Custom keys(CTRL-F4) can be added against custom url. The word under cursor is available in the search term. So Currently any help for the key words, are provided through devdocs.

  Again there is expremental feature to provide selection and preview of the any dom element in the html page. This can be currently used against small dom element.
  -![Browser-Plus-Preview](https://raw.github.com/skandasoft/browser-plus/master/preview.gif)]
