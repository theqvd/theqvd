<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="generator" content="AsciiDoc 8.6.9">
<title>Manual de usuario del portal de usuario de QVD</title>
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
<h1>Manual de usuario del portal de usuario de QVD</h1>
<span id="author">QVD Docs Team</span><br>
<span id="email" class="monospaced">&lt;<a href="mailto:documentation@theqvd.com">documentation@theqvd.com</a>&gt;</span><br>
<div id="toc">
  <div id="toctitle">Table of Contents</div>
  <noscript><p><b>JavaScript must be enabled in your browser to display the table of contents.</b></p></noscript>
</div>
</div>
<div id="content">
<div class="sect1">
<h2 id="_introduccion">1. Introducción</h2>
<div class="sectionbody">
<div class="paragraph"><p>El <strong>portal de usuario</strong> de QVD es una herramienta web para conectarse a un escritorio virtual.</p></div>
<div class="paragraph"><p>Además de la conexión a los escritorios, también proporciona una utilidad avanzada de configuración, pudiendo guardar pre-configuraciones, y un entorno de trabajo en el que conectarse a diferentes escritorios sin tener que reintroducir las credenciales.</p></div>
</div>
</div>
<div class="sect1">
<h2 id="_metodos_de_conexion">2. Métodos de conexión</h2>
<div class="sectionbody">
<div class="paragraph"><p>El <strong>portal de usuario</strong> tiene <strong>dos</strong> formas de conectarse a los <em>escritorios virtuales</em>.</p></div>
<div class="sect2">
<h3 id="_cliente_pesado">2.1. Cliente pesado</h3>
<div class="paragraph"><p>Para utilizar este método será necesario tener instalado el cliente de QVD en el ordenador del usuario. El <strong>portal de usuario</strong> se encargará de arrancar en segundo plano el cliente enviándole los parámetros de configuración.</p></div>
</div>
<div class="sect2">
<h3 id="_cliente_html5">2.2. Cliente HTML5</h3>
<div class="paragraph"><p>La conexión se realiza íntegramente con la aplicación web, sin necesidad de instalar componente alguno en el sistema.</p></div>
<div class="paragraph"><p>Funcionalidades no disponibles actualmente en este modo:</p></div>
<div class="ulist"><ul>
<li>
<p>
Sonido
</p>
</li>
<li>
<p>
Carpetas compartidas
</p>
</li>
<li>
<p>
Dispositivos USB
</p>
</li>
<li>
<p>
Impresión
</p>
</li>
</ul></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_elementos_del_up">3. Elementos del UP</h2>
<div class="sectionbody">
<div class="paragraph"><p>En esta sección veremos los diferentes elementos del Portal de Usuario.</p></div>
<div class="sect2">
<h3 id="_usuario">3.1. Usuario</h3>
<div class="paragraph"><p>Es el Usuario de QVD con cuyas credenciales accede al Portal de Usuario para visualizar y conectarse a sus <em>escritorios virtuales</em>.</p></div>
<div class="ulist"><ul>
<li>
<p>
Las credenciales son las mismas que utiliza en el Cliente pesado de QVD
</p>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_escritorios_virtuales">3.2. Escritorios virtuales</h3>
<div class="paragraph"><p>Los <em>escritorios virtuales</em> son los escritorios asociados al usuario que accede al Portal de Usuario. Estos escritorios corresponden a <em>máquinas virtuales</em> desplegadas y administradas en QVD.</p></div>
</div>
<div class="sect2">
<h3 id="_workspaces">3.3. Workspaces</h3>
<div class="paragraph"><p>Son los <em>presets</em> de parámetros de configuración bajo los que el usuario se conecta a los escritorios.</p></div>
<div class="paragraph"><p>Tener configuraciones diferentes guardadas es de utilidad para cuando el usuario se conecta a sus escritorios desde diferentes localizaciones, con distintas velocidades de conexión, etc.</p></div>
<div class="ulist"><ul>
<li>
<p>
Por defecto, un usuario tiene siempre un <em>workspace</em> predefinido.
</p>
</li>
<li>
<p>
Cada usuario puede crear y editar los _workspaces_que desee.
</p>
</li>
<li>
<p>
Siempre habrá un <em>workspace</em> definido como activo. Siendo la <strong>Configuración activa</strong> que veremos en otro apartado.
</p>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_configuracion_activa">3.4. Configuración activa</h3>
<div class="paragraph"><p>La configuración activa del UP es un <em>workspace</em> cuyos parámetros son utilizados en la conexión de los <em>escritorios virtuales</em> <strong>por defecto</strong>.</p></div>
<div class="ulist"><ul>
<li>
<p>
Se puede cambiar el <em>workspace</em> establecido como configuración activa desde la pantalla de <em>escritorios virtuales</em> así como desde la pantalla de Ajustes.
</p>
</li>
<li>
<p>
La configuración activa se guarda entre sesiones para un usuario.
</p>
</li>
<li>
<p>
La configuración activa se verá sobrescrita por aquellos escritorios que tengan definidos ajustes de conexión.
</p>
</li>
</ul></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_paso_a_paso">4. Paso a paso</h2>
<div class="sectionbody">
<div class="sect2">
<h3 id="_login">4.1. Login</h3>
<div class="paragraph"><p>En la pantalla de login se introducirán las credenciales del usuario, siendo estas las mismas que se utilizan en el cliente clásico de QVD.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_login.png" alt="up_section_login.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Tras introducir correctamente las credenciales se tendrá acceso a la aplicación, siendo la sección de <em>escritorios virtuales</em> la página principal.</p></div>
<div class="paragraph"><p>A la izquierda se sitúa el menú con las diferentes secciones de la aplicación.</p></div>
</div>
<div class="sect2">
<h3 id="_em_escritorios_virtuales_em">4.2. <em>escritorios virtuales</em></h3>
<div class="paragraph"><p>En esta sección se muestran los <em>escritorios virtuales</em> asociados en QVD al Usuario que inicia sesión.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_desktops.png" alt="up_section_desktops.png" width="960px">
</span></p></div>
<div class="sect3">
<h4 id="_configuracion_activa_2">4.2.1. Configuración activa</h4>
<div class="paragraph"><p>En la parte superior izquierda se encuentra un combo de selección del <em>workspace</em> cuya configuración será la <em>Configuración activa</em>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_active_configuration_control.png" alt="up_active_configuration_control.png" width="960px">
</span></p></div>
<div class="paragraph"><p>La <em>Configuración activa</em> será la configuración con la que se realizarán las conexiones de aquellos escritorios que no tengan una configuración propia.</p></div>
<div class="paragraph"><p>La configuración propia de un escritorio la veremos en el apartado de ajustes de conexión.</p></div>
</div>
<div class="sect3">
<h4 id="_lista_de_escritorios">4.2.2. Lista de escritorios</h4>
<div class="paragraph"><p>La parte principal de esta sección es la lista de <em>escritorios virtuales</em>.</p></div>
<div class="paragraph"><p>Cada escritorio tiene <em>datos informativos</em> como su nombre, identificador y estado. Además dispone de <em>áreas de interacción</em> para realizar acciones como conectarse al escritorio o editar su configuración.</p></div>
<div class="sect4">
<h5 id="_datos_informativos">Datos informativos</h5>
<div class="ulist"><ul>
<li>
<p>
<strong>Nombre</strong>: El nombre de los escritorios viene predefinido pero puede ser editado por el usuario.
</p>
</li>
<li>
<p>
<strong>Identificador</strong>: El ID de los escritorios solamente se muestra a efectos de futuras incidencias en las que se le pueda solicitar al usuario.
</p>
</li>
<li>
<p>
<strong>Estado</strong>: El estado muestra si el usuario está conectado o no al escritorio. Los diferentes estados posibles son:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Desconectado</strong>: El usuario está desconectado.
</p>
</li>
<li>
<p>
<strong>Conectando</strong>: El usuario está conectándose.
</p>
</li>
<li>
<p>
<strong>Conectado</strong>: El usuario está conectado.
</p>
</li>
<li>
<p>
<strong>Reconectando</strong>: El escritorio está reiniciando la sesión para reconectar al usuario. Útil en caso de dejar el usuario conectado en otra máquina o bloqueo del sistema.
</p>
</li>
</ul></div>
</li>
</ul></div>
</div>
<div class="sect4">
<h5 id="_areas_de_interacion">Áreas de interación</h5>
<div class="paragraph"><p>Los <em>escritorios virtuales</em> están representados como cajas, en las cuales la mayoría de la superficie servirá como botón de conexión. El resto de la caja, con forma de rectángulo en la parte inferior, dispone de información de conexión y un botón de ajustes.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_desktop_areas.png" alt="up_desktop_areas.png">
</span></p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Conexión/Reconexión</strong>
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Para conectarse a un <em>escritorio virtual</em> hay que hacer click en cualquier parte de la caja que representa el escritorio excepto en el rectángulo inferior. Al pasar el ratón por encima observamos la aparición del icono de conexión.</p></div>
<div class="paragraph"><p>Al hacer click en <em>Conectar</em> el escritorio pasará a estado <em>Conectando</em>  En el momento en que se produzca la conexión el estado pasará a <em>Conectado</em>.</p></div>
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
<div class="paragraph"><p>Cuando el escritorio está en estado <em>Conectado</em> el mismo área que sirve para hacer la conexión, servirá para que el usuario se <em>Reconecte</em> al escritorio. Igualmente, al pasar el ratón por encima observamos la aparición del icono de reconexión.</p></div>
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
<strong>Configuración de ajustes de conexión</strong>
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>En la esquina inferior izquierda de las cajas que representan los <em>escritorios virtuales</em> hay un botón para acceder a los ajustes de configuración del escritorio.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_desktop_settings_hover.png" alt="up_desktop_settings_hover.png">
</span></p></div>
</div></div>
</li>
</ul></div>
</div>
</div>
<div class="sect3">
<h4 id="_ajustes_de_conexion_de_un_escritorio_virtual">4.2.3. Ajustes de conexión de un escritorio Virtual</h4>
<div class="paragraph"><p>Cuando hacemos click en el botón de ajustes de conexión en un <em>escritorio virtual</em> se abrirá una ventana modal con diferentes opciones:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Nombre</strong>: Con este campo, el usuario podrá personalizar el nombre del escritorio. Este nombre será visible solamente por el usuario.
</p>
</li>
<li>
<p>
<strong>Activar ajustes propios</strong>: Si esta opción está desactivada, las siguientes opciones estarán desactivadas y corresponderán con la configuración activa en el momento.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_desktop_settings_disabled.png" alt="up_desktop_settings_disabled.png" width="960px">
</span></p></div>
<div class="paragraph"><p>De este modo se entiende qué configuración afecta al escritorio y se da la opción de sobreescribirla con ajustes propios.</p></div>
<div class="paragraph"><p>Si se activa, las opciones se desbloquarán y se podrán cambiar, sobreescribiendo así la configuración activa con ajustes propios específicos para ese escritorio.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Cliente</strong>: Esta opción indicará qué tipo de cliente se abrirá al conectarse al escritorio.
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>HTML5</strong>: Se abrirá el cliente en una pestaña del navegador.
</p>
</li>
<li>
<p>
<strong>Cliente clásico</strong>: Se abrirá el cliente pesado.
</p>
</li>
</ul></div>
</li>
</ul></div>
<div class="paragraph"><p>Según el tipo de cliente escogido se mostrarán unas opciones determinadas.</p></div>
<div class="sect4">
<h5 id="_opciones_para_el_cliente_clasico">Opciones para el Cliente Clásico</h5>
<div class="ulist"><ul>
<li>
<p>
<strong>Tipo de conexión</strong>: Según la calidad de la conexión podremos escoger un tipo de conexión de las disponibles en un combo de selección.
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
<strong>Activar audio</strong>: Esta opción activará el audio en el Escritorio Virtual.
</p>
</li>
<li>
<p>
<strong>Activar impresión</strong>: Esta opción activará la impresión en el Escritorio Virtual.
</p>
</li>
<li>
<p>
<strong>Visualización a pantalla completa</strong>: Esta opción activará la pantalla completa en cliente pesado.
</p>
</li>
<li>
<p>
<strong>Compartir carpetas</strong>: Al activar esta opción aparecerá una caja de texto para especificar las rutas (una por línea) de las carpetas locales que se desean compartir con el escritorio.
</p>
</li>
<li>
<p>
<strong>Compartir USB</strong>: Al activar esta opción aparecerá una caja de texto para especificar los IDs (uno por línea) de los dispositivos USB que se desean compartir con el escritorio.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_desktop_settings_enabled_classic.png" alt="up_desktop_settings_enabled_classic.png" width="960px">
</span></p></div>
</div>
<div class="sect4">
<h5 id="_opciones_para_el_cliente_html5">Opciones para el Cliente HTML5</h5>
<div class="ulist"><ul>
<li>
<p>
<strong>Visualización a pantalla completa</strong>: Esta opción activará la pantalla completa en el Navegador.
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
<h3 id="_ajustes">4.3. Ajustes</h3>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_settings.png" alt="up_section_settings.png" width="960px">
</span></p></div>
<div class="paragraph"><p>En esta sección se encuentra la gestión de Workspaces.</p></div>
<div class="paragraph"><p>Se dispone de un listado con los _workspaces_asociados al usuario junto con opciones de creado, clonado, borrado y activación.</p></div>
<div class="paragraph"><p>Por defecto viene un <em>workspace</em> <strong>Default</strong> que se puede editar pero no se puede borrar.</p></div>
<div class="sect3">
<h4 id="_crear_nuevo_workspace">4.3.1. Crear nuevo Workspace</h4>
<div class="paragraph"><p>En el inferior de la lista se encuentra un botón para crear un <em>workspace</em> desde cero.</p></div>
<div class="paragraph"><p>Al crear un <em>workspace</em> aparecerá una ventana modal con los siguientes campos:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Nombre</strong>: Nombre del Workspace
</p>
</li>
<li>
<p>
<strong>Cliente</strong>: Esta opción indicará qué tipo de cliente se abrirá al conectarse al escritorio.
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>HTML5</strong>: Se abrirá el cliente en una pestaña del navegador.
</p>
</li>
<li>
<p>
<strong>Cliente clásico</strong>: Se abrirá el cliente pesado.
</p>
</li>
</ul></div>
</li>
</ul></div>
<div class="paragraph"><p>Según el tipo de cliente escogido se mostrarán unas opciones determinadas.</p></div>
<div class="sect4">
<h5 id="_opciones_para_el_cliente_clasico_2">Opciones para el Cliente Clásico</h5>
<div class="ulist"><ul>
<li>
<p>
<strong>Tipo de conexión</strong>: Según la calidad de la conexión podremos escoger un tipo de conexión de las disponibles en un combo de selección.
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
<strong>Activar audio</strong>: Esta opción activará el audio en el Escritorio Virtual.
</p>
</li>
<li>
<p>
<strong>Activar impresión</strong>: Esta opción activará la impresión en el Escritorio Virtual.
</p>
</li>
<li>
<p>
<strong>Visualización a pantalla completa</strong>: Esta opción activará la pantalla completa en cliente pesado.
</p>
</li>
<li>
<p>
<strong>Compartir carpetas</strong>: Al activar esta opción aparecerá una caja de texto para especificar las rutas (una por línea) de las carpetas locales que se desean compartir con el escritorio.
</p>
</li>
<li>
<p>
<strong>Compartir USB</strong>: Al activar esta opción aparecerá una caja de texto para especificar los IDs (uno por línea) de los dispositivos USB que se desean compartir con el escritorio.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_new_classic.png" alt="up_settings_new_classic.png" width="960px">
</span></p></div>
</div>
<div class="sect4">
<h5 id="_opciones_para_el_cliente_html5_2">Opciones para el Cliente HTML5</h5>
<div class="ulist"><ul>
<li>
<p>
<strong>Visualización a pantalla completa</strong>: Esta opción activará la pantalla completa en el Navegador.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_new_html5.png" alt="up_settings_new_html5.png" width="960px">
</span></p></div>
</div>
</div>
<div class="sect3">
<h4 id="_clonar_em_workspace_em_existente">4.3.2. Clonar <em>workspace</em> existente</h4>
<div class="paragraph"><p>Esta opción es para crear un <em>workspace</em> a partir de otro.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_button_clone.png" alt="up_settings_button_clone.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Al igual que con el botón de crear nuevo Workspace, aparecerá una ventana modal con el formulario con los atributos del Workspace, solo que en este caso aparecerán por defecto rellenados con la configuración del <em>workspace</em> origen de la clonación.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_clone.png" alt="up_settings_clone.png" width="960px">
</span></p></div>
</div>
<div class="sect3">
<h4 id="_establecer_em_workspace_em_como_activo">4.3.3. Establecer <em>workspace</em> como activo</h4>
<div class="paragraph"><p>Con esta opción se establece un <em>workspace</em> como la configuración activa del User Portal.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_button_active.png" alt="up_settings_button_active.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Esta configuración será la utilizada en la conexión por los <em>escritorios virtuales</em> salvo que tengan su configuración propia activada.</p></div>
<div class="ulist"><ul>
<li>
<p>
Sólo un <em>workspace</em> puede estar establecido como configuración activa.
</p>
</li>
</ul></div>
</div>
<div class="sect3">
<h4 id="_eliminar_workspace">4.3.4. Eliminar Workspace</h4>
<div class="paragraph"><p>Con esta opción se eliminará permanentemente un Workspace.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_settings_button_delete.png" alt="up_settings_button_delete.png" width="960px">
</span></p></div>
<div class="ulist"><ul>
<li>
<p>
Si se elimina el <em>workspace</em> activo, pasará a ser activo el <em>workspace</em> <em>Default</em>.
</p>
</li>
<li>
<p>
El <em>workspace</em> <em>Default</em> no dispone de esta opción al ser un <em>workspace</em> proporcionado por la aplicación por defecto.
</p>
</li>
</ul></div>
</div>
</div>
<div class="sect2">
<h3 id="_descarga_de_clientes">4.4. Descarga de clientes</h3>
<div class="paragraph"><p>Esta sección contiene una relación de links a los diferentes clientes de QVD disponibles en la web.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_downloads.png" alt="up_section_downloads.png" width="960px">
</span></p></div>
</div>
<div class="sect2">
<h3 id="_informacion_de_conexion">4.5. Información de conexión</h3>
<div class="paragraph"><p>En esta sección se muestran los datos de la última conexión del usuario a un escritorio virtual.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_info.png" alt="up_section_info.png" width="960px">
</span></p></div>
<div class="ulist"><ul>
<li>
<p>
Geolocalización
</p>
<div class="ulist"><ul>
<li>
<p>
Coordenadas
</p>
<div class="ulist"><ul>
<li>
<p>
Latitud
</p>
</li>
<li>
<p>
Longitud
</p>
</li>
</ul></div>
</li>
<li>
<p>
Mapa (Open Street Map)
</p>
</li>
</ul></div>
</li>
<li>
<p>
Navegador
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
Sistema operativo
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
Dispositivo
</p>
<div class="ulist"><ul>
<li>
<p>
Escritorio
</p>
</li>
<li>
<p>
Móvil
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
<h3 id="_ayuda">4.6. Ayuda</h3>
<div class="paragraph"><p>En la sección ayuda se tiene acceso a los distintos manuales de la aplicación.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_help.png" alt="up_section_help.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Además se dispone la información de versionado y licencia.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/up_section_help_user_guide.png" alt="up_section_help_user_guide.png" width="960px">
</span></p></div>
<div class="paragraph"><p>La guía de usuario está disponible dentro del portal.</p></div>
</div>
</div>
</div>
</div>
<div id="footnotes"><hr></div>
<div id="footer">
<div id="footer-text">
Last updated
 2018-10-11 06:45:03 UTC
</div>
</div>
</body>
</html>
