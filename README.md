# __**BrowserPlus ~ Real Browser in ATOM!!**__

## Here are some feature...

1. Live Preview
2. Back/Forward Button
3. DevTool
4. Refresh
5. History
6. Favorites
7. Simple Plugin Framework - Jquery/ContextMenu based.

-![Browser-Plus](https://raw.github.com/skandasoft/browser-plus/master/browser.gif)



## __FAQ__

0. __I have problem loading this package?__

  on your command prompt for atom directory, try uninstalling the package and reinstalling it

  >   apm uninstall browser-plus

  >   apm install browser-plus

  if there is package dependency issue(jquery.autocomplete.js no found error messages etc) try

  >   delete the jquery-ui directory under node_modules and
  >   npm install --> in the browser-plus directory. This will install all dependency
  >   
  >   if you still have issues with jquery.autocomplete.
  >   apm rebuild-module-cache


2. __How to open browser in atom?__

   ctrl+shift+p(cmd+shift+p) Browser Plus: Open. It opens the home page(maintained in the settings) or http://www.google.com.

3. __How to open the current file in the brower-plus?__

   ctrl+shift+p(cmd+shift+p) Browser Plus: OpenCurrent

4. __Is it possible to hide the URL Bar?__

   Yes. ctrl+shift+p(cmd+shift+p) Browser Plus View: toggleURLBar/F11. You need to have the browser highlighted when performing the action.

5. __How to Favoritize/UnFavaritize an URL?__

   On the browser urlbar click on the star to favoritize it. And click on the star if you need to UnFavaritize it/ to remove from the favoritized dropdown.

6. __How to View favoritized URLs?__

   ctrl+shift+p(cmd+shift+p) Browser Plus: Fav. This would open an dropdown selection of Favoritized URL. Or click on the down arrow next to the url bar on the left side.

7. __How to View Browser Plus History?__

   ctrl+shift+p(cmd+shift+p) Browser Plus: History/click on the button icon on the url toolbar. Opens a browser window with the URLs browsed. It is possible to delete the entire history by clicking clear history button in the webpage/delete individual entry by clicking on trash can/delete dates by clicking on the trash can by the side of dates.

8. __How to  open developer tool for the browser?__

   Press the function key f12/on the clicking on the settings icon on the webpage. Jquery is added for free if it is not available. So you can perform DOM activities.

9. __How to show live changes(as soon as you save file) to show up as we are  viewing a file?__

   Press the lighting icon. It is a toggle button ie., same button can used on switching on to live view/stop live view. Any save of any window would refresh the window. So css file window/js file window saved would be reflected on save.

10. __Is it possible to print the webpage?__

    Yes. Click on the print icon.

11. __Is BrowserPlus used in any other packages?__

    [**Navigate**][1] ( http://atom.io/packages/navigate )

     This package help in navigating/links on html file. when you press f2 on a html filename it opens up the browser. There are other keys you can use. Here are some of the default key combinations that are available now when Navigate Package is installed along with BrowserPlus

     ```javascript
     'F1':
       title: 'F1 - DevDocs Help'
       type: 'string'
       default: 'http://devdocs.io/#q=&searchterm'

     'CTRL-F1':
       title: 'Ctrl-F1 - Google Help'
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
     ```
     __Checkout [Navigate][1]__

12. __Can I add custom key combinations to my weburls?__

     Yes!! you can.The word under cursor is available in the field searchterm. For eg when F1 is pressed, help for that keyword, are provided through [devdocs][2] using the config

     ``` javascript
      default: 'http://devdocs.io/#q=&searchterm'
     ```

     __Checkout [Navigate][1]__

13. __Can I preview jsp/php/express/django and other frameworks or from localhost in BrowserPlus?__

    Yes. Absolutely. You can install this plugin called __[PP][3](http://atom.io/packages/pp)__. This is used to preview the files. Check more info @ __[PP][8]__

14. __Can I get hyperLive(show html changes as I type) preview of the current file?__

    Previews can be done using __PP__ [preview plus][3]. This Plugin user BrowserPlus to visualize html file and allows for live/hyperLive options + able to preview in different formats.

15. __How can I call BrowserPlus from my plugin?__

    atom.workspace.open following by url and you can pass options just as you would do to open a file using atom. If you file starts with http,https or localhost it would automatically open in the browser-plus window.

16. __Is there a way enhance the functionality of BrowserPlus/Plugin system for BrowserPlus?__

    you can build a plugin for browserplus. It is very simple. Checkout [browser-plus-zoom][5] or [browser-plus-open-new-window][9] or [browser-plus-block][6]. The naming convention for the plugin is browser-plus-yourpluginname.
    browser-plus provides a service called consumeAddPlugin which can be put under your plugin
    ``` javascript
      "consumedServices": {
        "browser-plus": {
          "versions": {
            ">=0.0.0": "consumeAddPlugin"
          }
        }
      }
    ```
    in order to add your plugin to browser-plus pass the details in json format

    "onInit" --> initializes the browser with your script that will be loaded once the browser is opened

    "js" --> load an/array of javascripts both from your resources directory under your package/ from cdns

    "css" --> load an/array of css both from your resources directory under your package/ from cdns

    "menus" --> this can be a single object /array of object in the following format. The plugin can be displayed as context menu or accessed using key combinations.

    "menu-ctrlkey" --> use to invoke you plugin (it can be any key combination)

    "menu-fn" --> this is where the code for you plugin goes . for your convience jQuery is already loaded/notifyBar(https://github.com/dknight/jQuery-Notify-bar)/jStorage
     another plugin(http://www.jstorage.info/) is loaded.

    your function can be invoked using a key combination/from context menu. If you want it to be a context menu

    "name": "name of the menu"

    "selector": "for which the context menu would appear, can be multiple and be separated by ','"

    "selectorFilter": "a function which would return boolean. if for some reason you want some filter for the selector passed it can be done by sending boolean back"

    The best way make a plugin is copy the browser-plus-open-new-window/browser-plus-zoom and testing with your code.

    And you can do a PR on FAQ for browserplus to update your plugin details :).

17. __what browser-plus plugins are availble?__

    Look/search for browser-plus- for plugins. That will be the name convention for browserplus plugins.

    1. [browser-plus-zoom][5]
    2. [browser-plus-new-window][9]
    3. [browser-plus-find][7]
    4. [browser-plus-block][6]

    [browser-plus-zoom][5] helps to zoom in /out of the website(ctr++ or ctr--).

    [browser-plus-block][6] helps in maintaining particular websites from opening(self restraint)

    [browser-plus-find][7] helps in searching in the webpage.

    [browser-plus-new-window][9] open link in window/tab.

    Your next browser-plus plugin goes here....

18. __when opening search website like google/stackoverflow, I don't want multiple search browsers open. Is it possible to open in the same window?__

    Yes. check the setting for openInSameWindow.currently an array of website (google/stackoverflow)

19. __Calling BrowserPlus from contextMenu opens the home page. Can I make to open the current file?__

    Check the setting. 'Show Current File'. It is on by default.

20. __Can I block Youtube/any website? I get distracted while working.__

    yes. Check out [browser-plus-block][6](http://atom.io/packages/browser-plus-block) plugin.

21. __Can I use this browser like chrome to search on the toolbar?__

    Yes. As you type more than 2 character the dropdown of search results are shown from bing. Once you click on the result it searches in google and bring the results. if you don't choose any of it and press enter and if it is url it would go to that url.

22. __Can I view documentation/help for languages?___

    Yes. [Naviagate Plugin][1] does that. You can press f1 and it would show the devdocs help for the word under the cursor.Check [Navigate][1] for more info.

23. __How can I make browser-plus better?__

    PRs are welcome.Any issue reported would make this a better plugin. This FAQ can be updated with the browser-plus-plugins.


[1]: http://atom.io/packages/Navigate
[2]: http://devdocs.io
[3]: http://atom.io/packages/pp
[4]: http://atom.io/packages/open-in-browsers
[5]: http://atom.io/packages/browser-plus-zoom
[6]: http://atom.io/packages/browser-plus-block
[7]: http://atom.io/packages/browser-plus-find
[8]: http://atom.io/packages/pp/readme.md
[9]: http://atom.io/packages/pp/browser-plus-new-window
