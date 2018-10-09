<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="generator" content="AsciiDoc 8.6.9">
<title>User manual of the QVD user portal</title>
<style type="text/css">
/* Shared CSS for AsciiDoc xhtml11 and html5 backends */

/* Default font. */
body {
  font-family: Georgia,serif;
}

/* Title font. */
h1, h2, h3, h4, h5, h6,
div.title, caption.title,
thead, p.table.header,
#toctitle,
#author, #revnumber, #revdate, #revremark,
#footer {
  font-family: Arial,Helvetica,sans-serif;
}

body {
  margin: 1em 5% 1em 5%;
}

a {
  color: blue;
  text-decoration: underline;
}
a:visited {
  color: fuchsia;
}

em {
  font-style: italic;
  color: navy;
}

strong {
  font-weight: bold;
  color: #083194;
}

h1, h2, h3, h4, h5, h6 {
  color: #527bbd;
  margin-top: 1.2em;
  margin-bottom: 0.5em;
  line-height: 1.3;
}

h1, h2, h3 {
  border-bottom: 2px solid silver;
}
h2 {
  padding-top: 0.5em;
}
h3 {
  float: left;
}
h3 + * {
  clear: left;
}
h5 {
  font-size: 1.0em;
}

div.sectionbody {
  margin-left: 0;
}

hr {
  border: 1px solid silver;
}

p {
  margin-top: 0.5em;
  margin-bottom: 0.5em;
}

ul, ol, li > p {
  margin-top: 0;
}
ul > li     { color: #aaa; }
ul > li > * { color: black; }

pre {
  padding: 0;
  margin: 0;
}

#author {
  color: #527bbd;
  font-weight: bold;
  font-size: 1.1em;
}
#email {
}
#revnumber, #revdate, #revremark {
}

#footer {
  font-size: small;
  border-top: 2px solid silver;
  padding-top: 0.5em;
  margin-top: 4.0em;
}
#footer-text {
  float: left;
  padding-bottom: 0.5em;
}
#footer-badges {
  float: right;
  padding-bottom: 0.5em;
}

#preamble {
  margin-top: 1.5em;
  margin-bottom: 1.5em;
}
div.imageblock, div.exampleblock, div.verseblock,
div.quoteblock, div.literalblock, div.listingblock, div.sidebarblock,
div.admonitionblock {
  margin-top: 1.0em;
  margin-bottom: 1.5em;
}
div.admonitionblock {
  margin-top: 2.0em;
  margin-bottom: 2.0em;
  margin-right: 10%;
  color: #606060;
}

div.content { /* Block element content. */
  padding: 0;
}

/* Block element titles. */
div.title, caption.title {
  color: #527bbd;
  font-weight: bold;
  text-align: left;
  margin-top: 1.0em;
  margin-bottom: 0.5em;
}
div.title + * {
  margin-top: 0;
}

td div.title:first-child {
  margin-top: 0.0em;
}
div.content div.title:first-child {
  margin-top: 0.0em;
}
div.content + div.title {
  margin-top: 0.0em;
}

div.sidebarblock > div.content {
  background: #ffffee;
  border: 1px solid #dddddd;
  border-left: 4px solid #f0f0f0;
  padding: 0.5em;
}

div.listingblock > div.content {
  border: 1px solid #dddddd;
  border-left: 5px solid #f0f0f0;
  background: #f8f8f8;
  padding: 0.5em;
}

div.quoteblock, div.verseblock {
  padding-left: 1.0em;
  margin-left: 1.0em;
  margin-right: 10%;
  border-left: 5px solid #f0f0f0;
  color: #777777;
}

div.quoteblock > div.attribution {
  padding-top: 0.5em;
  text-align: right;
}

div.verseblock > pre.content {
  font-family: inherit;
  font-size: inherit;
}
div.verseblock > div.attribution {
  padding-top: 0.75em;
  text-align: left;
}
/* DEPRECATED: Pre version 8.2.7 verse style literal block. */
div.verseblock + div.attribution {
  text-align: left;
}

div.admonitionblock .icon {
  vertical-align: top;
  font-size: 1.1em;
  font-weight: bold;
  text-decoration: underline;
  color: #527bbd;
  padding-right: 0.5em;
}
div.admonitionblock td.content {
  padding-left: 0.5em;
  border-left: 3px solid #dddddd;
}

div.exampleblock > div.content {
  border-left: 3px solid #dddddd;
  padding-left: 0.5em;
}

div.imageblock div.content { padding-left: 0; }
span.image img { border-style: none; }
a.image:visited { color: white; }

