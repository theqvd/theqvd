var asciidoc = {  // Namespace.
    /////////////////////////////////////////////////////////////////////
    // Table Of Contents generator
    /////////////////////////////////////////////////////////////////////

    /* Author: Mihai Bazon, September 2002
     * http://students.infoiasi.ro/~mishoo
     *
     * Table Of Content generator
     * Version: 0.4
     *
     * Feel free to use this script under the terms of the GNU General Public
     * License, as long as you do not remove or alter this notice.
     */

     /* modified by Troy D. Hanson, September 2006. License: GPL */
     /* modified by Stuart Rackham, 2006, 2009. License: GPL */

    // toclevels = 1..4.
    toc: function (toclevels) {

      function getText(el) {
        var text = "";
        for (var i = el.firstChild; i != null; i = i.nextSibling) {
          if (i.nodeType == 3 /* Node.TEXT_NODE */) // IE doesn't speak constants.
            text += i.data;
          else if (i.firstChild != null)
            text += getText(i);
        }
        return text;
      }

      function TocEntry(el, text, toclevel) {
        this.element = el;
        this.text = text;
        this.toclevel = toclevel;
      }

      function tocEntries(el, toclevels) {
        var result = new Array;
        var re = new RegExp('[hH]([1-'+(toclevels+1)+'])');
        // Function that scans the DOM tree for header elements (the DOM2
        // nodeIterator API would be a better technique but not supported by all
        // browsers).
        var iterate = function (el) {
          for (var i = el.firstChild; i != null; i = i.nextSibling) {
            if (i.nodeType == 1 /* Node.ELEMENT_NODE */) {
              var mo = re.exec(i.tagName);
              if (mo && (i.getAttribute("class") || i.getAttribute("className")) != "float") {
                result[result.length] = new TocEntry(i, getText(i), mo[1]-1);
              }
              iterate(i);
            }
          }
        }
        iterate(el);
        return result;
      }

      var toc = document.getElementById("toc");
      if (!toc) {
        return;
      }

      // Delete existing TOC entries in case we're reloading the TOC.
      var tocEntriesToRemove = [];
      var i;
      for (i = 0; i < toc.childNodes.length; i++) {
        var entry = toc.childNodes[i];
        if (entry.nodeName.toLowerCase() == 'div'
         && entry.getAttribute("class")
         && entry.getAttribute("class").match(/^toclevel/))
          tocEntriesToRemove.push(entry);
      }
      for (i = 0; i < tocEntriesToRemove.length; i++) {
        toc.removeChild(tocEntriesToRemove[i]);
      }

      // Rebuild TOC entries.
      var entries = tocEntries(document.getElementById("content"), toclevels);
      for (var i = 0; i < entries.length; ++i) {
        var entry = entries[i];
        if (entry.element.id == "")
          entry.element.id = "_toc_" + i;
        var a = document.createElement("a");
        a.href = "#" + entry.element.id;
        a.appendChild(document.createTextNode(entry.text));
        var div = document.createElement("div");
        div.appendChild(a);
        div.className = "toclevel" + entry.toclevel;
        toc.appendChild(div);
      }
      if (entries.length == 0)
        toc.parentNode.removeChild(toc);
    }
}