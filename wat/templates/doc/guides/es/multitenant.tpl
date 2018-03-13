<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="generator" content="AsciiDoc 8.6.9">
<title>Guía multitenant</title>
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
<body class="article">
<div id="header">
<h1>Guía multitenant</h1>
<div id="toc">
  <div id="toctitle">Table of Contents</div>
  <noscript><p><b>JavaScript must be enabled in your browser to display the table of contents.</b></p></noscript>
</div>
</div>
<div id="content">
<div id="preamble">
<div class="sectionbody">
<div class="paragraph"><p>Esta guía es un <strong>complemento a la guía de usuario</strong>. Donde se repasarán los aspectos diferenciadores de un modo especial de funcionamiento del WAT: El <strong>modo multitenant</strong>, respecto al modo normal, o también llamado <strong>modo monotenant</strong>.</p></div>
<div class="paragraph"><p>Con la guía multitenant se describe tanto a nivel conceptual como funcional todo lo necesario para poder utilizar este modo avanzado, siempre tomando como base la guía de usuario. Ambas guías <strong>no son idependientes</strong>.</p></div>
</div>
</div>
<div class="sect1">
<h2 id="_modos_de_funcionamiento_por_ámbito">1. Modos de funcionamiento por ámbito</h2>
<div class="sectionbody">
<div class="paragraph"><p>El WAT tiene dos modos de funcionamiento:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Monotenant</strong>: Todos los administradores del sistema conviven en un mismo ámbito o tenant. Este modo de funcionamiento sería el equivalente a cómo funcionaba el WAT en versiones anteriores a QVD 4.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Un sistema por defecto es monotenant. Viene creado un usuario administrador con el que tenemos acceso total y con él podremos crear elementos de QVD y a otros administradores con los permisos más o menos limitados para gestionar diferentes partes del WAT.</p></div>
<div class="paragraph"><p>Estos permisos harán referencia a qué elementos ver o gestionar (Usuarios, Máquinas virtuales, etc.) pero no se podrá dar acceso sobre un subconjunto de los mismos.</p></div>
<div class="literalblock">
<div class="content monospaced">
<pre>Por ejemplo, si a un administrador le damos permisos de lectura sobre las imágenes de disco, podrá ver todas las imágenes del sistema, no podremos limitarlo a un subconjunto de ellas.</pre>
</div></div>
<div class="paragraph"><p>Este tipo de disgregación se realizará en el modo multitenant.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Multitenant</strong>: Podrán existir diferentes ámbitos o tenants. En ellos, se podrán crear elementos de QVD independientes entre sí y administradores que los gestionen. En este caso <strong>cada tenant se comportará como una instalación de WAT monotenant</strong>, pudiendo otorgar a los administradores permisos para poder gestionar más o menos elementos con mayor o menor control.
</p>
<div class="openblock">
<div class="content">
<div class="literalblock">
<div class="content monospaced">
<pre>Por ejemplo, a un administrador se le podrán asignar permisos de lectura sobre imágenes de disco, con el que solo podrá ver las que haya en su tenant, y un nivel más avanzado de gestión en máquinas virtuales, con el que podrá, además de visualizar, crear y actualizar las máquinas virtuales a las que tenga acceso (las de su tenant).</pre>
</div></div>
<div class="paragraph"><p>Los administradores de un tenant estarán <strong>aislados en su tenant</strong>, sin que sepan que existen otros ámbitos. Solo verán los elementos de QVD que hay en ese tenant. El administrador ni siquiera será consciente de si está trabajando en un WAT monotenant o en un tenant dentro de un WAT multitenant.</p></div>
<div class="paragraph"><p>En un WAT multitenant, existirá un <strong>ámbito superior</strong> al que denominaremos <strong>Supertenant ó Tenant <em></strong></em>* que englobará a todos los demás. Los administradores de este Supertenant están pensados para tareas de <strong>configuración y supervisión</strong> ya que podrán gestionar elementos de QVD de <strong>cualquier tenant</strong> siendo conscientes de la distribución, pudiendo filtrar elementos por tenant, o elegir en qué tenant crear un determinado elemento.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="/images/doc_images/icons//tip.png" alt="Tip">
</td>
<td class="content">Cuando un administrador del Supertenant crea elementos, puede <strong>escoger en qué Tenant</strong> hacerlo. Del mismo modo, deberá tener en cuenta que <strong>no puede relacionar elementos de diferentes Tenants entre sí</strong>, por lo que, por ejemplo, si desea crear una máquina virtual en el Tenant A, deberá existir al menos un OSF, una Imagen de disco asociada a dicho OSF y un usuario en el Tenant A.</td>
</tr></table>
</div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/Monotenant-Multitenant.png" alt="Monotenant-Multitenant.png" width="600px">
</span></p></div>
</div></div>
</li>
</ul></div>
</div>
</div>
<div class="sect1">
<h2 id="_cambio_de_modo_monotenant_8592_8594_multitenant">2. Cambio de modo (monotenant &#8592;&#8594; multitenant)</h2>
<div class="sectionbody">
<div class="dlist"><dl>
<dt class="hdlist1">
Cambios reversibles
</dt>
<dd>
<p>
Los cambios de modo del WAT son <strong>reversibles</strong>. Se puede cambiar tantas veces como se desee entre modos aunque, para preservar coherencia en los datos, lo recomendable es hacer solamente los cambios estrictamente necesarios.
</p>
</dd>
<dt class="hdlist1">
Cómo cambiar de modo
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Para cambiar el modo entre monotenant y multitenant, debemos ir a la sección de <strong>Gestión de QVD</strong> en el menú general. Dentro de dicha sección, en el apartado de <strong>Configuración de QVD</strong>, iremos al apartado <em>wat</em> o bien buscaremos en el buscador <em>multitenant</em>.</p></div>
<div class="paragraph"><p>Allí encontraremos el token <em>wat.multitenant</em>.  Este token acepta dos valores: 0 para el modo monotenant y 1 para el modo multitenant. Podremos cambiarlo al valor deseado y aplicar el cambio. A partir de este momento, nuestro sistema habrá cambiado su modo de funcionamiento.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Cambios según tipo de administrador
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Según el cambio que realicemos y el tipo de administrador con el que lo hagamos podemos vernos en diferentes situaciones:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Cambio de monotenant a multitenant</strong>: En este caso, al venir de un sistema monotenant, el cambio solo podrá realizarse con un administrador de tenant con permisos de configuración de QVD.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Al estar en todo momento dentro del tenant en el que exista el administrador que realiza el cambio, no parecerá haber consecuencias inmediatas tras su aplicación. Deberemos cerrar sesión y autenticarnos con un superadministrador para acceder al supertenant y así comprobar que el WAT está funcionando en modo multitenant. Si es la primera vez que se activa este modo, habrá un superadministrador creado por defecto. Todo esto viene detallado en el apartado Configuración Multitenant del manual.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Cambio de multitenant a monotenant</strong>: Este cambio puede realizarse con dos tipos de administradores: Un administrador de tenant o un superadministrador. Ambos necesitarán permisos de configuración de QVD para ello.
</p>
</li>
</ul></div>
</div></div>
</dd>
</dl></div>
<div class="paragraph"><p>Cuando se pasa de multitenant a monotenant, los superadministradores que existan en el sistema <strong>quedarán inactivos</strong>. No se borrarán por si se desea en algún momento volver al modo multitenant.</p></div>
<div class="paragraph"><p>De este modo tendremos diferentes comportamientos dependiendo el tipo de administrador con que realicemos el cambio:</p></div>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
<strong>Administrador de tenant</strong>: No observaremos cambios aparentes. Lo que ocurrirá es que si cerramos sesión e intentamos auntenticarnos con un superadministrador, el sistema no nos lo permitirá.
</p>
</li>
<li>
<p>
<strong>Superadministrador</strong>: Debido a que al pasar a modo monotenant los superadministradores pasan a estar inactivos, si realizamos este cambio con un superadministrador, al hacerlo efectivo, se cerrará sesión automáticamente.
</p>
</li>
</ul></div>
</div></div>
<div class="paragraph"><p>Cambiando de multitenant a monotenant existe el peligro de perder el modo multitenant. Ver la sección <em>Situaciones de bloqueo</em> en el manual.</p></div>
<div class="openblock">
<div class="content">
</div></div>
</div>
</div>
<div class="sect1">
<h2 id="_supertenant">3. Supertenant</h2>
<div class="sectionbody">
<div class="paragraph"><p>Al cambiar el modo a multitenant (Ver sección <em>Cambio de modo</em> en el manual), podremos iniciar sesión con un superadministrador. De este modo gestionaremos el supertenant * que es el ámbito de los superadministradores, así como todos los tenants del sistema.</p></div>
<div class="paragraph"><p>El supertenant * es como si fuera un tenant más a efectos de configuración del WAT. Se pueden crear administradores en él con permisos más o menos restringidos. Pero a diferencia de los tenants, <strong>no podrá albergar elementos de QVD</strong> (Máquinas virtuales, usuarios, imágenes de disco&#8230;).</p></div>
<div class="paragraph"><p>La otra diferencia principal respecto a los tenants es que los administradores del supertenant o superadministradores, tienen como <strong>ámbito</strong>, no solo el supertenant, sino <strong>todos los tenants del sistema</strong>.</p></div>
</div>
</div>
<div class="sect1">
<h2 id="_interfaz_multitenant">4. Interfaz multitenant</h2>
<div class="sectionbody">
<div class="paragraph"><p>Cuando iniciamos sesión con un superadministrador, la interfaz del WAT es prácticamente idéntica a la de un administrador de tenant normal salvo por algunas diferencias:</p></div>
<div class="ulist"><ul>
<li>
<p>
En los elementos que son contenidos en los tenants, aparecerá una <strong>columna extra indicando el tenant</strong> al que pertenecen. En el caso del listado de administradores, como caso particular, el tenant al que pertenece puede ser además el supertenant *.
</p>
</li>
<li>
<p>
En las vistas de listado de elementos clasificados por tenant, aparece un <strong>control de filtrado extra para filtrar por tenant</strong>. Como excepciones tenemos las vistas de listado de tenants,  nodos y administradores.
</p>
</li>
<li>
<p>
Cuando creamos un elemento en QVD así como un administrador del WAT, habrá un <strong>campo extra en el formulario de creación</strong> para especificar su tenant. Al igual que dijimos antes, en el caso de los administradores podremos escoger, además de los tenants, el supertenant *. Esta posibilidad solo está en la creación de elementos, y no en la edición. Una vez creado un elemento en un tenant, no podrá moverse.
</p>
</li>
<li>
<p>
En la sección <em>Vistas</em> que se encuentra en el apartado <em>Gestión del WAT</em> aparece un nuevo control de Tenant. Se pueden configurar las vistas del mismo modo que en Monotenant pero por cada Tenant.
</p>
</li>
<li>
<p>
Existen <strong>permisos adicionales</strong> como son los de gestión de tenants. De ese modo, podrá aparecer (si el superadministrador posee dichos permisos) <strong>un apartado más: Tenants</strong>.
</p>
</li>
</ul></div>
</div>
</div>
<div class="sect1">
<h2 id="_wat_multitenant_paso_a_paso">5. WAT multitenant paso a paso</h2>
<div class="sectionbody">
<div class="paragraph"><p>Veremos paso a paso las secciones o <strong>componentes que se añaden al WAT cuando activamos el modo multitenant</strong>. Estos cambios van desde la pantalla de inicio de sesión hasta pequeñas modificaciones en las vistas genéricas de listado o creación de elementos. También podrá aparecer alguna sección nueva si estamos en este modo.</p></div>
<div class="paragraph"><p>Estos cambios aparecerán <strong>solo para superadministradores</strong> que tengan los permisos adecuados para ello. <strong>Los administradores de tenant no verán ninguna diferencia</strong> con el modo monotenant, salvo una pantalla de inicio de sesión diferente.</p></div>
<div class="sect2">
<h3 id="_página_de_inicio_de_sesión_multitenant">5.1. Página de inicio de sesión (multitenant)</h3>
<div class="paragraph"><p>Cuando cargamos el WAT, está configurado en modo multitenant, la pantalla de inicio de sesión tendrá el campo <em>tenant</em> además de <em>usuario y contraseña</em>. Esto es debido a que el nombre de un administrador puede repetirse en diferentes Tenants. En el caso de los superadministradores, se pondrá * en el campo Tenant.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/login_multitenant.png" alt="login_multitenant.png" width="960px">
</span></p></div>
</div>
<div class="sect2">
<h3 id="_tenants">5.2. Tenants</h3>
<div class="paragraph"><p>En la sección <strong>Gestionar WAT</strong> aparecer un apartado más: Tenants. Este apartado se gestionan los tenants del WAT.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Vista listado
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>La vista principal es un listado con los tenants del WAT.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/screenshot_tenant_list.png" alt="screenshot_tenant_list.png" width="960px">
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Columna informativa
</dt>
<dd>
<p>
El listado de tenants no dispone de columna informativa.
</p>
</dd>
<dt class="hdlist1">
Acciones masivas
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/screenshot_tenant_massiveactions.png" alt="screenshot_tenant_massiveactions.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Las acciones masivas nos dan las siguientes opciones a realizar sobre los tenants seleccionados:</p></div>
<div class="ulist"><ul>
<li>
<p>
Eliminar tenants
</p>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Creación
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/screenshot_tenant_create.png" alt="screenshot_tenant_create.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Al crear un tenant estableceremos su nombre, idioma y tamaño de bloque. Al igual que cuando administramos la configuración del WAT, los valores de configuración de un tenant harán de configuración del WAT dentro de ese tenant. Los administradores de un tenant, no son conscientes de que existen otros ámbitos, y tendrán lo que para ellos es la configuración de WAT, correspondiendo a la configuración de su tenant si lo vemos desde el ámbito superior o supertenant.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Vista detalle
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/screenshot_tenant_details.png" alt="screenshot_tenant_details.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Observamos una <strong>cabecera</strong> donde junto al <strong>nombre del tenant</strong> están los <strong>botones para eliminarlo, bloquearlo, editarlo y limpiarlo</strong>.</p></div>
<div class="ulist"><ul>
<li>
<p>
El <strong>eliminado</strong> de tenants es como el de otros elementos. En este caso <strong>si un tenant tiene elementos, no se podrá eliminar</strong>. Será necesario vaciarlo manualmente o con la herramienta de limpieza.
</p>
</li>
<li>
<p>
El <strong>bloqueo</strong> de tenants restringe a los administradores y usuarios acceder al WAT y a sus máquinas virtuales respectivamente.
</p>
</li>
<li>
<p>
En la <strong>edición</strong> se puede cambiar el nombre, la descripción, el idioma y el tamaño de bloque por defecto del tenant. El tamaño de bloque e idioma serán efectivos para administradores de ese tenant en cuya configuración personal tengan establecido <em>Por defecto</em>.
</p>
</li>
</ul></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="/images/doc_images/icons//warning.png" alt="Warning">
</td>
<td class="content">Es importante saber que el nombre del tenant se utiliza en las credenciales de los administradores y usuarios, por lo que su cambio debe ser controlado e informado.</td>
</tr></table>
</div>
<div class="ulist"><ul>
<li>
<p>
La herramienta de <strong>limpieza</strong> muestra en una sola pantalla todos los elementos dependientes de un Tenant ofreciendo diversas opciones de eliminado: De uno en uno, por categorías (todas las máquinas virtuales, usuarios etc.), o bien eliminar todo lo que ese tenant contienga.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Bajo esta cabecera hay una <strong>tabla con los atributos del tenant</strong>.</p></div>
<div class="paragraph"><p>En la parte derecha encontramos cuadros que contienen los listados de elementos relevantes del Tenant: Máquinas virtuales, Usuarios e Imágenes de disco. Todos ellos con controles de paginación y un botón para ir a la vista correspondiente filtrada por el tenant actual.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Edición
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/screenshot_tenant_edit.png" alt="screenshot_tenant_edit.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Al editar un tenant podremos cambiar el nombre, idoma y tamaño de bloque, recordando que un administrador de ese tenant con permisos de configuración de QVD puede cambiar estos valores exceptuando el nombre, que solo podrá ser modificado por un superadministrador.</p></div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_vistas_por_defecto_multitenant">5.3. Vistas por defecto (multitenant)</h3>
<div class="paragraph"><p>Si estamos en modo multitenant y somos superadministrador, en <em>Vistas por defecto</em> podremos no solo configurar estos elementos en el supertenant, sino que también podremos hacerlo para cada uno de los tenants del sistema.</p></div>
<div class="paragraph"><p>Para ello, además de un combo selector con la sección que queremos personalizar, aparecerá otro combo de selección con el tenant al que afectará esta configuración.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/default_views_multitenant.png" alt="default_views_multitenant.png" width="960px">
</span></p></div>
<div class="paragraph"><p>A la hora de reestablecer las vistas por defecto, también podremos escoger si queremos aplicar esta acción sobre el tenant cargado en ese momento en la sección o bien sobre todos los tenants del sistema, incluyendo el supertenant *.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/default_views_multitenant_reset.png" alt="default_views_multitenant_reset.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Combinando esta opción con el control en el que elegimos si aplicar la acción sobre la sección actual o todas, tenemos diferentes posibilidades:</p></div>
<div class="ulist"><ul>
<li>
<p>
Reestablecer las vistas de la sección y tenant cargados en ese momento
</p>
</li>
<li>
<p>
Reestablecer las vistas de la sección cargada en todos los tenants del sistema
</p>
</li>
<li>
<p>
Reestablecer las vistas del tenant cargado para todas las secciones
</p>
</li>
<li>
<p>
Reestablecer las vistas de todas las secciones en todos los tenants del sistema
</p>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_documentación_multitenant">5.4. Documentación (multitenant)</h3>
<div class="paragraph"><p>Si estamos en modo multitenant y somos superadministrador, en <em>Documentación</em> encontraremos una guía más:</p></div>
<div class="ulist"><ul>
<li>
<p>
La <strong>guía multitenant</strong> donde encontraremos, por una parte una descripción teórica del funcionamiento del sistema multitenant y por otro las diferencias tanto funcionales como de interfaz respecto al modo monotenant.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Además, en los enlaces de documentación relacionada situados bajo las diferentes secciones, podremos encontrar enlaces adicionales con acceso a la parte correspondiente de dicha sección desde el punto de vista multitenant.</p></div>
</div>
<div class="sect2">
<h3 id="_propiedades_multitenant">5.5. Propiedades (multitenant)</h3>
<div class="paragraph"><p>Si estamos en modo multitenant y somos superadministrador, en <em>Propiedades</em> tendremos acceso a la gestión de todas las propiedades de todos los tenants. Por lo tanto, para clasificarlas está disponible un filtro más con el tenant al que pertenecen las propiedades en pantalla. Estos tenants incluyen el supertenant <em>*</em>, que también puede tener sus propias propiedades.</p></div>
<div class="paragraph"><p>Al poder haber propiedades específicas del supertenant <em>*</em>, en las vistas de listado y detalle de los elementos, si somos superadministradores, puede que veamos las propiedades del tenant y además las del supertenant. Conviene tener en cuenta que estas últimas no serán visibles para los administradores de ese tenant, sino que solo las podrán ver los superadministradores.</p></div>
<div class="paragraph"><p>Además, en modo multitenant <strong>los Nodos también tendrán propiedades personalizadas</strong>. Los Nodos, al no pertenecer a ningún tenant, solamente podrán tener propiedades en el supertenant <em>\*</em>, y por lo tanto serán solo administradas y visibles por un superadministrador.</p></div>
</div>
<div class="sect2">
<h3 id="_configuración_de_qvd_multitenant">5.6. Configuración de QVD (multitenant)</h3>
<div class="paragraph"><p>Si estamos en modo multitenant y somos superadministrador, en <em>Configuración de QVD</em> podremos realizar algunas acciones adicionales.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Creación de parámetros
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Se pueden añadir <strong>parámetros nuevos</strong>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/screenshot_config_create.png" alt="screenshot_config_create.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Al crear un parametro se situará en la categoría que corresponda con el inicio de su nombre.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/screenshot_config_created.png" alt="screenshot_config_created.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Si la categoría no existe, se creará en el menú.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/screenshot_config_custom.png" alt="screenshot_config_custom.png" width="960px">
</span></p></div>
<div class="paragraph"><p>Si el nombre del parámetro no contiene puntos, formará parte de la categoría especial <em>unclassified</em>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/screenshot_config_unclassified.png" alt="screenshot_config_unclassified.png" width="960px">
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Eliminado de parámetros
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Los parámetros añadidos tras la instalación, podrán eliminarse. Al hacer click en el botón "Eliminar" junto a la caja de texto, se marcará como eliminado. Esta acción se podrá deshacer con el botón que aparece bajo la caja de texto, o eliminarlo de forma definitiva con el botón "Salvar todo".</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/screenshot_config_delete.png" alt="screenshot_config_delete.png" width="960px">
</span></p></div>
</div></div>
</dd>
</dl></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_primeros_pasos_multitenant">6. Primeros pasos multitenant</h2>
<div class="sectionbody">
<div class="paragraph"><p>Si es la primera vez que activamos el modo multitenant, podremos iniciar sesión con el superadministrador que viene por defecto en el sistema. Sus credenciales son:</p></div>
<div class="literalblock">
<div class="content monospaced">
<pre>Usuario: superadmin@*
Contraseña: superadmin</pre>
</div></div>
<div class="paragraph"><p>Lo primero que haremos será <strong>cambiar la contraseña</strong>.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Poderes de <em>superadmin</em>
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Este administrador tendrá poderes totales sobre el sistema. Si deseamos tener superadministradores menos poderosos, podremos gestionarlos con él o con cualquier superadministrador creado en el sistema con los suficientes permisos. Para saber más ver sección <em>Configuración de administradores</em> en el manual.</p></div>
</div></div>
</dd>
</dl></div>
</div>
</div>
<div class="sect1">
<h2 id="_gestionar_administradores_y_permisos_multitenant">7. Gestionar Administradores y Permisos (multitenant)</h2>
<div class="sectionbody">
<div class="paragraph"><p>En entornos multitenant hay algunas cosas que debemos saber cuando gestionamos los administradores y sus permisos.</p></div>
<div class="paragraph"><p>Las diferencias en la interfaz y en su gestión que comentaremos a continuación solamente aparecerán para los superadministradores.</p></div>
<div class="paragraph"><p>Aunque un entorno sea multitenant, para los administradores de un tenant, esta condición es transparente. Para ellos, no habrá diferencia con un entorno monotenant.</p></div>
<div class="sect2">
<h3 id="_distribución_de_administradores_por_tenants">7.1. Distribución de administradores por tenants</h3>
<div class="paragraph"><p>En un entorno multitenant, <strong>los administradores estarán alojados inequívocamente en un tenant</strong>, bien sea un tenant normal o el supertenant en el caso de los superadministradores.</p></div>
<div class="paragraph"><p>Atendiendo a la creación de un administrador, distinguimos <strong>dos casos en función del ámbito</strong>:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Un administrador de tenant</strong> podrá ser creado por un administrador de su mismo tenant o por un superadministrador.
</p>
</li>
<li>
<p>
<strong>Un superadministrador podrá ser creado por otro superadministrador</strong>.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Al crear un administrador, si estamos en un entorno multitenant y somos superadministradores, aparecerá un campo para escoger en qué tenant queremos crearlo. <strong>El administrador no podrá ser movido de tenant una vez creado</strong>.</p></div>
<div class="paragraph"><p>En la vista listado de administradores figurará en una <strong>columna extra</strong> el tenant al que pertenece cada administrador, y además un <strong>nuevo control de filtrado</strong> nos ayudará a ver solamente los administradores del tenant que elijamos.</p></div>
</div>
<div class="sect2">
<h3 id="_independencia_de_plantillas_de_acls">7.2. Independencia de plantillas de ACLs</h3>
<div class="paragraph"><p>Las plantilals son independientes a los tenants. Lo que es lo mismo, son comunes a todos ellos. Como no hay una vista de plantillas más allá de la pantalla de edición de roles donde heredamos de las plantillas, no habrá cambios significativos a nivel de interfaz.</p></div>
</div>
<div class="sect2">
<h3 id="_distribución_de_roles_por_tenants">7.3. Distribución de roles por tenants</h3>
<div class="sect3">
<h4 id="_roles_de_sistema">7.3.1. Roles de sistema</h4>
<div class="paragraph"><p>Los roles que el sistema trae por defecto son fijos y comunes a todos los tenants, osea que no se pueden editar ni eliminar y están a disposición de cualquier administrador del sistema, independientemente del tenant o supertenant al que pertenezca, al igual que pasa con las plantillas.</p></div>
</div>
<div class="sect3">
<h4 id="_roles_personalizados">7.3.2. Roles personalizados</h4>
<div class="paragraph"><p>Los roles creados por un administrador estarán alojados inequívocamente en un tenant, bien sea un tenant normal o el supertenant.</p></div>
<div class="paragraph"><p>Los superadministradores podrán crearlos en cualquier tenant y los administradores de tenant lo harán en el suyo propio.</p></div>
<div class="paragraph"><p>Un rol solo podrá heredar de roles de sistema o de otros roles de su mismo tenant.</p></div>
<div class="paragraph"><p>Al crear un rol, si estamos en un entorno multitenant y somos superadministradores, aparecerá un campo para escoger en qué tenant queremos crearlo. <strong>El rol no podrá ser movido de tenant una vez creado</strong>.</p></div>
<div class="paragraph"><p>En la vista listado de roles figurará en una <strong>columna extra</strong> el tenant al que pertenece cada rol, y además un <strong>nuevo control de filtrado</strong> nos ayudará a ver solamente los roles del tenant que elijamos.</p></div>
</div>
</div>
<div class="sect2">
<h3 id="_gestión_de_tenants">7.4. Gestión de tenants</h3>
<div class="paragraph"><p>En los entornos multitenant se introduce la gestión de tenants.</p></div>
<div class="paragraph"><p>Podemos crear tantos tenants como queramos, sin límite de administradores por tenant.</p></div>
<div class="paragraph"><p>Al crear un tenant definiremos su nombre, el idioma y el tamaño de bloque del WAT por defecto para sus administradores.</p></div>
<div class="paragraph"><p>El proceso será:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Crear el tenant con el botón “Nuevo tenant”</strong> de la vista listado de tenants. Definiremos su nombre, el idioma y el tamaño de bloque del WAT por defecto para sus administradores.
</p>
</li>
<li>
<p>
La gestión de un tenant no va más allá de modificar dichos parámetros o eliminar el tenant como cualquier otro elemento en el WAT. <strong>Si eliminamos un tenant se eliminará todo su contenido</strong>, así que es una acción bastante delicada y por lo tanto crítica.
</p>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_referencia_de_acls_multitenant">7.5. Referencia de ACLs (Multitenant)</h3>
<div class="paragraph"><p>Algunos ACLs son exclusivos de entornos multitenant.</p></div>
<div class="paragraph"><p>De esta manera, en la gestión de roles así como cuando gestionemos administradores en un entorno multitenant, los árboles de ACLs tendrán ciertos ACLs extras además de los mismos que habrá en el caso de monotenant.</p></div>
<div class="paragraph"><p>Este es el caso de los ACLs responsables de la gestión de Tenants.</p></div>
<div class="sect3">
<h4 id="_acls_de_tenants">7.5.1. ACLs de Tenants</h4>
<table class="tableblock frame-all grid-all"
style="
width:100%;
">
<col style="width:33%;">
<col style="width:33%;">
<col style="width:33%;">
<thead>
<tr>
<th class="tableblock halign-left valign-top" >ACL </th>
<th class="tableblock halign-left valign-top" >código ACL </th>
<th class="tableblock halign-left valign-top" >Descripción</th>
</tr>
</thead>
<tbody>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Crear tenants</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.create.</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Crear tenants incluyendo la configuración inicial por nombre.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Eliminar tenants</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.delete.</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Eliminación de tenants uno por uno.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Acceso a la vista de los detalles del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see-details.</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Acceso a la vista de detalles de los Tenants. Esta vista incluye nombre</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Acceso a la sección principal del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see-main.</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Acceso al listado de tenants. Esta vista incluye nombre</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver el tamaño del bloque del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.blocksize</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">El tamaño del bloque en los listados de paginación de los tenants..</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver el estado de bloqueo del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.block</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Estado bloqueado (bloqueado/desbloqueado) de los tenants.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver el creador del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.created-by</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">El administrador WAT que creó el tenant</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver fecha de creación del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.creation-date</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Fecha y hora de creación cuando se creó el tenant</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver la descripción del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.description</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">La descripción de los tenants.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver imagenes de disco del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.di-list</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Ver imágenes de disco de este tenant en su vista detalle. Esta vista contiene: nombre, bloque, etiquetas, por defecto y encabezado</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver el estado bloqueado del disco del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.di-list-block</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Bloqueado de la información del disco de imágenes que se muestra en la vista detalle del tenant</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver las etiquetas de las imágenes de disco del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.di-list-tags</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Etiquetas de imágenes de disco que aparecen en la vista detalle en el tenant.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver identificación del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.id</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">La base de datos que identifica los tenants. Útil para hacer llamadas desde CLI.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver idioma del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.language</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">El idioma establecido por defecto para cualquier administrador que pertenezca a un tenant</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver usuarios del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.user-list</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Ver usuarios de un tenant en su vista detalle. Esta vista incluirá: el nombre y la información de bloqueo para cada usuario.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver el estado bloqueado del usuario del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.user-list-block</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Información de bloqueo de los usuarios que aparece en la vista detalle del tenant.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver máquinas virtuales del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.vm-list</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Ver las máquinas virtuales de un tenant en la vista detallada. Esta vista incluye: nombre, estado,de bloqueo y fecha de vencimiento de cada mv</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver el estado de bloqueo de las máquinas virtuales</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.vm-list-block</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">La información del bloqueo de las máquinas virtuales aparece en la vista detallada del tenant</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver fecha de vencimiento de las máquinas virtuales del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.vm-list-expiration</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">La información sobre el vencimiento de las máquinas virtuales aparece en las vista detallada del tenant</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver estado de funcionamiento de las máquinas virtuales del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.vm-list-state</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">El estado (apagado/encendido) de las máquinas virtuales aparece en la vista detallada del tenant</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Ver el estado de usuario de las máquinas virtuales del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.see.vm-list-user-state</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Estado del usuario (conectado/desconectado) de las máquinas virtuales que aparece en la vista detallada del tenant</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Tenants bloqueados-desbloqueados</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.update.block</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Actualizar el estado de bloqueo (bloqueado/desbloqueado) de los tenants uno por uno.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Actualizar el tamaño bloque del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.update.blocksize</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Actualizar el tamaño del bloque en los listados de paginación uno por uno.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Actualizar la descripción del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.update.description</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Actualizar la descripción de los tenants uno por uno.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Actualizar el lenguaje del tenant</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.update.language</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Actualizar el lenguaje de los tenants uno por uno.</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top" ><p class="tableblock"><strong>Actualizar el nombre de los tenants</strong></p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">tenant.update.name</p></td>
<td class="tableblock halign-left valign-top" ><p class="tableblock">Actualizar el nombre de los tenants.</p></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="sect2">
<h3 id="_referencia_de_plantillas_multitenant">7.6. Referencia de Plantillas (Multitenant)</h3>
<div class="paragraph"><p>También hay Plantillas de ACLs adicionales exclusivas del modo multitenant:</p></div>
<div class="ulist"><ul>
<li>
<p>
Tenants Manager
</p>
<div class="openblock">
<div class="content">
<div class="dlist"><dl>
<dt class="hdlist1">
Hereda de
</dt>
<dd>
</dd>
</dl></div>
<div class="ulist"><ul>
<li>
<p>
Tenants Reader
</p>
</li>
<li>
<p>
Tenants Creator
</p>
</li>
<li>
<p>
Tenants Updater
</p>
</li>
<li>
<p>
Tenants Eraser
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/Templates_Hierarchy_-_Tenants_Manager.png" alt="Templates_Hierarchy_-_Tenants_Manager.png" width="600px">
</span></p></div>
<div class="paragraph"><p>Los Tenants no tienen plantilla de operación al no tener operativa más allá de ver, crear, actualizar y borrar. Si en un futuro se añadiera, sería heredada por esta plantilla de gestión.</p></div>
</div></div>
</li>
</ul></div>
<div class="sect3">
<h4 id="_jerarquía_de_plantillas_multitenant">7.6.1. Jerarquía de Plantillas (Multitenant)</h4>
<div class="paragraph"><p>Cuando el sistema está en modo multitenant, la jerarquía de Plantillas tiene Plantillas adicionales. Se pueden ver de un vistazo en el siguiente esquema:</p></div>
<div class="paragraph"><p><span class="image">
<img src="/images/doc_images/Templates_Hierarchy_Monotenant.png" alt="Templates_Hierarchy_Monotenant.png" width="960px">
</span></p></div>
</div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_situaciones_de_bloqueo_multitenant">8. Situaciones de bloqueo (multitenant)</h2>
<div class="sectionbody">
<div class="paragraph"><p>En un sistema multitenant, surgen nuevas formas de entrar en una situación de bloqueo. Aunque en los tenants tengamos los administradores bien configurados, puede que en en el supertenant <strong>perdamos por descuido el control del único superadministrador que pueda gestionar los permisos</strong>, por lo que perderíamos funcionalidades.</p></div>
<div class="paragraph"><p>Otra nueva situación de bloqueo puede ocurrir <strong>al cambiar de modo multitenant a monotenant</strong>.</p></div>
<div class="paragraph"><p>Ocurrirá si cambiamos el modo multitenant a monotenant en el caso de que no exista ningún administrador de tenant con capacidad para volver a poner el sistema en modo multitenant ni para otorgar dichos permisos a otro administrador (o a sí mismo).</p></div>
<div class="paragraph"><p>En este caso quedaríamos atrapados en el modo monotenant, lo que también consideramos situación de bloqueo.</p></div>
</div>
</div>
<div class="sect1">
<h2 id="_modo_de_recuperación_multitenant">9. Modo de recuperación (multitenant)</h2>
<div class="sectionbody">
<div class="paragraph"><p>En una configuración multitenant también existirá el administrador de recuperación con las mismas credenciales que en monotenant:</p></div>
<div class="literalblock">
<div class="content monospaced">
<pre>Usuario: batman@*
Contraseña: (Consulte al equipo de soporte)</pre>
</div></div>
<div class="paragraph"><p>En este caso tendrá ligeras diferencias con el que tendremos en modo monotenant.</p></div>
<div class="paragraph"><p>Básicamente <strong>la diferencia será</strong>, que en este modo, <strong>el administrador de recuperación tendrá</strong>, además de los que tiene en modo monotenant, <strong>acceso a gestión de Tenants</strong>.</p></div>
</div>
</div>
</div>
<div id="footnotes"><hr></div>
<div id="footer">
<div id="footer-text">
Last updated 2018-03-13 10:16:05 CET
</div>
</div>
</body>
</html>