dl {
  margin-top: 0.8em;
  margin-bottom: 0.8em;
}
dt {
  margin-top: 0.5em;
  margin-bottom: 0;
  font-style: normal;
  color: navy;
}
dd > *:first-child {
  margin-top: 0.1em;
}

ul, ol {
    list-style-position: outside;
}
ol.arabic {
  list-style-type: decimal;
}
ol.loweralpha {
  list-style-type: lower-alpha;
}
ol.upperalpha {
  list-style-type: upper-alpha;
}
ol.lowerroman {
  list-style-type: lower-roman;
}
ol.upperroman {
  list-style-type: upper-roman;
}

div.compact ul, div.compact ol,
div.compact p, div.compact p,
div.compact div, div.compact div {
  margin-top: 0.1em;
  margin-bottom: 0.1em;
}

tfoot {
  font-weight: bold;
}
td > div.verse {
  white-space: pre;
}

div.hdlist {
  margin-top: 0.8em;
  margin-bottom: 0.8em;
}
div.hdlist tr {
  padding-bottom: 15px;
}
dt.hdlist1.strong, td.hdlist1.strong {
  font-weight: bold;
}
td.hdlist1 {
  vertical-align: top;
  font-style: normal;
  padding-right: 0.8em;
  color: navy;
}
td.hdlist2 {
  vertical-align: top;
}
div.hdlist.compact tr {
  margin: 0;
  padding-bottom: 0;
}

.comment {
  background: yellow;
}

.footnote, .footnoteref {
  font-size: 0.8em;
}

span.footnote, span.footnoteref {
  vertical-align: super;
}

#footnotes {
  margin: 20px 0 20px 0;
  padding: 7px 0 0 0;
}

#footnotes div.footnote {
  margin: 0 0 5px 0;
}

#footnotes hr {
  border: none;
  border-top: 1px solid silver;
  height: 1px;
  text-align: left;
  margin-left: 0;
  width: 20%;
  min-width: 100px;
}

div.colist td {
  padding-right: 0.5em;
  padding-bottom: 0.3em;
  vertical-align: top;
}
div.colist td img {
  margin-top: 0.3em;
}

@media print {
  #footer-badges { display: none; }
}

#toc {
  margin-bottom: 2.5em;
}

#toctitle {
  color: #527bbd;
  font-size: 1.1em;
  font-weight: bold;
  margin-top: 1.0em;
  margin-bottom: 0.1em;
}

div.toclevel1, div.toclevel2, div.toclevel3, div.toclevel4 {
  margin-top: 0;
  margin-bottom: 0;
}
div.toclevel2 {
  margin-left: 2em;
  font-size: 0.9em;
}
div.toclevel3 {
  margin-left: 4em;
  font-size: 0.9em;
}
div.toclevel4 {
  margin-left: 6em;
  font-size: 0.9em;
}

span.aqua { color: aqua; }
span.black { color: black; }
span.blue { color: blue; }
span.fuchsia { color: fuchsia; }
span.gray { color: gray; }
span.green { color: green; }
span.lime { color: lime; }
span.maroon { color: maroon; }
span.navy { color: navy; }
span.olive { color: olive; }
span.purple { color: purple; }
span.red { color: red; }
span.silver { color: silver; }
span.teal { color: teal; }
span.white { color: white; }
span.yellow { color: yellow; }

span.aqua-background { background: aqua; }
span.black-background { background: black; }
span.blue-background { background: blue; }
span.fuchsia-background { background: fuchsia; }
span.gray-background { background: gray; }
span.green-background { background: green; }
span.lime-background { background: lime; }
span.maroon-background { background: maroon; }
span.navy-background { background: navy; }
span.olive-background { background: olive; }
span.purple-background { background: purple; }
span.red-background { background: red; }
span.silver-background { background: silver; }
span.teal-background { background: teal; }
span.white-background { background: white; }
span.yellow-background { background: yellow; }

span.big { font-size: 2em; }
span.small { font-size: 0.6em; }

span.underline { text-decoration: underline; }
span.overline { text-decoration: overline; }
span.line-through { text-decoration: line-through; }


/*
 * xhtml11 specific
 *
 * */

tt {
  font-family: monospace;
  font-size: inherit;
  color: navy;
}

div.tableblock {
  margin-top: 1.0em;
  margin-bottom: 1.5em;
}
div.tableblock > table {
  border: 3px solid #527bbd;
}
thead, p.table.header {
  font-weight: bold;
  color: #527bbd;
}
p.table {
  margin-top: 0;
}
/* Because the table frame attribute is overriden by CSS in most browsers. */
div.tableblock > table[frame="void"] {
  border-style: none;
}
div.tableblock > table[frame="hsides"] {
  border-left-style: none;
  border-right-style: none;
}
div.tableblock > table[frame="vsides"] {
  border-top-style: none;
  border-bottom-style: none;
}


