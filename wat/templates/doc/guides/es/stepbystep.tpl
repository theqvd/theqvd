<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
<meta name="generator" content="AsciiDoc 8.6.9" />
<title>El WAT paso a paso</title>
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
<h1>El WAT paso a paso</h1>
<div id="toc">
  <div id="toctitle">Table of Contents</div>
  <noscript><p><b>JavaScript must be enabled in your browser to display the table of contents.</b></p></noscript>
</div>
</div>
<div id="content">
<div id="preamble">
<div class="sectionbody">
<div class="paragraph"><p>En la guía <em>WAT paso a paso</em> veremos desde el inicio de sesión hasta las secciones más complejas, haciendo un recorrido por las diferentes secciones del WAT analizando su utilidad y aspectos clave.</p></div>
<div class="paragraph"><p>Estas secciones las encontramos en el menú general situado en la parte derecha de la cabecera.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_general.png" alt="menu_general.png" width="960px" />
</span></p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/important.png" alt="Important" />
</td>
<td class="content">Hay que tener en cuenta que <strong>no todos los administradores tienen por qué tener los mismos permisos</strong>, y por lo tanto, no todos verán cada una de las secciones o botones que se van a describir a continuación.</td>
</tr></table>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_página_de_inicio_de_sesión">1. Página de inicio de sesión</h2>
<div class="sectionbody">
<div class="paragraph"><p>Cuando cargamos el WAT, lo primero que nos aparecerá será una pantalla de inicio de sesión, donde autenticarnos con nuestras credenciales <em>usuario/contraseña</em>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/login.png" alt="login.png" width="960px" />
</span></p></div>
</div>
</div>
<div class="sect1">
<h2 id="_página_principal">2. Página principal</h2>
<div class="sectionbody">
<div class="paragraph"><p>La primera pantalla que se muestra al iniciar sesión es una vista táctica compuesta por gráficas y tablas resumen del sistema.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/home.png" alt="home.png" width="960px" />
</span></p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Máquinas virtuales corriendo</strong>: Se muestra en una gráfica circular la relación entre las máquinas virtuales corriendo respecto al total de máquinas virtuales existentes.
</p>
</li>
<li>
<p>
<strong>Resumen</strong>: En una tabla resumen se muestra el recuento de elementos de QVD. Número de usuarios, máquinas virtuales, nodos, OSFs e imágenes de disco.
</p>
</li>
<li>
<p>
<strong>Nodos corriendo</strong>: Se muestra en una gráfica circular la relación entre los nodos corriendo respecto al total de nodos existentes.
</p>
</li>
<li>
<p>
<strong>Máquinas virtuales próximas a expirar</strong>: Se muestran las máquinas virtuales cuya fecha de expiración está próxima.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>En esta lista se tendrá en cuenta la <strong>fecha de expiración dura</strong>, mostrándose la fecha y hora en que sucederá y el tiempo que resta hasta ese momento.</p></div>
<div class="paragraph"><p>Las máquinas virtuales aparecen ordenadas de la más próxima a expirar a la más lejana, adoptando un color más crítico cuanto más cerca esté el momento.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Nodos con más máquinas virtuales corriendo</strong>: En una gráfica de barras se mostrarán los nodos del sistema con más máquinas virtuales corriendo. Los nodos aparecerán ordenados del que más máquinas virtuales tiene al que menos.
</p>
</li>
<li>
<p>
<strong>Elementos bloqueados</strong>: En una tabla resumen se muestra el recuento de elementos de QVD <strong>bloqueados</strong>. Los elementos con posibilidad de bloqueo son los usuarios, máquinas virtuales, nodos e imágenes de disco.
</p>
</li>
</ul></div>
</div>
</div>
<div class="sect1">
<h2 id="_ayuda">3. Ayuda</h2>
<div class="sectionbody">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_help.png" alt="menu_help.png" width="600px" />
</span></p></div>
<div class="sect2">
<h3 id="_a_cerca_de">3.1. A cerca de</h3>
<div class="paragraph"><p>Sección donde se muestra información de la versión de QVD que se está utilizando así como revisión del WAT.</p></div>
</div>
<div class="sect2">
<h3 id="_documentación">3.2. Documentación</h3>
<div class="paragraph"><p>En esta sección podremos consultar la documentación del WAT.</p></div>
<div class="paragraph"><p>La documentación está distribuida en varias guías, entre las cuales se encuentran:</p></div>
<div class="ulist"><ul>
<li>
<p>
Una guía <strong>Introducción</strong> con la descripción general de los elementos de la interfaz WAT así como claves para entender funcionalidades algo complejas
</p>
</li>
<li>
<p>
Una descripción del <strong>WAT paso a paso</strong> donde se recorren los diferentes menus describiendo cada pantalla a través de capturas.
</p>
</li>
<li>
<p>
Una <strong>Guía de usuario</strong> con indicaciones para realizar tareas frecuentes como enfrentas los primeros pasos, cambiar la contraseña, creación de una máquina virtual de cero, actualizar una imagen o gestionar los permisos de otros administradores.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Además, la documentación dispone de una caja de búsqueda para encontrar rápidamente resultados en cualquiera de las guías disponibles.</p></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_plataforma">4. Plataforma</h2>
<div class="sectionbody">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_platform.png" alt="menu_platform.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>En esta sección encontraremos los diferentes elementos de QVD. Es lo que consideramos <strong>el núcleo de la administración de QVD</strong>.</p></div>
<div class="paragraph"><p>Todas ellas tienen unos <strong>componentes comunes</strong> con una vista de listado, controles de paginación, filtrado y acciones masivas, vista detalle y formularios de creación/edición. Para saber más visitar “Estructura listado-detalle” en la introducción de la documentación.</p></div>
<div class="sect2">
<h3 id="_usuarios">4.1. Usuarios</h3>
<div class="paragraph"><p>En este apartado se gestionan los usuarios de QVD incluyendo sus credenciales para acceder a las máquinas virtuales que tengan configuradas a través del cliente de QVD.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Vista listado
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>La vista principal es un listado con los usuarios de QVD.
<span class="image">
<img src="images/doc_images/screenshot_user_list.png" alt="screenshot_user_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Columna informativa
</dt>
<dd>
<p>
La columna informativa nos indicará:
</p>
<div class="ulist"><ul>
<li>
<p>
El <strong>estado de bloqueo</strong> de los usuarios:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Bloqueado</strong>: Icono de candado.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_locked.png" alt="icon_locked.png" />
</span></p></div>
<div class="paragraph"><p>Un usuario bloqueado no podrá iniciar sesión en ninguna de sus máquinas virtuales.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Desbloqueado</strong>: Si no aparece el icono de candado.
</p>
</li>
</ul></div>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Acciones masivas
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_massiveactions.png" alt="screenshot_user_massiveactions.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Las acciones masivas nos dan las siguientes opciones a realizar sobre los usuarios seleccionados:</p></div>
<div class="ulist"><ul>
<li>
<p>
Bloquear usuarios
</p>
</li>
<li>
<p>
Desbloquear usuarios
</p>
</li>
<li>
<p>
Desconectar usuarios de todas las máquinas virtuales donde estén conectados
</p>
</li>
<li>
<p>
Eliminar usuarios
</p>
</li>
<li>
<p>
Editar usuarios: La contraseña de los usuarios no aparecerá en el editor masivo. Para cambiar la contraseña se deberá hacer de uno en uno desde la vista detalle.
</p>
</li>
</ul></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">Si se selecciona solamente un elemento, en el caso de la edición se podrán editar los mismos campos que con la edición normal del elemento desde su vista detalle.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Editor masivo
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_massiveeditor.png" alt="screenshot_user_massiveeditor.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>El editor masivo de usuarios solamente permite crear/modificar propiedades. Al hacer click en “Añadir propiedad” aparecerán unas cajas de texto para poner el nombre y el valor de la propiedad. Si alguno de los usuarios editados ya tienene una propiedad con ese nombre (coincidiendo mayúsculas y minúsculas) se sobreescribirá su valor; por el contrario, si no existe, se creará.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Creación
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_create.png" alt="screenshot_user_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al crear un usuario estableceremos su nombre, password y de forma opcional podemos crearle propiedades.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Vista detalle
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_details.png" alt="screenshot_user_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Observamos una pequeña <strong>cabecera</strong> donde junto al <strong>nombre del usuario</strong> está el <strong>botón para eliminarlo, y los botones de acción</strong>.</p></div>
<div class="paragraph"><p>Los botones disponibles en la vista detalle de usuario son:</p></div>
<div class="ulist"><ul>
<li>
<p>
Bloquear/Desbloquear el usuario
</p>
</li>
<li>
<p>
Editar el usuario
</p>
</li>
</ul></div>
<div class="paragraph"><p>Bajo esta cabecera hay una <strong>tabla con los atributos del usuario</strong>, incluídas las propiedades, de haberlas.</p></div>
<div class="paragraph"><p>Y en la parte derecha encontramos:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Las máquinas virtuales asociadas</strong> a este usuario.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Si quisiéramos más acciones sobre ellas, con el botón de vista extendida iremos a la vista listado de las máquinas virtuales filtradas por este nodo.</p></div>
<div class="paragraph"><p>En este caso, a diferencia de otras vistas detalle, también disponemos de un <strong>botón para crear una máquina virtual asociada al usuario</strong> actual, donde aparecerá el mismo formulario de creación de máquinas virtuales salvo el usuario al que se asociará la máquina, que va implícito al estar creándola desde aquí.</p></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Edición
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_edit.png" alt="screenshot_user_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al editar un usuario podremos escoger si cambiarle la <strong>contraseña</strong> (si no marchamos la casilla de verificación,  permanecerá inalterada) y <strong>crear, editar o añadir propiedades</strong>.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">A la edición del elemento también se puede acceder desde la vista listado con las acciones masivas que se sitúan bajo el listado si solo seleccionamos un elemento.</td>
</tr></table>
</div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_máquinas_virtuales">4.2. Máquinas virtuales</h3>
<div class="paragraph"><p>En este apartado se gestionan las máquinas virtuales de QVD incluyendo la imagen que ejecutan.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Vista listado
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>La vista principal es un listado con las máquinas virtuales de QVD.
<span class="image">
<img src="images/doc_images/screenshot_vm_list2.png" alt="screenshot_vm_list2.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Columna informativa
</dt>
<dd>
<p>
La columna informativa nos indicará:
</p>
<div class="ulist"><ul>
<li>
<p>
El <strong>estado de bloqueo</strong> de las máquinas virtuales:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Bloqueado</strong>: Icono de candado.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_locked.png" alt="icon_locked.png" />
</span></p></div>
<div class="paragraph"><p>Una máquina virtual bloqueada no podrá arrancar.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Desbloqueado</strong>: Si no aparece el icono de candado.
</p>
</li>
</ul></div>
</li>
<li>
<p>
Si las máquinas virtuales tienen definida une <strong>fecha de expiración</strong>:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Con fecha de expiración</strong>: Icono de reloj.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_expire.png" alt="icon_expire.png" />
</span></p></div>
<div class="paragraph"><p>Este icono indica que hay cualquier expiración establecida, <strong>tanto si es suave como dura</strong>.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Sin fecha de expiración</strong>: Si no aparece el icono de reloj.
</p>
</li>
</ul></div>
</li>
<li>
<p>
<strong>Estado de ejecución</strong> de las máquinas virtuales
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Detenida</strong>: Icono de stop.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_stopped.png" alt="icon_stopped.png" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Corriendo</strong>: Icono de play.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_running.png" alt="icon_running.png" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Arrancando/Deteniéndose*: Icono animado de carga.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_startingstopping.png" alt="icon_startingstopping.png" />
</span></p></div>
</div></div>
</li>
</ul></div>
</li>
<li>
<p>
<strong>Estado de conexión de usuario</strong> de las máquinas virtuales
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Usuario conectado</strong>: Icono de usuario.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_userconnected.png" alt="icon_userconnected.png" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Usuario no conectado</strong>: Si no aparece el icono de usuario.
</p>
</li>
</ul></div>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Acciones masivas
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_massiveactions.png" alt="screenshot_vm_massiveactions.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Las acciones masivas nos dan las siguientes opciones a realizar sobre las máquinas virtuales seleccionadas:</p></div>
<div class="ulist"><ul>
<li>
<p>
Arrancar máquinas virtuales
</p>
</li>
<li>
<p>
Detener máquinas virtuales
</p>
</li>
<li>
<p>
Bloquear máquinas virtuales
</p>
</li>
<li>
<p>
Desbloquear máquinas virtuales
</p>
</li>
<li>
<p>
Desconectar usuario de máquinas virtuales
</p>
</li>
<li>
<p>
Eliminar máquinas virtuales
</p>
</li>
<li>
<p>
Editar máquinas virtuales: El nombre de las máquinas virtuales no aparecerá en el editor masivo. Para cambiar el nombre se deberá hacer de uno en uno desde la vista detalle.
</p>
</li>
</ul></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">Si se selecciona solamente un elemento, en el caso de la edición se podrán editar los mismos campos que con la edición normal del elemento desde su vista detalle.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Editor masivo
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_massiveeditor_properties.png" alt="screenshot_vm_massiveeditor_properties.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>El editor masivo de máquinas virtuales permite cambiar el tag de imagen utilizado, asignar una fecha de expiración y crear/modificar propiedades.</p></div>
<div class="paragraph"><p>Al hacer click en “Añadir propiedad” aparecerán unas cajas de texto para poner el nombre y el valor de la propiedad. Si alguna de las máquinas virtuales editadas ya tienene una propiedad con ese nombre (coincidiendo mayúsculas y minúsculas) se sobreescribirá su valor; por el contrario, si no existe, se creará.</p></div>
<div class="paragraph"><p>El control de expiración se verá en el apartado de Edición de máquinas virtuales.</p></div>
<div class="paragraph"><p>Respecto al tag de imagen, cuando editamos masivamente máquinas virtuales existen dos posibilidades:</p></div>
</div></div>
<div class="ulist"><ul>
<li>
<p>
Que las máquinas virtuales tengan asignado el mismo OSF: En este caso el selector de tags de imagen mostrará todos los tags de las imágenes del <strong>OSF asignado</strong> así como los tags especiales <em>default</em> y <em>head</em> para utilizar la imagen establecida por defecto o la última creada respectivamente.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_massiveeditor_sameOSF.png" alt="screenshot_vm_massiveeditor_sameOSF.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Que la máquinas virtuales tengan asignados OSFs distintos: En este caso, se mostrará un aviso.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_massiveeditor_differentOSF.png" alt="screenshot_vm_massiveeditor_differentOSF.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al no poder obtener una lista de tags real para todas las máquinas virtuales seleccionadas, solamente se podrá escoger entre <em>default</em> y <em>head</em>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_massiveeditor_sameOSF_opencombo.png" alt="screenshot_vm_massiveeditor_sameOSF_opencombo.png" width="960px" />
</span></p></div>
</div></div>
</li>
</ul></div>
</dd>
</dl></div>
<div class="openblock">
<div class="content">
</div></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Creación
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_create.png" alt="screenshot_vm_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al crear una máquina virtual estableceremos su <strong>nombre</strong>, el <strong>usuario</strong> al que pertenece (salvo si la creamos desde la vista detalle del usuario) y la <strong>imagen</strong> que utilizará.</p></div>
<div class="paragraph"><p>La imagen la seleccionaremos escogiendo un OSF, y el tag de imagen deseado. Al seleccionar el OSF, los tags de las imágenes asociadas a dicho OSF se cargarán en el siguiente combo, pudiendo escoger uno de ellos así como los tags especiales <em>default</em> y <em>head</em>, con los que se cargará la imagen por defecto o la última imagen creada en el OSF respectivamente.</p></div>
<div class="paragraph"><p>El OSF es el único dato que no podremos editar más adelante en una máquina virtual.</p></div>
<div class="paragraph"><p>De forma opcional podemos crearle otras propiedades.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Vista detalle
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_details.png" alt="screenshot_vm_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Observamos una pequeña <strong>cabecera</strong> donde junto al <strong>nombre de la máquina virtual</strong> está el <strong>botón para eliminarla, y los botones de acción</strong>.</p></div>
<div class="paragraph"><p>Los botones disponibles en la vista detalle de máquina virtual son:</p></div>
<div class="ulist"><ul>
<li>
<p>
Desconectar al usuario de la máquina virtual. Este botón solo estará disponible si el usuario está conectado.
</p>
</li>
<li>
<p>
Bloquear/Desbloquear la máquina virtual
</p>
</li>
<li>
<p>
Editar la máquina virtual
</p>
</li>
</ul></div>
<div class="paragraph"><p>Bajo esta cabecera hay una <strong>tabla con los atributos de la máquina virtual</strong>, incluídas las propiedades, de haberlas.</p></div>
<div class="paragraph"><p>En la parte derecha encontramos:</p></div>
</div></div>
<div class="ulist"><ul>
<li>
<p>
<strong>El estado de ejecución</strong> de la máquina virtual
</p>
</li>
</ul></div>
</dd>
</dl></div>
<div class="openblock">
<div class="content">
<div class="dlist"><dl>
<dt class="hdlist1">
Fechas de expiración
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Según la definición o no de expiración o del estado de la misma, se mostrarán diferentes cosas en el campo <em>Expiración</em> de los atributos:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Sin expiración</strong>: Se mostrará simplemente que la máquina no expirará:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/vm_expiration_no.png" alt="vm_expiration_no.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Con expiración sin cumplirse</strong>: Se mostrarán las expiraciones suave, dura o ambas, junto al tiempo restante para que sucedan. Según se va acercando el momento de la expiración se mostrarán en diferentes colores (verde, amarillo o rojo).
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/vm_expiration_enabled.png" alt="vm_expiration_enabled.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Con expiración suave cumplida</strong>: Si se ha cumplido la expiración suave se mostrará igualmente.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/vm_expiration_expiring.png" alt="vm_expiration_expiring.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Con expiración dura cumplida</strong>: Si la máquina ha expirado definitivamente, solamente se mostrará que ha expirado.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/vm_expiration_expired.png" alt="vm_expiration_expired.png" width="600px" />
</span></p></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Estado de ejecución
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>En la parte derecha de la vista detalle se muestra un <strong>cuadro con el estado de ejecución</strong> de la máquina virtual. Si la máquina está corriendo, podremos ver los <strong>parámetros de ejecución</strong>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_details_execparams.png" alt="screenshot_vm_details_execparams.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Estos parámetros pueden cambiar de una ejecución a otra y no tienen por qué coincidir con los atributos actuales de la máquina.</p></div>
<div class="paragraph"><p><em>Por ejemplo, en la captura, observamos que está configurado el tag default, por lo que la máquina virtual está ejecutando la imagen que el OSF mUbuntu tiene configurada por defecto.
Si la imagen por defecto del OSF cambia, observamos que en los atributos aparece otra imagen de disco, pero en los parámetros de ejecución sigue apareciendo la de antes, puesto que es la que se está ejecutando.</em></p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_details_execparams_warning.png" alt="screenshot_vm_details_execparams_warning.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>En este caso nos aparecerá un aviso para hacernos notar que algún parámetro en ejecución es distinto a los actuales, y si queremos que cambie deberemos reiniciar la máquina virtual.</p></div>
<div class="paragraph"><p>El cuadro con el estado de ejecución tiene, además, un control para arrancar/parar la máquina virtual.</p></div>
<div class="paragraph"><p>Según el momento, la máquina virtual puede pasar por 4 estados:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Corriendo</strong>: Aparecerá en una versión simple con un botón para mostrar los parámetros de ejecución. Estará disponible el botón para detener la máquina.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/vm_execution_state_running.png" alt="vm_execution_state_running.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Detenido</strong>: Cuando la máquina está detenida, se mostrará como tal y estará disponible el botón para arrancarla.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/vm_execution_state_stopped.png" alt="vm_execution_state_stopped.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Arrancando</strong>: Mientras se arranca la máquina virtual se mostrará un icono en movimiento. Sin necesidad de refrescar la página, cambiará a estado <em>Corriendo</em> cuando arranque o bien a <em>Detenido</em> si no lo consigue por algún motivo.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/vm_execution_state_stopped.png" alt="vm_execution_state_stopped.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Deteniéndose</strong>: Mientras se detiene la máquina virtual se mostrará un icono en movimiento. Sin necesidad de refrescar la página, cambiará a estado <em>Detenido</em> cuando finalice el proceso.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/vm_execution_state_stopping.png" alt="vm_execution_state_stopping.png" width="600px" />
</span></p></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
</dl></div>
</div></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Edición
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_edit.png" alt="screenshot_vm_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al editar una máquina virtual podremos cambiarle el <strong>nombre</strong>, el <strong>tag</strong> de imagen, las <strong>fechas de expiración</strong> y <strong>crear, editar o añadir propiedades</strong>.</p></div>
<div class="paragraph"><p>Se pueden configurar dos fechas de expiración:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Suave</strong>: Solamente se advertirá al usuario de que la máquina va a expirar. Este aviso se hace a través de unos scripts destinados a ello. Ver documentación.
</p>
</li>
<li>
<p>
<strong>Dura</strong>: Se impedirá al usuario conectar a la máquina virtual.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Para configurar las fechas de expiración existe un control de calendario.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_edit_expiration.png" alt="screenshot_vm_edit_expiration.png" width="960px" />
</span></p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">A la edición del elemento también se puede acceder desde la vista listado con las acciones masivas que se sitúan bajo el listado si solo seleccionamos un elemento.</td>
</tr></table>
</div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_nodos">4.3. Nodos</h3>
<div class="paragraph"><p>En este apartado se gestionan los nodos de QVD.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Vista listado
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>La vista principal es un listado con los nodos de QVD.
<span class="image">
<img src="images/doc_images/screenshot_host_list.png" alt="screenshot_host_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Columna informativa
</dt>
<dd>
<p>
La columna informativa nos indicará:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Estado de ejecución</strong> de los nodos
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
<strong>Detenida</strong>: Icono de stop.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_stopped.png" alt="icon_stopped.png" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Corriendo</strong>: Icono de play.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_running.png" alt="icon_running.png" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>El estado de ejecución de un nodo no depende del WAT. No se puede arrancar ni parar. El WAT simplemente conoce la dirección IP del nodo y recibe su estado.</p></div>
</div></div>
</li>
<li>
<p>
El <strong>estado de bloqueo</strong> de los nodos:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Bloqueado</strong>: Icono de candado.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_locked.png" alt="icon_locked.png" />
</span></p></div>
<div class="paragraph"><p>En un nodo bloqueado no correrán máquinas virtuales.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Desbloqueado</strong>: Si no aparece el icono de candado.
</p>
</li>
</ul></div>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Acciones masivas
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_host_massiveactions.png" alt="screenshot_host_massiveactions.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Las acciones masivas nos dan las siguientes opciones a realizar sobre los nodos seleccionados:</p></div>
<div class="ulist"><ul>
<li>
<p>
Bloquear nodos
</p>
</li>
<li>
<p>
Desbloquear nodos
</p>
</li>
<li>
<p>
Detener todas las máquinas virtuales corriendo en los nodos
</p>
</li>
<li>
<p>
Eliminar nodos
</p>
</li>
<li>
<p>
Editar nodos: Ni el nombre ni la dirección IP de los nodos aparecerá en el editor masivo. Para cambiar nombre y dirección IP se deberá hacer de uno en uno desde la vista detalle.
</p>
</li>
</ul></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">Si se selecciona solamente un elemento, en el caso de la edición se podrán editar los mismos campos que con la edición normal del elemento desde su vista detalle.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Editor masivo
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_host_massiveeditor.png" alt="screenshot_host_massiveeditor.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>El editor masivo de nodos solamente permite crear/modificar propiedades. Al hacer click en “Añadir propiedad” aparecerán unas cajas de texto para poner el nombre y el valor de la propiedad. Si alguno de los nodos editados ya tienene una propiedad con ese nombre (coincidiendo mayúsculas y minúsculas) se sobreescribirá su valor; por el contrario, si no existe, se creará.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Creación
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_host_create.png" alt="screenshot_host_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al crear un nodo estableceremos su nombre, dirección IP y de forma opcional podemos crearle propiedades.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Vista detalle
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_host_details.png" alt="screenshot_host_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Observamos una pequeña <strong>cabecera</strong> donde junto al <strong>nombre del nodo</strong> está el <strong>botón para eliminarlo, y los botones de acción</strong>.</p></div>
<div class="paragraph"><p>Los botones disponibles en la vista detalle de usuario son:</p></div>
<div class="ulist"><ul>
<li>
<p>
Bloquear/Desbloquear el nodo
</p>
</li>
<li>
<p>
Editar el nodo
</p>
</li>
</ul></div>
<div class="paragraph"><p>Bajo esta cabecera hay una <strong>tabla con los atributos del nodo</strong>, incluídas las propiedades, de haberlas.</p></div>
<div class="paragraph"><p>Y en la parte derecha encontramos:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Las máquinas virtuales corriendo en el nodo</strong>.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Si quisiéramos más acciones sobre ellas, con el botón de vista extendida iremos a la vista listado de las máquinas virtuales filtradas por este nodo.</p></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Edición
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_host_edit.png" alt="screenshot_host_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al editar un nodo podremos editar su <strong>nombre, dirección IP y crear, editar o añadir propiedades</strong>.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">A la edición del elemento también se puede acceder desde la vista listado con las acciones masivas que se sitúan bajo el listado si solo seleccionamos un elemento.</td>
</tr></table>
</div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_os_flavours">4.4. OS Flavours</h3>
<div class="paragraph"><p>En este apartado se gestionan los OSFs de QVD, en los cuales se agruparán las imágenes de disco.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Vista listado
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>La vista principal es un listado con los OSFs de QVD.
<span class="image">
<img src="images/doc_images/screenshot_osf_list.png" alt="screenshot_osf_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Columna informativa
</dt>
<dd>
<p>
En los OSFs no hay columna informativa, no son elementos bloqueables ni tienen ningún otro atributo interesante para esta columna.
</p>
</dd>
<dt class="hdlist1">
Acciones masivas
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_osf_massiveactions.png" alt="screenshot_osf_massiveactions.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Las acciones masivas nos dan las siguientes opciones a realizar sobre los OSFs seleccionados:</p></div>
<div class="ulist"><ul>
<li>
<p>
Eliminar OSFs
</p>
</li>
<li>
<p>
Editar OSFs: El nombre no aparecerá en el editor masivo. Para cambiarlo se deberá hacer de uno en uno desde la vista detalle.
</p>
</li>
</ul></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">Si se selecciona solamente un elemento, en el caso de la edición se podrán editar los mismos campos que con la edición normal del elemento desde su vista detalle.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Editor masivo
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_osf_massiveeditor.png" alt="screenshot_osf_massiveeditor.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>El editor masivo de OSFs permite modificar la memoria, el almacenamiento de usuario y crear/modificar propiedades. <strong>Si dejamos la caja de memoria y almacenamiento de usuario en blanco no se modificarán</strong>. Al hacer click en “Añadir propiedad” aparecerán unas cajas de texto para poner el nombre y el valor de la propiedad. Si alguno de los OSFs editados ya tienene una propiedad con ese nombre (coincidiendo mayúsculas y minúsculas) se sobreescribirá su valor; por el contrario, si no existe, se creará.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Creación
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_osf_create.png" alt="screenshot_osf_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al crear un OSF estableceremos su nombre, memoria, almacenamiento de usuario y de forma opcional podemos crearle propiedades.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Vista detalle
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_osf_details.png" alt="screenshot_osf_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Observamos una pequeña <strong>cabecera</strong> donde junto al <strong>nombre del OSF</strong> estan los <strong>botones para eliminarlo y editarlo</strong>.</p></div>
<div class="paragraph"><p>Bajo esta cabecera hay una <strong>tabla con los atributos del OSF</strong>, incluídas las propiedades, de haberlas.</p></div>
<div class="paragraph"><p>En la parte derecha, en este caso, encontramos:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Las imágenes de este OSF</strong>.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>En este caso, a parte de ver los nombres de las imágenes y su columna informativa, podremos <strong>cambiar la imagen definida como imágen por defecto</strong> con marcando la casilla de la última columna.</p></div>
<div class="paragraph"><p>Además, como en el caso de las máquinas virtuales desde la vista de usuarios, también disponemos de un <strong>botón para crear una imagen de disco asociada al OSF</strong> actual, donde aparecerá el mismo formulario de creación de imágenes de disco salvo el OSF al que se asociará la imagen, que va implícito al estar creándola desde aquí.</p></div>
<div class="paragraph"><p>Si quisiéramos más acciones sobre ellas, con el botón de vista extendida iremos a la vista listado de las máquinas virtuales filtradas por esta imagen.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Las máquinas virtuales</strong> que están utilizando una imagen de este OSF, solamente a modo informativo. Si quisiéramos más acciones sobre ellas, con el botón de vista extendida iremos a la vista listado de las máquinas virtuales filtradas por este OSF.
</p>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Edición
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_osf_edit.png" alt="screenshot_osf_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al editar un OSF podremos editar su <strong>nombre, memoria, almacenamiento de usuario y crear, editar o añadir propiedades</strong>.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">A la edición del elemento también se puede acceder desde la vista listado con las acciones masivas que se sitúan bajo el listado si solo seleccionamos un elemento.</td>
</tr></table>
</div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_imágenes_de_disco">4.5. Imágenes de disco</h3>
<div class="paragraph"><p>En este apartado se gestionan las imágenes de disco de QVD incluyendo su versionado y tags.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Vista listado
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>La vista principal es un listado con las imágenes de disco de QVD.
<span class="image">
<img src="images/doc_images/screenshot_di_list.png" alt="screenshot_di_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Columna informativa
</dt>
<dd>
<p>
La columna informativa nos indicará:
</p>
<div class="ulist"><ul>
<li>
<p>
El <strong>estado de bloqueo</strong> de las imágenes:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Bloqueada</strong>: Icono de candado.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_locked.png" alt="icon_locked.png" />
</span></p></div>
<div class="paragraph"><p>Una imagen bloqueada no permitirá ser usada, por lo que las máquinas virtuales que la utilicen no podrán ser arrancadas.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Desbloqueada</strong>: Si no aparece el icono de candado.
</p>
</li>
</ul></div>
</li>
<li>
<p>
Los <strong>tags</strong> asociados a las imágenes: Si una imagen tiene tags aparecerá el icono de etiqueta que al pasar por encima nos mostrará los tags.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_tags.png" alt="icon_tags.png" />
</span></p></div>
<div class="paragraph"><p>Si una imagen no tiene tags, este icono no aparecerá.</p></div>
</div></div>
</li>
<li>
<p>
Si una imagen es <strong>la imagen por defecto de su OSF</strong>: Icono de casa.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_default.png" alt="icon_default.png" />
</span></p></div>
<div class="paragraph"><p>En alguna vista podemos encontrar esta característica como el tag especial <em>default</em>.</p></div>
</div></div>
</li>
<li>
<p>
Si una imagen es <strong>la última creada de su OSF</strong>: Icono de bandera.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_head.png" alt="icon_head.png" />
</span></p></div>
<div class="paragraph"><p>En alguna vista podemos encontrar esta característica como el tag especial <em>head</em>.</p></div>
</div></div>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Acciones masivas
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_massiveactions.png" alt="screenshot_di_massiveactions.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Las acciones masivas nos dan las siguientes opciones a realizar sobre las imágenes de disco seleccionados:</p></div>
<div class="ulist"><ul>
<li>
<p>
Bloquear imágenes
</p>
</li>
<li>
<p>
Desbloquear imágenes
</p>
</li>
<li>
<p>
Eliminar imágenes
</p>
</li>
<li>
<p>
Editar imágenes: La edición de tags no aparecerán en el editor masivo. Para gestionar los tags de una imagen se deberá hacer de uno en uno desde la vista detalle.
</p>
</li>
</ul></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">Si se selecciona solamente un elemento, en el caso de la edición se podrán editar los mismos campos que con la edición normal del elemento desde su vista detalle.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Editor masivo
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_massiveeditor.png" alt="screenshot_di_massiveeditor.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>El editor masivo de imágenes solamente permite crear/modificar propiedades. Al hacer click en “Añadir propiedad” aparecerán unas cajas de texto para poner el nombre y el valor de la propiedad. Si alguna de las imáges editadas ya tienene una propiedad con ese nombre (coincidiendo mayúsculas y minúsculas) se sobreescribirá su valor; por el contrario, si no existe, se creará.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Creación
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Al crear una imagen escogeremos el <strong>fichero de imagen</strong>, <strong>la versión</strong> (si la dejamos en blanco se establecerá una versión automática basada en la fecha de creación) y <strong>el OSF</strong> donde queremos asociar la imagen. De forma opcional podemos marcarla como imagen <strong>por defecto</strong> para su OSF, añadirle <strong>tags</strong> y crearle <strong>propiedades</strong>.</p></div>
<div class="paragraph"><p>El fichero de imagen se puede configurar de tres formas:</p></div>
<div class="ulist"><ul>
<li>
<p>
Seleccionando una imagen de entre las disponibles en el directorio <em>staging</em> del servidor:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_create_staging.png" alt="screenshot_di_create_staging.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Subiendo una imagen desde nuestra computadora:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_create_upload.png" alt="screenshot_di_create_upload.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Proporcionando la URL de una imagen, que se descargará y alojará en el servidor:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_create_url.png" alt="screenshot_di_create_url.png" width="960px" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>A diferencia de la creación del resto de elementos, la de las imágenes de disco requieren tiempo al suponer la copia física de ficheros de gran tamaño.</p></div>
<div class="paragraph"><p>Por ello, al crear una imagen de disco aparecerá una pantalla de carga con una gráfica de progreso de creación.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_creating.png" alt="screenshot_di_creating.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Vista detalle
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_details.png" alt="screenshot_di_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Observamos una pequeña <strong>cabecera</strong> donde junto al <strong>nombre de la imagen</strong> está el <strong>botón para eliminarlo, y los botones de acción</strong>.</p></div>
<div class="paragraph"><p>Los botones disponibles en la vista detalle de usuario son:</p></div>
<div class="ulist"><ul>
<li>
<p>
Establecer la imagen como imagen por defecto en su OSF: Este botón solo está disponible en las imágenes que no son la imagen por defecto en su OSF.
</p>
</li>
<li>
<p>
Bloquear/Desbloquear la imagen
</p>
</li>
<li>
<p>
Editar la imagen
</p>
</li>
</ul></div>
<div class="paragraph"><p>Bajo esta cabecera hay una <strong>tabla con los atributos de la imagen</strong>, incluídas las propiedades, de haberlas.</p></div>
<div class="paragraph"><p>Dos de los campos de esta tabla serán para indicar si es la imagen por defecto o la última creada de su OSF (<strong>default y head</strong>). Estas filas solo aparecerán si se cumplen dichas premisas.</p></div>
<div class="paragraph"><p>Y en la parte derecha encontramos:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Las máquinas virtuales que utiliza</strong> esta imagen.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Si quisiéramos más acciones sobre ellas, con el botón de vista extendida iremos a la vista listado de las máquinas virtuales filtradas por esta imagen.</p></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Edición
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_edit.png" alt="screenshot_di_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al editar una imagen podremos gestionar sus <strong>tags y crear, editar o añadir propiedades</strong>. Ademas podremos establecerla como imagen por defecto de su OSF, en el caso de no serlo ya. Si lo es, nos saldrá un aviso.</p></div>
<div class="paragraph"><p><strong>Los tags de una Imagen de disco no se pueden repetir en las Imágenes asociadas a un mismo OSF</strong>. <strong>Si añadimos un tag a una Imagen de disco que ya existe</strong> en otra Imagen de su mismo OSF el sistema nos lo permitirá, pero lo que estaremos haciendo en realidad es <strong>mover el tag entre las dos Imágenes</strong>, desapareciendo de la que lo tenía en un inicio para establecerse en la Imagen que estemos editando.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">A la edición del elemento también se puede acceder desde la vista listado con las acciones masivas que se sitúan bajo el listado si solo seleccionamos un elemento.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Consecuencias de cambios en Imágenes
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>A veces, un cambio en una Imagen de disco puede tener <strong>consecuencias en las Máquinas virtuales</strong> de diversas maneras.</p></div>
<div class="paragraph"><p>Esto sucederá en Máquinas virtuales <strong>corriendo</strong> y que tengan asociado el <strong>mismo OSF</strong> que la Imagen de disco modificada.</p></div>
<div class="paragraph"><p>Una Máquina virtual tiene asignado un tag de entre los tags de sus Imágenes de disco asociadas, o lo que es lo mismo, las Imágenes de disco del OSF asociado a la Máquina. Esto incluye los tags especiales <em>head</em> y <em>default</em> que hacen referencia a la última Imagen de disco creada y a la Imagen de disco establecida como por defecto respectivamente.</p></div>
<div class="paragraph"><p>Recordamos que cuando cambiamos el tag asociado a una Máquina virtual mientras está corriendo, podemos llegar a una situación en la que su Imagen de disco asociada es distinta a la que está utilizando en la ejecución.</p></div>
<div class="paragraph"><p>Se puede llegar a la misma situación cuando el tag asociado a una Máquina virtual que está corriendo pase de una Imagen a otra. Esto puede pasar en distintas situaciones:</p></div>
<div class="ulist"><ul>
<li>
<p>
Cuando el tag sea asignado a otra Imagen de disco del mismo OSF y por lo tanto, eliminado de la Imagen usada en la ejecución de la Máquina virtual.
</p>
</li>
<li>
<p>
Cuando el tag asociado sea <em>default</em> y se establezca como Imagen por defecto del OSF una nueva Imagen de disco.
</p>
</li>
<li>
<p>
Cuando el tag asociado sea <em>head</em> y se cree una nueva Imagen de disco.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Al realizar la acción que desencadene cualquiera de estas situaciones se podrá asignar una fecha de expiración para la Máquina o Máquinas virtuales afectadas. Estas acciones son las siguientes:</p></div>
<div class="ulist"><ul>
<li>
<p>
Editar una Imagen añadiéndole un tag que está en otra, siendo este tag el asignado a una Máquina virtual corriendo
</p>
</li>
<li>
<p>
Establecer una Imagen como imagen por defecto en su OSF habiendo una máquina virtual asignada a ese mismo OSF que tiene el tag <em>default</em> asignado
</p>
</li>
<li>
<p>
Crear una Imagen en un OSF habiendo una máquina virtual asignada a ese mismo OSF que tiene el tag <em>head</em> asignado
</p>
</li>
</ul></div>
<div class="paragraph"><p>Tras cualquiera de estas acciones, aparecerá una ventana modal avisándonos de la situación con la lista de Máquinas virtuales afectadas junto a casillas de verificación y un formulario para asignar una fecha de expiración a aquellas Máquinas de la lista que deseemos.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_edit_affected_vms.png" alt="screenshot_di_edit_affected_vms.png" width="960px" />
</span></p></div>
</div></div>
</dd>
</dl></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_gestión_del_wat">5. Gestión del WAT</h2>
<div class="sectionbody">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_config_wat.png" alt="menu_config_wat.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Una parte del WAT está dedicada a la gestión del mismo. Proporcionando herramientas para la gestión de la configuración general del WAT, los administradores y sus permisos.</p></div>
<div class="sect2">
<h3 id="_configuración_del_wat">5.1. Configuración del WAT</h3>
<div class="paragraph"><p>En este apartado podremos definir una serie de valores generales que afectan a todos los administradores del WAT. Serán valores que servirán de configuración por defecto, y que cada administrador podrá configurar según sus preferencias.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_view.png" alt="screenshot_watconfig_view.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Encontramos una tabla con los valores actuales y en la parte derecha el botón de edición.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Edición
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_edit.png" alt="screenshot_watconfig_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Los parámetros configurables son:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Idioma</strong>: Será el idioma de la interfaz del WAT que tendrán por defecto los administradores.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Se puede configurar dos tipos de valores para este parámetro:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Idioma fijo</strong>: Inglés, Español&#8230;
</p>
</li>
<li>
<p>
<strong>Idioma automático</strong> (auto): Se adoptará el <strong>idioma del navegador</strong> con el que se esté utilizando el WAT. Si el idioma del navegador no está disponible en el WAT, se utilizará el <strong>inglés por defecto</strong>.
</p>
</li>
</ul></div>
</div></div>
</li>
<li>
<p>
<strong>Tamaño de bloque</strong>: Será el número de elementos mostrados en todas las vistas listado.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Si el número de elementos supera el tamaño de bloque, la lista aparecerá paginada con el tamaño de bloque como número máximo de elementos por página.</p></div>
<div class="paragraph"><p>Una excepción al tamaño de bloque son las <strong>listas embebidas</strong> en las vistas detalle, que tendrán un <strong>tamaño de bloque fijo</strong> de 5.</p></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_administradores">5.2. Administradores</h3>
<div class="paragraph"><p>En este apartado se gestionan los administradores del WAT así como sus permisos.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Vista listado
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>La vista principal es un listado con los administradores del WAT.
<span class="image">
<img src="images/doc_images/screenshot_admin_list.png" alt="screenshot_admin_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Columna informativa
</dt>
<dd>
<p>
La columna informativa nos indicará:
</p>
<div class="ulist"><ul>
<li>
<p>
El <strong>estado de bloqueo</strong> de los usuarios:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Con roles</strong>: Icono de birrete.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_montarboard.png" alt="icon_montarboard.png" />
</span></p></div>
<div class="paragraph"><p>Si pasamos el ratón por encima podremos ver los roles que tiene asociados el administrador.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Sin roles</strong>: Icono de advertencia.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_warning.png" alt="icon_warning.png" />
</span></p></div>
<div class="paragraph"><p>Si el administrador no tiene roles asociados, aparecerá un icono de advertencia, ya que un administrador sin roles no tiene sentido.</p></div>
</div></div>
</li>
</ul></div>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Acciones masivas
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_admin_massiveactions.png" alt="screenshot_admin_massiveactions.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Las acciones masivas nos dan las siguientes opciones a realizar sobre los administradores seleccionados:</p></div>
<div class="ulist"><ul>
<li>
<p>
Eliminar administradores
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
<img src="images/doc_images/screenshot_admin_create.png" alt="screenshot_admin_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al crear un administrador estableceremos su nombre, password y su idioma. Si dejamos el idioma por defecto, el administrador tendrá el idioma general del sistema aunque podrá cambiarlo.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Vista detalle
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_admin_details.png" alt="screenshot_admin_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Observamos una pequeña <strong>cabecera</strong> donde junto al <strong>nombre del administrador</strong> están los <strong>botones para eliminarlo y editarlo</strong>.</p></div>
<div class="paragraph"><p>Bajo esta cabecera hay una <strong>tabla con los atributos del administrador</strong>. Entre ellos se encuentran los roles asociados al administrador con un control de borrado junto a cada uno. Haciendo click en el nombre de los roles, se irá a la vista detalle de cada rol.</p></div>
<div class="paragraph"><p>Debajo, hay un panel con un selector para asignar cualquiera de los roles que haya configurados en el sistema. Esta asignación otorga al administrador los ACLs que contengan los roles asignados, sin importar si tienen ACLs comunes. En el árbol de ACLs podremos ir viendo los ACLs computados de la asignación.</p></div>
<div class="paragraph"><p>En la parte derecha encontramos:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>El árbol de ACLs del administrador</strong>. Las ramas aparecen inicialmente cerradas. Haciendo click sobre el icono junto a cada rama podremos abrirlas y ver su contenido.
</p>
</li>
</ul></div>
<div class="paragraph"><p>El árbol tiene dos modos de clasificación:</p></div>
<div class="ulist"><ul>
<li>
<p>
Por <strong>secciones</strong> del WAT:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Los ACLs se clasifican por la sección donde se aplican o el tipo de elemento al que afectan.</p></div>
<div class="paragraph"><p><em>Por ejemplo, en la sección Configuración se encuentran tanto la parte de configuración de WAT como la configuración de QVD.</em></p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_admin_treesections.png" alt="screenshot_admin_treesections.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Por tipo de <strong>acciones</strong>:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>En esta clasificación se encuentran los mismos ACLs, pero clasificados por el tipo de acción que permiten.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_admin_treeactions.png" alt="screenshot_admin_treeactions.png" width="600px" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>En ambos casos, <strong>solamente se mostrarán los ACLs asociados</strong> al administrador a través de los roles asignados.</p></div>
<div class="paragraph"><p>Cada ACL en el árbol tiene un icono birrete que pasando el ratón por encima nos indicará el rol o roles de los que procede. Esto es útil si hemos asociado varios roles al administrador y nos interesa saber el origen de los ACLs, ya que los roles pueden tener ACLs en común.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Edición
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_admin_edit.png" alt="screenshot_admin_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al editar un administrador podremos escoger si cambiarle la <strong>contraseña</strong> (si no marchamos la casilla de verificación,  permanecerá inalterada) y el <strong>idioma</strong>, recordando que son valores que él mismo puede cambiar.</p></div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_roles">5.3. Roles</h3>
<div class="paragraph"><p>En este apartado se gestionan los roles del WAT así como sus ACLs asociados.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Vista listado
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>La vista principal es un listado con los roles del WAT.
<span class="image">
<img src="images/doc_images/screenshot_role_list.png" alt="screenshot_role_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Columna informativa
</dt>
<dd>
<p>
En los roles no hay columna informativa.
</p>
</dd>
<dt class="hdlist1">
Acciones masivas
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_massiveactions.png" alt="screenshot_role_massiveactions.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Las acciones masivas nos dan las siguientes opciones a realizar sobre los roles seleccionados:</p></div>
<div class="ulist"><ul>
<li>
<p>
Eliminar roles
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
<img src="images/doc_images/screenshot_role_create.png" alt="screenshot_role_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al crear un rol estableceremos solamente su nombre. Lo importante será asociarle permisos, cosa que haremos desde la vista detalle.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Vista detalle
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_details.png" alt="screenshot_role_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>En esta vista muy similar a la de administradores, observamos una pequeña <strong>cabecera</strong> donde junto al <strong>nombre del rol</strong> está el <strong>botón para eliminarlo, y el botón de edición</strong>.</p></div>
<div class="paragraph"><p>Bajo esta cabecera hay una <strong>tabla con los atributos del rol</strong>. Entre los atributos se encuentra la lista de <strong>roles heredados</strong> con un enlace para eliminarlos.</p></div>
<div class="paragraph"><p>En el listado de roles heredados pueden aparecer <strong>dos tipos de elementos</strong>:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Rol</strong>: Se trata de un rol de los definidos en el sistema. El nombre de este rol, será un enlace a su vista detalle.
</p>
</li>
<li>
<p>
<strong>Plantilla</strong>: Se trata de un conjunto de ACLs predefinido para <strong>ayudar a la construcción de roles</strong>. Hay plantillas para diferentes niveles de acceso en los elementos de QVD.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Por ejemplo:</p></div>
<div class="ulist"><ul>
<li>
<p>
Acceso de solo lectura en Usuarios
</p>
</li>
<li>
<p>
Acceso de operación en Imágenes de disco (se considera operación a acciones tales como bloquear/desbloquear, desconectar usuarios, arrancar una máquina virtual&#8230;)
</p>
</li>
<li>
<p>
Acceso de actualización en Máquinas virtuales
</p>
</li>
<li>
<p>
Acceso de eliminación en Usuarios
</p>
</li>
<li>
<p>
&#8230;
</p>
</li>
</ul></div>
<div class="paragraph"><p>Otras plantillas son la composición de varios niveles de acceso:</p></div>
<div class="ulist"><ul>
<li>
<p>
Gestión: Incluyen Lectura, Operación, Creación, Actualización, Borrado
</p>
</li>
<li>
<p>
Plantillas de QVD: Las plantillas de QVD engloban las plantillas del mismo nivel de acceso de Usuarios, Máquinas virtuales, OSFs e Imágenes. Por ejemplo: QVD Updater.
</p>
</li>
<li>
<p>
Plantillas de WAT: Las plantillas de WAT engloban las plantillas del mismo nivel de acceso de Administradores, Roles y Vistas.
</p>
</li>
<li>
<p>
Master: Esta plantilla engloba las plantillas de Gestión de WAT y Gestión de QVD.
</p>
</li>
<li>
<p>
Total Master: Esta plantilla engloba la plantilla Master, Gestión de Tenants y Gestión de Nodos.
</p>
</li>
</ul></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>Debajo se encuentra un cuadro de controles de herencia de ACLs. La herencia de ACLs tiene dos modos:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Heredar ACLs de otros roles</strong>: En este modo se escoge qué rol se desea heredar con un selector de roles. Una vez heredado un rol, desaparecerá de este selector. Igualmente si se elimina de la lista de roles heredados, volverá a aparecer entre los roles heredados disponibles.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_inherit_roles.png" alt="screenshot_role_inherit_roles.png" width="600px" />
</span></p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Heredar ACLs de plantillas</strong>: En este modo se escogen las plantillas de las que se deseen heredar los ACLs de una matriz de botones donde se distribuyen las diferentes plantillas según los objetos o nivel de privilegios de cada una. Por ejemplo, la plantilla con los ACLs de actualización de un Nodo estará en la intersección de la fila de Nodos y la columna de Actualizado.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_inherit_templates.png" alt="screenshot_role_inherit_templates.png" width="600px" />
</span></p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">Si se hereda de uno o más roles/plantillas, se heredará la suma de sus ACLs sin importar los ACLs comunes. Tras esta herencia, se pueden quitar o agregar ACLs sueltos manualmente desde el Árbol de ACLs para personalizar las credenciales obtenidas por ellos según las necesidades del administrador. De este modo, si nos interesan todos los ACLs de un rol o plantilla excepto uno, será tan fácil como heredar el rol/plantilla y quitar a mano el ACL sobrante.</td>
</tr></table>
</div>
<div class="paragraph"><p>En la parte derecha encontramos:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>El árbol de ACLs</strong>. Las ramas aparecen inicialmente cerradas. Haciendo click sobre el icono junto a cada rama podremos abrirlas y ver su contenido. A diferencia del árbol de ACLs de la vista detalle de administradores, <strong>en los roles el árbol contiene todos los ACLs del sistema</strong>, y figuran como activos los que tiene asociado el rol.
</p>
</li>
</ul></div>
<div class="paragraph"><p>El árbol tiene, del mismo modo que en el árbol de la vista detalle de administradores, dos modos de clasificación:</p></div>
<div class="ulist"><ul>
<li>
<p>
Por <strong>secciones</strong> del WAT:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Los ACLs se clasifican por la sección donde se aplican o el tipo de elemento al que afectan.</p></div>
<div class="paragraph"><p>El ACL principal de cada sección, y necesario para que esa sección al menos esté disponible en el menú, junto a su vista principal es “Acceder a vista principal de&#8230;”, salvo en los apartados de configuración que se rigen por un único ACL “Gestión de configuración WAT/QVD”.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_treesections.png" alt="screenshot_role_treesections.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Por tipo de <strong>acciones</strong>:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>En esta clasificación se encuentran los mismos ACLs, pero clasificados por el tipo de acción que permiten.</p></div>
<div class="paragraph"><p><em>Por ejemplo en la rama “Ver sección principal” podemos configurar que secciones ver.</em></p></div>
<div class="paragraph"><p>Si queremos aplicarles ciertos permisos de un tipo (borrar, actualizar, etc.) sobre varios tipos de elementos, esta clasificiación simplifica la gestión de ACLs.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_treeactions.png" alt="screenshot_role_treeactions.png" width="600px" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>Cada rama tiene una casilla de verificación. Si está activada, significa que todos los ACLs de la rama están asignados, bien directamente o por herencia de uno o varios roles.</p></div>
<div class="paragraph"><p><strong>Si activamos la casilla de una rama</strong>, incluiremos en el rol todos los ACLs de esa rama. Del mismo modo, <strong>si desactivamos la casilla de una rama</strong>, estaremos quitando sus ACLs.</p></div>
<div class="paragraph"><p>Las ramas, también tienen adosada, entre paréntesis, información de los ACLs incluídos en el rol frente a los ACLs totales en la rama.</p></div>
<div class="paragraph"><p>Al abrir una rama, vemos que <strong>cada ACL tiene una casilla de verificación</strong> con la que asociarlo o desasociarlo del rol.</p></div>
<div class="paragraph"><p>Algunos ACLs tienen un icono birrete, lo cual indica que ese ACL viene de un rol heredado. Pasando el ratón por encima nos indicará el rol o roles de los que procede.</p></div>
<div class="paragraph"><p>De este modo, algunos ACLs heredados a través de un rol se pueden desactivar usando la casilla de verificación y otros que no sean heredados se pueden añadir al rol.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Edición
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_edit.png" alt="screenshot_role_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Al editar un rol podremos cambiarle solamente el nombre.</p></div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_vistas_por_defecto">5.4. Vistas por defecto</h3>
<div class="paragraph"><p>Como hemos visto en el análisis de cada sección, las vistas listado muestran varias columnas con diferentes datos de los elementos existentes y además disponen de algunos controles de filtrado.</p></div>
<div class="paragraph"><p>Estas columnas y filtros se puede configurar globalmente en el sistema, y luego cada administrador podrá personalizar estos valores sólamente para él.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_defaultviews.png" alt="screenshot_watconfig_defaultviews.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>En este apartado se realizará la configuración general de estos parámetros marcando una serie de casillas de verificación. Por un lado se configuran las columnas mostradas y por otro los filtros disponibles.</p></div>
<div class="paragraph"><p>En el caso de las <strong>columnas</strong> es una configuración válida para la <strong>versión escritorio</strong>, ya que en la versión móvil se mostrará una versión siempre simplificada. Por otro lado, los <strong>filtros</strong> se configuran independientemente para <strong>escritorio y móvil</strong>. Esta diferenciación se hace para poder hacer la versión móvil más o menos simple según nuestras necesidades.</p></div>
<div class="paragraph"><p>Tras un aviso informativo vemos un menú desplegable con la sección que queremos personalizar y un botón para restaurar las vistas por defecto.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_defaultviews_sections.png" alt="screenshot_watconfig_defaultviews_sections.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Según seleccionemos una u otra sección se cargarán las columnas y filtros de dicha sección. Solamente con hacer click sobre las diferentes casillas de verificación, se guardará el cambio.</p></div>
<div class="paragraph"><p>Si deseamos <strong>volver a la configuración inicial</strong> utilizaremos el botón de <strong>restaurar vistas por defecto</strong>. Esta acción puede realizarse sobre la sección cargada actualmente o sobre todo el sistema, escogiendo una u otra opción en el diálogo que aparece antes de llevarse a cabo la restauración.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_defaultviews_reset.png" alt="screenshot_watconfig_defaultviews_reset.png" width="960px" />
</span></p></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_gestión_de_qvd">6. Gestión de QVD</h2>
<div class="sectionbody">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_config_qvd.png" alt="menu_config_qvd.png" width="600px" />
</span></p></div>
<div class="sect2">
<h3 id="_configuración_de_qvd">6.1. Configuración de QVD</h3>
<div class="paragraph"><p><strong>Los parámetros de QVD están distribuídos</strong> por varios ficheros de configuración y la base de datos. <strong>Desde el WAT</strong>, estos parámetros se muestran de <strong>forma centralizada</strong>, siendo editables cómodamente sin importar su procedencia.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_config.png" alt="screenshot_config.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Los parámetros están clasificados por categorías. Dichas categorías corresponden con el primer segmento del nombre de los parámetros, osea lo inmediatamente anterior al primer punto.</p></div>
<div class="paragraph"><p><em>Por ejemplo, los parámetros que comienzan con “admin.” estarán englobados en la categoría “admin”, como vemos en la captura.</em></p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Navegación y búsqueda
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Se puede navegar por las distintas categorías para editar sus parámetros o bien utilizar el <strong>control de búsqueda</strong> para encontrar los parámetros que contengan una <strong>subcadena</strong>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_config_search.png" alt="screenshot_config_search.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Creación de parámetros
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Se pueden añadir <strong>parámetros nuevos</strong>, que se situarán en la categoría que corresponda con el inicio de su nombre.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_config_custom.png" alt="screenshot_config_custom.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Si no existe la categoría se creará en el menú, y si el nombre del parámetro no contiene puntos formará parte de la categoría especial <em>unclassified</em>.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Eliminado y restauración de parámetros
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Los parámetros añadidos tras la instalación, podrán eliminarse.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_config_delete.png" alt="screenshot_config_delete.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Y los que venían de serie, podrán restaurarse al valor por defecto.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_config_restore.png" alt="screenshot_config_restore.png" width="960px" />
</span></p></div>
</div></div>
</dd>
</dl></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_área_de_usuario">7. Área de usuario</h2>
<div class="sectionbody">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_userarea.png" alt="menu_userarea.png" width="600px" />
</span></p></div>
<div class="sect2">
<h3 id="_perfil">7.1. Perfil</h3>
<div class="paragraph"><p>Es el apartado donde se puede consultar y actualizar la configuración del administrador logueado.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_userarea_profile.png" alt="screenshot_userarea_profile.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Se pueden configurar el idioma  de la interfaz del WAT así como el tamaño de bloque, que corresponde al número de elementos mostrados en cada página en las vistas listado.
Ambos parámetros se pueden definir como <em>por defecto</em> adoptando así la configuración general del WAT, o bien definir un valor fijo para el administrador actual.</p></div>
</div>
<div class="sect2">
<h3 id="_personalizar_vistas">7.2. Personalizar vistas</h3>
<div class="paragraph"><p>Como vimos en la sección de gestión del WAT, se pueden personalizar qué columnas o filtros se muestran en las diferentes vistas del WAT. Esa es una configuración global del sistema.</p></div>
<div class="paragraph"><p>En base a esta configuración, cada administrador puede personalizar sus vistas de un modo muy similar, adaptándolas a sus preferencias.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/important.png" alt="Important" />
</td>
<td class="content">Si un administrador no cambia la configuración de sus vistas, estas podrían variar si la configuración global fuese modificada. Por otro lado, si un administrador cambia un parámetro, éste quedará fijado en el valor establecido, sin ser alterado por los cambios en la configuración global.</td>
</tr></table>
</div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_userarea_customize.png" alt="screenshot_userarea_customize.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>En este apartado se realizará la configuración <strong>para el administrador actual</strong> de estos parámetros marcando una serie de casillas de verificación. Por un lado se configuran las columnas mostradas y por otro los filtros disponibles.</p></div>
<div class="paragraph"><p>En el caso de las <strong>columnas</strong> es una configuración válida para la <strong>versión escritorio</strong>, ya que en la versión móvil se mostrará una versión siempre simplificada. Por otro lado, los <strong>filtros</strong> se configuran independientemente para <strong>escritorio y móvil</strong>. Esta diferenciación se hace para poder hacer la versión móvil más o menos simple según nuestras necesidades.</p></div>
<div class="paragraph"><p>En la sección encontramos un menú desplegable con la sección que queremos personalizar y un botón para restaurar las vistas por defecto.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_defaultviews_sections.png" alt="screenshot_watconfig_defaultviews_sections.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Según seleccionemos una u otra sección se cargarán las columnas y filtros de dicha sección. Solamente con hacer click sobre las diferentes casillas de verificación, se guardará el cambio.</p></div>
<div class="paragraph"><p>Si deseamos <strong>volver a la configuración del sistema</strong> utilizaremos el botón de <strong>restaurar vistas por defecto</strong>. Esta acción puede realizarse sobre la sección cargada actualmente o sobre todo el sistema, escogiendo una u otra opción en el diálogo que aparece antes de llevarse a cabo la restauración.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/important.png" alt="Important" />
</td>
<td class="content">Las vistas que reestablezcamos a la configuración del sistema, volverán a ser susceptibles de los cambios que pueda sufrir la configuración global.</td>
</tr></table>
</div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_userarea_customize_reset.png" alt="screenshot_userarea_customize_reset.png" width="960px" />
</span></p></div>
</div>
<div class="sect2">
<h3 id="_cerrar_sesión">7.3. Cerrar sesión</h3>
<div class="paragraph"><p>Con esta opción se cierra la sesión del administrador actual y aparecerá el login.</p></div>
</div>
</div>
</div>
</div>
<div id="footnotes"><hr /></div>
<div id="footer">
<div id="footer-text">
Last updated 2015-04-28 12:40:58 CEST
</div>
</div>
</body>
</html>
