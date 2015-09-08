<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
<meta name="generator" content="AsciiDoc 8.6.9" />
<title>Introducción</title>
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

.monospaced, code, pre {
  font-family: "Courier New", Courier, monospace;
  font-size: inherit;
  color: navy;
  padding: 0;
  margin: 0;
}
pre {
  white-space: pre-wrap;
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
  color: #888;
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
span.image img { border-style: none; vertical-align: text-bottom; }
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

div.toclevel0, div.toclevel1, div.toclevel2, div.toclevel3, div.toclevel4 {
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

div.unbreakable { page-break-inside: avoid; }


/*
 * xhtml11 specific
 *
 * */

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
asciidoc.install(2);
/*]]>*/
</script>
</head>
<body class="article">
<div id="header">
<h1>Introducción</h1>
<div id="toc">
  <div id="toctitle">Table of Contents</div>
  <noscript><p><b>JavaScript must be enabled in your browser to display the table of contents.</b></p></noscript>
</div>
</div>
<div id="content">
<div class="sect1">
<h2 id="_qué_es_el_wat">1. ¿Qué es el WAT?</h2>
<div class="sectionbody">
<div class="paragraph"><p>El WAT es el <strong>panel de administración Web de QVD</strong>. Una herramienta web con la que se pueden <strong>gestionar usuarios, máquinas virtuales, nodos, imágenes y parámetros de configuración de QVD</strong>.</p></div>
<div class="paragraph"><p>Para ello, mostrará en pantalla <strong>listados con los elementos del sistema</strong> con información suficiente para poder <strong>configurarlos</strong> así como <strong>detectar problemas</strong>. Dispondrá de controles de <strong>filtrado</strong> y multitud de <strong>acciones</strong> posibles sobre los elementos de QVD así como <strong>crear, actualizar o eliminarlas</strong>; y otras más específicas como arrancar o parar una máquina virtual, bloquear un usuario por tareas de mantenimiento, etc.</p></div>
<div class="paragraph"><p><strong>Cliente-Servidor</strong></p></div>
<div class="paragraph"><p>En la administración de QVD, el WAT corresponde a la parte de <strong>cliente</strong>, nutriéndose del servidor vía HTTP. De este modo extrae y gestiona la información de QVD a través de <strong>llamadas</strong> <strong>autenticadas a la API</strong> del servidor. Esta API también sirve a la aplicación de administración en línea de comandos (QVD CLI).</p></div>
</div>
</div>
<div class="sect1">
<h2 id="_compatibilidad_de_navegadores">2. Compatibilidad de navegadores</h2>
<div class="sectionbody">
<div class="paragraph"><p>A continuación se especifican los navegadores soportados para utilizar el WAT con todas sus funcionalidad. La utilización de versiones inferiores y/o otros navegadores no garantiza su correcto funcionamiento.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Escritorio
</dt>
<dd>
</dd>
</dl></div>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="25%" />
<col width="25%" />
<col width="25%" />
<col width="25%" />
<thead>
<tr>
<th align="left" valign="top">Chrome </th>
<th align="left" valign="top">Firefox        </th>
<th align="left" valign="top">Internet Explorer </th>
<th align="left" valign="top">Opera</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table">40+</p></td>
<td align="left" valign="top"><p class="table">31+</p></td>
<td align="left" valign="top"><p class="table">11+</p></td>
<td align="left" valign="top"><p class="table">31+</p></td>
</tr>
</tbody>
</table>
</div>
<div class="dlist"><dl>
<dt class="hdlist1">
Dispositivos móviles
</dt>
<dd>
</dd>
</dl></div>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="25%" />
<col width="25%" />
<col width="25%" />
<col width="25%" />
<thead>
<tr>
<th align="left" valign="top">iOS Safari     </th>
<th align="left" valign="top">iOS Chrome     </th>
<th align="left" valign="top">Android Browser    </th>
<th align="left" valign="top">Android Chrome</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table">8.4+</p></td>
<td align="left" valign="top"><p class="table">40+</p></td>
<td align="left" valign="top"><p class="table">4.3+</p></td>
<td align="left" valign="top"><p class="table">44+</p></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_estructura_general_de_la_interfaz">3. Estructura general de la interfaz</h2>
<div class="sectionbody">
<div class="paragraph"><p>La estructura de la interfaz del WAT tiene 6 componentes básicos:</p></div>
<div class="ulist"><ul>
<li>
<p>
Captura
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_list.png" alt="screenshot_vm_list.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Captura por componentes
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/interface_structure.png" alt="interface_structure.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Componentes detallados
</p>
<div class="olist arabic"><ol class="arabic">
<li>
<p>
<strong>El logo de QVD</strong>: Situado a la izquierda de la cabecera, haciendo click en él accederemos a la página principal.
</p>
</li>
<li>
<p>
<strong>Menú general</strong>:  Menú fijo a la derecha de la cabecera desde el que podremos seleccionar las distintas secciones donde se encuentran clasificadas las diferentes opciones de QVD:
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
<strong>Ayuda</strong>: Información sobre el sistema y acceso a la documentación.
</p>
</li>
<li>
<p>
<strong>Plataforma</strong>: Gestión de los elementos de QVD (Usuarios, Máquinas virtuales, Imágenes&#8230;)
</p>
</li>
<li>
<p>
<strong>Gestión del WAT</strong>:  Secciones de configuración del WAT así como la gestión de sus administradores, permisos, etc.
</p>
</li>
<li>
<p>
<strong>Gestión de QVD</strong>: Secciones de configuración de parametros de QVD.
</p>
</li>
<li>
<p>
<strong>Area de administrador</strong>: Esta sección tendrá el nombre del administrador logueado y se podrá acceder a su perfil, personalización de vistas o cerrar sesión.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Este menú es desplegable, por lo que se puede acceder directamente a las opciones de cada sección con un solo click.</p></div>
<div class="ulist"><ul>
<li>
<p>
Captura
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_drop_down.png" alt="menu_drop_down.png" width="960px" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>En la sección <strong>El WAT paso a paso</strong>, analizaremos cada sección por separado para aprender sus funcionalidades.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Menú de sección</strong>: Según en qué sección del menú general nos encontremos, bajo la cabecera encontraremos un menú con sus diferentes opciones.
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Captura
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_section_platform.png" alt="menu_section_platform.png" width="600px" />
</span></p></div>
</div></div>
</li>
</ul></div>
</div></div>
</li>
<li>
<p>
<strong>Migas de pan</strong>: Bajo el menú de sección, aparecerá en todo momento el rastro de enlaces desde la página principal hasta la actual.
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Captura
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/breadcrumbs.png" alt="breadcrumbs.png" width="300px" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>Tras las migas de pan, aparecerá un icono de libro enlazado a una ventana modal con la documentación general de la sección actual.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Contenido</strong>: La mayor parte de la pantalla, bajo el menú de sección y las migas de pan, será dedicada a mostrar el contenido de cada página.
</p>
</li>
<li>
<p>
<strong>Documentación relacionada</strong>: En la parte inferior de cada pantalla se encuentran una serie de enlaces a partes de la documentación relacionados con la sección en la que nos encontramos. Estos enlaces abrirán una ventana modal sin salir de la pantalla donde consultar esta documentación específica.
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Captura
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/related_documentation.png" alt="related_documentation.png" width="600px" />
</span></p></div>
</div></div>
</li>
</ul></div>
</div></div>
</li>
<li>
<p>
<strong>Pie de página</strong>: Tras todo el contenido se encuentra el pie de página con información de la aplicación.
</p>
</li>
</ol></div>
</li>
</ul></div>
</div>
</div>
<div class="sect1">
<h2 id="_estructura_listado_detalle">4. Estructura listado-detalle</h2>
<div class="sectionbody">
<div class="paragraph"><p>La gestión de elementos en el WAT tiene componentes en común a lo largo de muchas de sus secciones. Estos componentes conforman la estructura listado-detalle.</p></div>
<div class="sect2">
<h3 id="_vista_listado">4.1. Vista listado</h3>
<div class="paragraph"><p>Vista donde se muestra una lista de elementos paginados con controles de filtrado y acciones.</p></div>
<div class="ulist"><ul>
<li>
<p>
Captura
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_list.png" alt="screenshot_user_list.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Captura por componentes
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/interface_list.png" alt="interface_list.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Componentes detallados
</p>
<div class="olist arabic"><ol class="arabic">
<li>
<p>
<strong>Tabla de elementos</strong>: Listado de los elementos que coincidan con el filtrado (de haberlo).
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Algunas de las columnas de este listado tendrán links a otras secciones del WAT (si el administrador tiene permiso para ver dichas secciones).
La principal columna que suele coincidir con el nombre del elemento tendrá un link a la vista detalle del elemento. Este link irá acompañado de un icono de lupa.</p></div>
<div class="paragraph"><p>Esta lista estará paginada a un número de elementos por página configurable. Las columnas de esta tabla se pueden configurar <code>(Ver Personalización de vistas en el manual)</code>.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Botón para crear nuevo elemento</strong>
</p>
</li>
<li>
<p>
<strong>Control de paginación</strong>: Si no hay suficientes elementos como para haber varias páginas, este control permanecerá desactivado. De haberlos nos permitirá navegar por las diferentes páginas de una en una o yendo directamente a la primera o última.
</p>
</li>
<li>
<p>
<strong>Información de elementos seleccionados y página actual</strong>: Número de elementos seleccionados (estén en la página actual o no) y número de página mostrada respecto a las páginas totales.
</p>
</li>
<li>
<p>
<strong>Columna de casillas de verificación</strong> para seleccionar varios elementos a la vez y aplicar sobre ellos una acción.
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Se pueden <strong>seleccionar varios elementos de distintas páginas</strong> moviéndonos entre ellas con el control de paginación (3). Bajo la tabla aparecerá en todo momento el número de elementos seleccionados (4).
</p>
</li>
<li>
<p>
También es posible <strong>seleccionar todos los elementos de un solo click</strong> con la casilla de verificación que hay en la cabecera de la tabla en esa misma columna. Si hay varias páginas nos dará la opción de seleccionar solo las visibles o seleccionar los elementos de todas las páginas.
</p>
</li>
</ul></div>
</div></div>
</li>
<li>
<p>
<strong>Control de acciones masivas</strong> sobre elementos seleccionados. Se seleccionará una opción del menú desplegable y se hará click en “Aplicar”. Entre estas acciones se encuentran eliminar, bloquear, desbloquear y otras más concretas de cada vista como por ejemplo arrancar y parar máquinas virtuales.
</p>
</li>
<li>
<p>
<strong>Controles de filtrado</strong>: Dependiendo del elemento habrá unos filtros u otros. Además, estos filtros también se pueden configurar (Ver Personalización de vistas en el manual).
</p>
</li>
<li>
<p>
<strong>Filtros activos</strong>: Si hay algún filtro activado, bien porque se ha seleccionado en el control de filtrado (7) o porque se ha cargado la vista con un filtro activado, aparecerá un cuadro con los filtros activos. Desde este cuadro se pueden quitar los filtros no deseados.
</p>
</li>
<li>
<p>
<strong>Columna informativa</strong>: Muchas de las vistas contienen una columna con iconos informativos. Con estos iconos se puede apreciar en poco espacio información de los elementos como si están bloqueados, el estado de ejecución o si un usuario está conectado o no en el caso de las máquinas virtuales, etc.
</p>
</li>
</ol></div>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_vista_detalle">4.2. Vista detalle</h3>
<div class="paragraph"><p>Vista donde se muestran detallados los datos de un elemento junto a información relacionada y controles de acción, editado y borrado.</p></div>
<div class="ulist"><ul>
<li>
<p>
Captura
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_details.png" alt="screenshot_user_details.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Captura por componentes
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/interface_details.png" alt="interface_details.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Componentes detallados
</p>
<div class="olist arabic"><ol class="arabic">
<li>
<p>
<strong>Nombre del elemento</strong>
</p>
</li>
<li>
<p>
<strong>Botones de acción</strong>: A ambos lados del nombre podemos encontrar botones para eliminar, editar, bloquear/desbloquear, arrancar/parar&#8230; dependiendo del tipo de elemento en el que nos encontramos estos botones pueden variar.
</p>
</li>
<li>
<p>
<strong>Tabla con los datos del elemento</strong>: Algunos de ellos con enlaces a otras vistas.
</p>
</li>
<li>
<p>
<strong>Listados embebidos de elementos relacionados</strong>. Muchos elementos tienen en sus vistas detalles un listado simplificado embebido de elementos relacionados.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><em>Por ejemplo, en la captura, las máquinas virtuales de un usuario.</em></p></div>
<div class="paragraph"><p>Esta vista embebida tiene un botón para acceder a la vista completa de dichos elementos, que por defecto nos aparecerá filtrada por el elemento actual.</p></div>
<div class="paragraph"><p><em>Por ejemplo, en la captura, iríamos a la vista listado de máquinas virtuales filtradas por el usuario 'muser001'</em></p></div>
</div></div>
</li>
</ol></div>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_formularios_de_creación_edición">4.3. Formularios de creación-edición</h3>
<div class="paragraph"><p>Tanto en una vista como en otra, al crear o editar un elemento, se mostrarán los diferentes formularios en ventanas modales, sin salir del contexto de la vista.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_create.png" alt="screenshot_user_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_edit.png" alt="screenshot_user_edit.png" width="960px" />
</span></p></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_permisos_administrador_rol_acl">5. Permisos: Administrador-Rol-ACL</h2>
<div class="sectionbody">
<div class="paragraph"><p>Un <strong>administrador</strong> es un usuario dotado de credenciales y permisos para administrar una solución QVD a través de la herramienta de administración web (WAT).</p></div>
<div class="sect2">
<h3 id="_administradores">5.1. Administradores</h3>
<div class="paragraph"><p>Un administrador será creado por <strong>otro administrador</strong> del WAT siempre que tenga permisos para ello.</p></div>
<div class="paragraph"><p>No basta con crear un administrador para que pueda acceder al sistema. Hará falta asignarle permisos.</p></div>
</div>
<div class="sect2">
<h3 id="_permisos">5.2. Permisos</h3>
<div class="paragraph"><p>Los administradores del WAT pueden ser configurados para tener <strong>diferentes permisos para ver determinada información o realizar diferentes acciones</strong>. A estos permisos los denominamos <strong>ACLs</strong>.</p></div>
<div class="paragraph"><p>Dicha asignación no se realiza directamente, sino que se configuran una serie de <strong>roles con los ACLs deseados</strong> y dichos roles se asignan a los administradores.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/acls_roles_administrators.png" alt="acls_roles_administrators.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Si no tenemos el rol o conjunto de roles deseados para ese administrador deberemos crearlo.</p></div>
<div class="sect3">
<h4 id="_roles">5.2.1. Roles</h4>
<div class="paragraph"><p>A un rol se le pueden asignar ACLs y/o heredarlos de otros roles.</p></div>
<div class="paragraph"><p>En la herencia de roles es posible escoger qué ACLs heredar y cuales no.</p></div>
<div class="paragraph"><p>Un rol puedo heredar de uno o varios roles, así como un administrador puede tener uno o más roles asignados, adquiriendo sus ACLs.</p></div>
</div>
<div class="sect3">
<h4 id="_acls">5.2.2. ACLs</h4>
<div class="paragraph"><p>Las características y cosas a tener en cuenta de los ACLs se pueden resumir en los siguientes puntos:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Los ACLs son fijos</strong> en el sistema. No se pueden agregar, ni eliminar.
</p>
</li>
<li>
<p>
Cada ACL dará permiso para <strong>ver o hacer una única cosa</strong> en un tipo de elemento o sección.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Por ejemplo:</p></div>
</div></div>
<div class="ulist"><ul>
<li>
<p>
Acceder a la sección de Imágenes de disco
</p>
</li>
<li>
<p>
Ver la dirección IP de los nodos
</p>
</li>
<li>
<p>
Eliminar usuarios
</p>
</li>
<li>
<p>
Crear OSFs
</p>
</li>
<li>
<p>
Filtrar máquinas virtuales por usuario
</p>
</li>
<li>
<p>
…
</p>
</li>
</ul></div>
</li>
<li>
<p>
Existen ACLs específicos para gestionar los permisos de los administradores: Asignar ACLs a roles, roles a administradores, etc.
</p>
</li>
<li>
<p>
Un administrador con los ACLs para gestionar los permisos podrá:
</p>
<div class="ulist"><ul>
<li>
<p>
Gestionar todos los ACLs del sistema, y no solo los que tenga el propio administrador en sus roles asignados. Podrá asignar a roles, y por tanto a administradores, ACLs de los que no dispone.
</p>
</li>
<li>
<p>
Gestionar sus propios ACLs, pudiendo llegar a tener permisos totales o incluso perderlos. Por ello <strong>la gestión de ACLs es muy delicada</strong>.
</p>
</li>
</ul></div>
</li>
</ul></div>
<div class="paragraph"><p>Para aprender a configurar permisos ver la guía <code>Gestionar Administradores y Permisos</code>.</p></div>
</div>
</div>
</div>
</div>
</div>
<div id="footnotes"><hr /></div>
<div id="footer">
<div id="footer-text">
Last updated 2015-09-08 10:58:55 CEST
</div>
</div>
</body>
</html>