/*
 * html5 specific
 *
 * */

.monospaced {
  font-family: monospace;
  font-size: inherit;
  color: navy;
}

table.tableblock {
  margin-top: 1.0em;
  margin-bottom: 1.5em;
}
thead, p.tableblock.header {
  font-weight: bold;
  color: #527bbd;
}
p.tableblock {
  margin-top: 0;
}
table.tableblock {
  border-width: 3px;
  border-spacing: 0px;
  border-style: solid;
  border-color: #527bbd;
  border-collapse: collapse;
}
th.tableblock, td.tableblock {
  border-width: 1px;
  padding: 4px;
  border-style: solid;
  border-color: #527bbd;
}

table.tableblock.frame-topbot {
  border-left-style: hidden;
  border-right-style: hidden;
}
table.tableblock.frame-sides {
  border-top-style: hidden;
  border-bottom-style: hidden;
}
table.tableblock.frame-none {
  border-style: hidden;
}

th.tableblock.halign-left, td.tableblock.halign-left {
  text-align: left;
}
th.tableblock.halign-center, td.tableblock.halign-center {
  text-align: center;
}
th.tableblock.halign-right, td.tableblock.halign-right {
  text-align: right;
}

th.tableblock.valign-top, td.tableblock.valign-top {
  vertical-align: top;
}
th.tableblock.valign-middle, td.tableblock.valign-middle {
  vertical-align: middle;
}
th.tableblock.valign-bottom, td.tableblock.valign-bottom {
  vertical-align: bottom;
}


/*
 * manpage specific
 *
 * */

body.manpage h1 {
  padding-top: 0.5em;
  padding-bottom: 0.5em;
  border-top: 2px solid silver;
  border-bottom: 2px solid silver;
}
body.manpage h2 {
  border-style: none;
}
body.manpage div.sectionbody {
  margin-left: 3em;
}

@media print {
  body.manpage div#toc { display: none; }
}


/*
 * Theme specific overrides of the preceding (asciidoc.css) CSS.
 *
 */
body {
  font-family: Garamond, Georgia, serif;
  font-size: 17px;
  color: #3E4349;
  line-height: 1.3em;
}
h1, h2, h3, h4, h5, h6,
div.title, caption.title,
thead, p.table.header,
#toctitle,
#author, #revnumber, #revdate, #revremark,
#footer {
  font-family: Garmond, Georgia, serif;
  font-weight: normal;
  border-bottom-width: 0;
  color: #3E4349;
}
div.title, caption.title { color: #596673; font-weight: bold; }
h1 { font-size: 240%; }
h2 { font-size: 180%; }
h3 { font-size: 150%; }
h4 { font-size: 130%; }
h5 { font-size: 115%; }
h6 { font-size: 100%; }
#header h1 { margin-top: 0; }
#toc {
  color: #444444;
  line-height: 1.5;
  padding-top: 1.5em;
}
#toctitle {
  font-size: 20px;
}
#toc a {
    border-bottom: 1px dotted #999999;
    color: #444444 !important;
    text-decoration: none !important;
}
#toc a:hover {
    border-bottom: 1px solid #6D4100;
    color: #6D4100 !important;
    text-decoration: none !important;
}
div.toclevel1 { margin-top: 0.2em; font-size: 16px; }
div.toclevel2 { margin-top: 0.15em; font-size: 14px; }
em, dt, td.hdlist1 { color: black; }
strong { color: #3E4349; }
a { color: #004B6B; text-decoration: none; border-bottom: 1px dotted #004B6B; }
a:visited { color: #615FA0; border-bottom: 1px dotted #615FA0; }
a:hover { color: #6D4100; border-bottom: 1px solid #6D4100; }
div.tableblock > table, table.tableblock { border: 3px solid #E8E8E8; }
th.tableblock, td.tableblock { border: 1px solid #E8E8E8; }
ul > li > * { color: #3E4349; }
pre, tt, .monospaced { font-family: Consolas,Menlo,'Deja Vu Sans Mono','Bitstream Vera Sans Mono',monospace; }
tt, .monospaced { font-size: 0.9em; color: black;
}
div.exampleblock > div.content, div.sidebarblock > div.content, div.listingblock > div.content { border-width: 0 0 0 3px; border-color: #E8E8E8; }
div.verseblock { border-left-width: 0; margin-left: 3em; }
div.quoteblock { border-left-width: 3px; margin-left: 0; margin-right: 0;}
div.admonitionblock td.content { border-left: 3px solid #E8E8E8; }


</style>
<script type="text/javascript">
/*<![CDATA[*/
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
},


/////////////////////////////////////////////////////////////////////
// Footnotes generator
/////////////////////////////////////////////////////////////////////

/* Based on footnote generation code from:
 * http://www.brandspankingnew.net/archive/2005/07/format_footnote.html
 */

footnotes: function () {
  // Delete existing footnote entries in case we're reloading the footnodes.
  var i;
  var noteholder = document.getElementById("footnotes");
  if (!noteholder) {
    return;
  }
  var entriesToRemove = [];
  for (i = 0; i < noteholder.childNodes.length; i++) {
    var entry = noteholder.childNodes[i];
    if (entry.nodeName.toLowerCase() == 'div' && entry.getAttribute("class") == "footnote")
      entriesToRemove.push(entry);
  }
  for (i = 0; i < entriesToRemove.length; i++) {
    noteholder.removeChild(entriesToRemove[i]);
  }

  // Rebuild footnote entries.
  var cont = document.getElementById("content");
  var spans = cont.getElementsByTagName("span");
  var refs = {};
  var n = 0;
  for (i=0; i<spans.length; i++) {
    if (spans[i].className == "footnote") {
      n++;
      var note = spans[i].getAttribute("data-note");
      if (!note) {
        // Use [\s\S] in place of . so multi-line matches work.
        // Because JavaScript has no s (dotall) regex flag.
        note = spans[i].innerHTML.match(/\s*\[([\s\S]*)]\s*/)[1];
        spans[i].innerHTML =
          "[<a id='_footnoteref_" + n + "' href='#_footnote_" + n +
          "' title='View footnote' class='footnote'>" + n + "</a>]";
        spans[i].setAttribute("data-note", note);
      }
      noteholder.innerHTML +=
        "<div class='footnote' id='_footnote_" + n + "'>" +
        "<a href='#_footnoteref_" + n + "' title='Return to text'>" +
        n + "</a>. " + note + "</div>";
      var id =spans[i].getAttribute("id");
      if (id != null) refs["#"+id] = n;
    }
  }
  if (n == 0)
    noteholder.parentNode.removeChild(noteholder);
  else {
    // Process footnoterefs.
    for (i=0; i<spans.length; i++) {
      if (spans[i].className == "footnoteref") {
        var href = spans[i].getElementsByTagName("a")[0].getAttribute("href");
        href = href.match(/#.*/)[0];  // Because IE return full URL.
        n = refs[href];
        spans[i].innerHTML =
          "[<a href='#_footnote_" + n +
          "' title='View footnote' class='footnote'>" + n + "</a>]";
      }
    }
  }
},

install: function(toclevels) {
  var timerId;

  function reinstall() {
    asciidoc.footnotes();
    if (toclevels) {
      asciidoc.toc(toclevels);
    }
  }

  function reinstallAndRemoveTimer() {
    clearInterval(timerId);
    reinstall();
  }

  timerId = setInterval(reinstall, 500);
  if (document.addEventListener)
    document.addEventListener("DOMContentLoaded", reinstallAndRemoveTimer, false);
  else
    window.onload = reinstallAndRemoveTimer;
}

}
asciidoc.install(3);
/*]]>*/
</script>
</head>
<body class="book">
<div id="header">
<h1>User manual of the QVD user portal</h1>
<span id="author">QVD Docs Team</span><br>
<span id="email" class="monospaced">&lt;<a href="mailto:documentation@theqvd.com">documentation@theqvd.com</a>&gt;</span><br>
<div id="toc">
  <div id="toctitle">Table of Contents</div>
  <noscript><p><b>JavaScript must be enabled in your browser to display the table of contents.</b></p></noscript>
</div>
</div>
<div id="content">
<div class="sect1">
<h2 id="_introduction">1. Introduction</h2>
<div class="sectionbody">
<div class="paragraph"><p>The QVD user portal is a web tool you can use to connect to QVD Virtual Desktops.</p></div>
<div class="paragraph"><p>In addition to the desktops connection, an advanced configuration tool is provided, being able to save presets, and a work environment where being connected to different desktops without have to introduce the credentials every time.</p></div>
</div>
</div>
<div class="sect1">
<h2 id="_connection_methods">2. Connection methods</h2>
<div class="sectionbody">
<div class="paragraph"><p>The User Portal has two methods to connect to Virtual Desktops.</p></div>
<div class="sect2">
<h3 id="_heavy_client">2.1. Heavy client</h3>
<div class="paragraph"><p>To use this method it will be necessary to have the QVD client installed in the user computer. The User Portal will handle the background startup of the client, sending it the configuration parameters.</p></div>
</div>
<div class="sect2">
<h3 id="_html5_client">2.2. HTML5 client</h3>
<div class="paragraph"><p>The connection is performed entirely using the web application, without the needy of install any component on the system.</p></div>
<div class="paragraph"><p>Not available features on this method:</p></div>
<div class="ulist"><ul>
<li>
<p>
Sound
</p>
</li>
<li>
<p>
Shared folders
</p>
</li>
<li>
<p>
USB devices
</p>
</li>
<li>
<p>
Printing
</p>
</li>
</ul></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_elements_of_the_up">3. Elements of the UP</h2>
<div class="sectionbody">
<div class="paragraph"><p>In this section will see the different elements of the User Portal.</p></div>
<div class="sect2">
<h3 id="_user">3.1. User</h3>
<div class="paragraph"><p>It is the QVD User whose credentials he/she access to the User Portal to visualize and connect to his/her Virtual Desktops.</p></div>
<div class="ulist"><ul>
<li>
<p>
The credentials are the same used in the QVD heavy client
</p>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_virtual_desktop">3.2. Virtual desktop</h3>
<div class="paragraph"><p>The Virtual Desktops are the associated desktops to the user who access to the User Portal. These desktops correspond with deployed and administered Virtual Machines in QVD.</p></div>
</div>
<div class="sect2">
<h3 id="_workspaces">3.3. Workspaces</h3>
<div class="paragraph"><p>They are configuration parameter <em>presets</em> under which user is connected to the desktops.</p></div>
<div class="paragraph"><p>To have different configurations stored is usefull when the user connects to his desktops from different locations, with different connection speeds, etc.</p></div>
<div class="ulist"><ul>
<li>
<p>
By default, a user will have always a predefine Workspace.
</p>
</li>
<li>
<p>
Each user can create and edit the Workspaces that he wants.
</p>
</li>
<li>
<p>
Always will be a Workspace defined as active. Being the <strong>Active configuration</strong> that will be treated in other section.
</p>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_active_configuration">3.4. Active configuration</h3>
<div class="paragraph"><p>The UP active configuration is a Workspace whose parameters are used on the Vistual Desktops connection <strong>by default</strong>.</p></div>
<div class="ulist"><ul>
<li>
<p>
Is possible to change the Workspace setted as active configuration from the Virtual Desktops screen as well as the Settings screen.
</p>
</li>
<li>
<p>
The active configuration is stored between user sessions.
</p>
</li>
<li>
<p>
The active configuration will be overwritted by those desktops whose connection settings were defined.
</p>
</li>
</ul></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_step_by_step">4. Step by step</h2>
<div class="sectionbody">
<div class="sect2">
<h3 id="_login">4.1. Login</h3>
<div class="paragraph"><p>In the login screen the user credentials will be introduced, wich are the same used in the classic QVD client.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_login.png" alt="up_section_login.png" width="960px">
</span></p></div>
<div class="paragraph"><p>After introduce the credentials correctly, the access to the application will be granted, being the Virtual Desktops section the main page.</p></div>
<div class="paragraph"><p>On the left will be located the menu with the different application sections.</p></div>
</div>
<div class="sect2">
<h3 id="_virtual_desktops">4.2. Virtual desktops</h3>
<div class="paragraph"><p>On this section we got the Virtual Desktops associated in QVD to the User whose start session.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_desktops.png" alt="up_section_desktops.png" width="960px">
</span></p></div>
<div class="sect3">
<h4 id="_active_configuration_2">4.2.1. Active configuration</h4>
<div class="paragraph"><p>In the upper left there is a selection combo with the Workspace whose configuration will be the <em>Active configuration</em>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_active_configuration_control.png" alt="up_active_configuration_control.png" width="960px">
</span></p></div>
<div class="paragraph"><p>The <em>Active configuration</em> will be the configuration used for the connection of the desktops without own settings.</p></div>
<div class="paragraph"><p>The desktop own settings will be treated in the Connection settings section.</p></div>
</div>
<div class="sect3">
<h4 id="_desktops_list">4.2.2. Desktops list</h4>
<div class="paragraph"><p>The main block of this section is the Virtual Desktops list.</p></div>
<div class="paragraph"><p>Each desktop has <em>informative data</em> as his name, identifier and status. In addition, it has <em>interaction areas</em> to perform actions such as connect to the desktop or edit its configuration.</p></div>
<div class="sect4">
<h5 id="_informative_data">Informative data</h5>
<div class="ulist"><ul>
<li>
<p>
<strong>Name</strong>: The name of the desktops is predefined but can be edited by the user.
</p>
</li>
<li>
<p>
<strong>Identifier</strong>: The ID of the desktops is only shown just in case in future incidents can be requested to the user.
</p>
</li>
<li>
<p>
<strong>Status</strong>: The status shows if the user is connected or not to the desktop. The different posible status are:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Disconnected</strong>: The user is disconnected.
</p>
</li>
<li>
<p>
<strong>Connecting</strong>: The user is being connecting.
</p>
</li>
<li>
<p>
<strong>Connected</strong>: The user is connected.
</p>
</li>
<li>
<p>
<strong>Reconnecting</strong>: The desktop is resetting the connection to reconnect the user. Useful in case of having the user connected from other computer or blocking of the system.
</p>
</li>
</ul></div>
</li>
</ul></div>
</div>
<div class="sect4">
<h5 id="_interaction_areas">Interaction areas</h5>
<div class="paragraph"><p>The Virtual Desktops are represented as boxes, in wich most of the surface will serve as connection button. The rest of the box, with rectangle shape on the bottom, have connection information and a settings button.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_desktop_areas.png" alt="up_desktop_areas.png">
</span></p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Connection/Reconnection</strong>
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>To being connected to a Virtual Desktop you have to click on any part of the box that represents the Desktop but the bottom rectangle. When we move the mouse over it we observe the appearance of the connection icon.</p></div>
<div class="paragraph"><p>When you click on <em>Connect</em>, the desktop will change to the status <em>Connecting</em>  When the connection will be established, the status will change to <em>Connected</em>.</p></div>
<table class="tableblock frame-all grid-all"
style="
width:75%;
">
<col style="width:25%;">
<col style="width:25%;">
<col style="width:25%;">
<col style="width:25%;">
<tbody>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><span class="image">
<img src="/images/doc_images/up_desktop_box_disconnected.png" alt="up_desktop_box_disconnected.png">
</span></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><span class="image">
<img src="/images/doc_images/up_desktop_box_disconnected_over.png" alt="up_desktop_box_disconnected_over.png">
</span></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><span class="image">
<img src="/images/doc_images/up_desktop_box_connecting.png" alt="up_desktop_box_connecting.png">
</span></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><span class="image">
<img src="/images/doc_images/up_desktop_box_connected.png" alt="up_desktop_box_connected.png">
</span></p></td>
</tr>
</tbody>
</table>
<div class="paragraph"><p>When the desktop is in status <em>Connected</em> the same area used to make the connection, will serve to the user to the user to <em>Reconnect</em> to the Desktop. In the same way, when you move the mouse over it we observe the appearance of the reconnection icon.</p></div>
<table class="tableblock frame-all grid-all"
style="
width:75%;
">
<col style="width:25%;">
<col style="width:25%;">
<col style="width:25%;">
<col style="width:25%;">
<tbody>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><span class="image">
<img src="/images/doc_images/up_desktop_box_connected.png" alt="up_desktop_box_connected.png">
</span></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><span class="image">
<img src="/images/doc_images/up_desktop_box_connected_over.png" alt="up_desktop_box_connected_over.png">
</span></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><span class="image">
<img src="/images/doc_images/up_desktop_box_reconnecting.png" alt="up_desktop_box_reconnecting.png">
</span></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><span class="image">
<img src="/images/doc_images/up_desktop_box_disconnected.png" alt="up_desktop_box_disconnected.png">
</span></p></td>
</tr>
</tbody>
</table>
</div></div>
</li>
<li>
<p>
<strong>Connection settings configuration</strong>
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>In the lower left corner of the boxes that represent the Virtual Desktops there is a button to access to the desktop configuration settings.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_desktop_settings_hover.png" alt="up_desktop_settings_hover.png">
</span></p></div>
</div></div>
</li>
</ul></div>
</div>
</div>
<div class="sect3">
<h4 id="_virtual_desktop_connection_settings">4.2.3. Virtual desktop connection settings</h4>
<div class="paragraph"><p>When we click on the connection settings button of a Virtual Desktop, a modal window with different options will emerge:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Name</strong>: With this field, the user can customize the Desktop name. This name will be visible only by the user.
</p>
</li>
<li>
<p>
<strong>Enable own settings</strong>: If this option is disabled, the following options will be disabled too and it will be taken from the current active configuration.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_desktop_settings_disabled.png" alt="up_desktop_settings_disabled.png" width="960px">
</span></p></div>
<div class="paragraph"><p>In this way it is understood wich configuration affect the desktop and is possible to overwrite it with own settings is possible.</p></div>
<div class="paragraph"><p>If it is enabled, the options will be unblocked and it will can be edited, overwriting in this way the active configuration with specific own settings on this desktop.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Client</strong>: This option will determine what type of client will be used to establish the connection to the desktop.
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>HTML5</strong>: The client will be openened in a tab of the browser.
</p>
</li>
<li>
<p>
<strong>Classic client</strong>: The heavy client will be used.
</p>
</li>
</ul></div>
</li>
</ul></div>
<div class="paragraph"><p>Depending on the type of the client selected, specific options will shown.</p></div>
<div class="sect4">
<h5 id="_options_for_the_classic_client">Options for the Classic Client</h5>
<div class="ulist"><ul>
<li>
<p>
<strong>Connection type</strong>: Según la calidad de la conexión podremos escoger un tipo de conexión de las disponibles en un combo de selección.
</p>
<div class="ulist"><ul>
<li>
<p>
ADSL
</p>
</li>
<li>
<p>
Modem
</p>
</li>
<li>
<p>
Local
</p>
</li>
</ul></div>
</li>
<li>
<p>
<strong>Enable audio</strong>: This option will enable the audio on the Virtual Desktop.
</p>
</li>
<li>
<p>
<strong>Enable printing</strong>: This option will enable the printing on the Virtual Desktop.
</p>
</li>
<li>
<p>
<strong>Full screen visualization</strong>: This option will enable full screen mode in the heavy client.
</p>
</li>
<li>
<p>
<strong>Share folders</strong>: When enable this option a text box will appear to specify the path (one per line) of the local folders that you want to share with the desktop.
</p>
</li>
<li>
<p>
<strong>Share USB</strong>:  When enable this option a text box will appear to specify the IDs (one per line) of the USB devices that you want to share with the desktop.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_desktop_settings_enabled_classic.png" alt="up_desktop_settings_enabled_classic.png" width="960px">
</span></p></div>
</div>
<div class="sect4">
<h5 id="_options_for_the_html5_client">Options for the HTML5 Client</h5>
<div class="ulist"><ul>
<li>
<p>
<strong>Full screen visualization</strong>: This option will enable the browser full screen mode.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_desktop_settings_enabled_html5.png" alt="up_desktop_settings_enabled_html5.png" width="960px">
</span></p></div>
</div>
</div>
</div>
<div class="sect2">
<h3 id="_settings">4.3. Settings</h3>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_settings.png" alt="up_section_settings.png" width="960px">
</span></p></div>
<div class="paragraph"><p>This section contains the Workspaces management.</p></div>
<div class="paragraph"><p>There is a list of the Workspaces associated to the user wit the options of creation, clonation, deletion and activation.</p></div>
<div class="paragraph"><p>By default there is a Workspace named <strong>Default</strong> that can be edited but it is not possible to be deleted.</p></div>
<div class="sect3">
<h4 id="_create_new_workspace">4.3.1. Create new Workspace</h4>
<div class="paragraph"><p>On the bottom of the list there is a button to create a Workspace from the scratch.</p></div>
<div class="paragraph"><p>When creating a Workspace a modal window will emerge with the following fields:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Name</strong>: Nombre del Workspace
</p>
</li>
<li>
<p>
<strong>Client</strong>: This option will determine what type of client will be used to establish the connection to the desktop.
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>HTML5</strong>: The client will be openened in a tab of the browser.
</p>
</li>
<li>
<p>
<strong>Classic client</strong>: The heavy client will be used.
</p>
</li>
</ul></div>
</li>
</ul></div>
<div class="paragraph"><p>Depending on the type of the client selected, specific options will shown.</p></div>
<div class="sect4">
<h5 id="_options_for_the_classic_client_2">Options for the Classic Client</h5>
<div class="ulist"><ul>
<li>
<p>
<strong>Connection type</strong>: Según la calidad de la conexión podremos escoger un tipo de conexión de las disponibles en un combo de selección.
</p>
<div class="ulist"><ul>
<li>
<p>
ADSL
</p>
</li>
<li>
<p>
Modem
</p>
</li>
<li>
<p>
Local
</p>
</li>
</ul></div>
</li>
<li>
<p>
<strong>Enable audio</strong>: This option will enable the audio on the Virtual Desktop.
</p>
</li>
<li>
<p>
<strong>Enable printing</strong>: This option will enable the printing on the Virtual Desktop.
</p>
</li>
<li>
<p>
<strong>Full screen visualization</strong>: This option will enable full screen mode in the heavy client.
</p>
</li>
<li>
<p>
<strong>Share folders</strong>: When enable this option a text box will appear to specify the path (one per line) of the local folders that you want to share with the desktop.
</p>
</li>
<li>
<p>
<strong>Share USB</strong>:  When enable this option a text box will appear to specify the IDs (one per line) of the USB devices that you want to share with the desktop.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_new_classic.png" alt="up_settings_new_classic.png" width="960px">
</span></p></div>
</div>
<div class="sect4">
<h5 id="_options_for_the_html5_client_2">Options for the HTML5 Client</h5>
<div class="ulist"><ul>
<li>
<p>
<strong>Full screen visualization</strong>: This option will enable the browser full screen mode.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_new_html5.png" alt="up_settings_new_html5.png" width="960px">
</span></p></div>
</div>
</div>
<div class="sect3">
<h4 id="_clone_existing_workspace">4.3.2. Clone existing Workspace</h4>
<div class="paragraph"><p>This option is used to create a Workspace based on another.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_button_clone.png" alt="up_settings_button_clone.png" width="960px">
</span></p></div>
<div class="paragraph"><p>As with the new Workspace button, a modal window will emerge containing the form with the Workspace attributes. In this case, the fields will be filled by default with the origin Workspace configuration.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_clone.png" alt="up_settings_clone.png" width="960px">
</span></p></div>
</div>
<div class="sect3">
<h4 id="_set_workspace_as_active">4.3.3. Set Workspace as active</h4>
<div class="paragraph"><p>With this option a Workspace is setted as the configuration active of the User Portal.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_button_active.png" alt="up_settings_button_active.png" width="960px">
</span></p></div>
<div class="paragraph"><p>This configuration will be used in the Virtual Desktops connection unless for the Desktops with own configuration enabled.</p></div>
<div class="ulist"><ul>
<li>
<p>
Only one Workspace can be setted as active configuration.
</p>
</li>
</ul></div>
</div>
<div class="sect3">
<h4 id="_delete_workspace">4.3.4. Delete Workspace</h4>
<div class="paragraph"><p>With this option a Workspace will be deleted permanently.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_button_delete.png" alt="up_settings_button_delete.png" width="960px">
</span></p></div>
<div class="ulist"><ul>
<li>
<p>
If the active Workspace is selected, the Workspace <em>Default</em> will be the active on.
</p>
</li>
<li>
<p>
The Workspace <em>Default</em> doesn&#8217;t have this option due to be a Workspace provided by the application by default.
</p>
</li>
</ul></div>
</div>
</div>
<div class="sect2">
<h3 id="_clients_download">4.4. Clients download</h3>
<div class="paragraph"><p>This section contains a list of links to the different QVD clients available on the web.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_downloads.png" alt="up_section_downloads.png" width="960px">
</span></p></div>
</div>
<div class="sect2">
<h3 id="_connection_information">4.5. Connection information</h3>
<div class="paragraph"><p>This section contains the data of the last connection of the user to a virtual desktop.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_info.png" alt="up_section_info.png" width="960px">
</span></p></div>
<div class="ulist"><ul>
<li>
<p>
Geolocation
</p>
<div class="ulist"><ul>
<li>
<p>
Coordinates
</p>
<div class="ulist"><ul>
<li>
<p>
Latitude
</p>
</li>
<li>
<p>
Longitude
</p>
</li>
</ul></div>
</li>
<li>
<p>
Map (Open Street Map)
</p>
</li>
</ul></div>
</li>
<li>
<p>
Browser
</p>
<div class="ulist"><ul>
<li>
<p>
Chrome X.Y
</p>
</li>
<li>
<p>
Firefox X.Y
</p>
</li>
<li>
<p>
Edge X.Y
</p>
</li>
<li>
<p>
etc
</p>
</li>
</ul></div>
</li>
<li>
<p>
Operating system
</p>
<div class="ulist"><ul>
<li>
<p>
Linux
</p>
</li>
<li>
<p>
Windows
</p>
</li>
<li>
<p>
OS X
</p>
</li>
<li>
<p>
Android
</p>
</li>
<li>
<p>
iOS
</p>
</li>
<li>
<p>
etc
</p>
</li>
</ul></div>
</li>
<li>
<p>
Device
</p>
<div class="ulist"><ul>
<li>
<p>
Desktop
</p>
</li>
<li>
<p>
Mobile
</p>
</li>
<li>
<p>
etc
</p>
</li>
</ul></div>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_help">4.6. Help</h3>
<div class="paragraph"><p>This section contains the access to the different manuals of the application.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_help.png" alt="up_section_help.png" width="960px">
</span></p></div>
<div class="paragraph"><p>In addition it contains the version and license information.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_help_user_guide.png" alt="up_section_help_user_guide.png" width="960px">
</span></p></div>
<div class="paragraph"><p>The user guide is available within the portal</p></div>
</div>
</div>
</div>
</div>
<div id="footnotes"><hr></div>
<div id="footer">
<div id="footer-text">
Last updated
 2018-10-11 06:44:27 UTC
</div>
</div>
</body>
</html>
