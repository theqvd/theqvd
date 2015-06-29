<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
<meta name="generator" content="AsciiDoc 8.6.9" />
<title>Guía de usuario</title>
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
<h1>Guía de usuario</h1>
<div id="toc">
  <div id="toctitle">Table of Contents</div>
  <noscript><p><b>JavaScript must be enabled in your browser to display the table of contents.</b></p></noscript>
</div>
</div>
<div id="content">
<div class="sect1">
<h2 id="_primeros_pasos">1. Primeros pasos</h2>
<div class="sectionbody">
<div class="paragraph"><p>Tras una instalación limpia del WAT se habrá creado un administrador de poderes totales. Sus credenciales son:</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Usuario: admin
Contraseña: admin</code></pre>
</div></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">Si solo vamos a tener un administrador del WAT con <em>admin</em> nos valdrá. Si, sin embargo, queremos tener diferentes administradores podemos crearlos con <em>admin</em> con la posibilidad de otorgarles diferentes permisos.</td>
</tr></table>
</div>
<div class="paragraph"><p><strong>Iniciaremos sesión con estas credenciales</strong>.</p></div>
<div class="paragraph"><p>El primer paso que debemos hacer, por seguridad, es <strong>cambiar la contraseña</strong> de nuestra cuenta de administrador.</p></div>
<div class="sect2">
<h3 id="_cambiar_la_contraseña">1.1. Cambiar la contraseña</h3>
<div class="paragraph"><p>Para cambiar la contraseña iremos al <strong>área de administrador</strong>, situada en el <strong>menú general</strong> arriba a la derecha.</p></div>
<div class="ulist"><ul>
<li>
<p>
Haremos click en la opción que lleva el nombre del administrador (en este caso <em>admin</em>) o pasaremos el ratón por encima y del menú desplegable elegiremos la opción <em>Perfil</em>.
</p>
</li>
<li>
<p>
Dentro de nuestro perfil podremos dar al botón de edición situado en la parte derecha de la cabecera bajo el menú.
</p>
</li>
<li>
<p>
Se abrirá un formulario de edición.
</p>
</li>
<li>
<p>
Haremos click en cambiar contraseña y escogeremos nuestra propia contraseña.
</p>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_entorno_inicial">1.2. Entorno inicial</h3>
<div class="paragraph"><p>La primera pantalla tras iniciar sesión corresponde a un <strong>panel con gráficas y estadísticas</strong> del sistema. La primera vez, al ser un sistema nuevo, nos aparecerán todos los <strong>indicadores vacíos</strong>.</p></div>
<div class="paragraph"><p>El menú que nos aparecerá cargado por defecto será el de la Plataforma QVD, que es el eje principal de la administración del QVD. El menú contiene las secciones: <em>usuarios, máquinas virtuales, nodos, OSFs e imágenes de disco</em>.</p></div>
<div class="paragraph"><p>Navegando por las diferentes secciones de la plataforma veremos que no hay nada en ninguna de ellas. Todos los listados aparecerán vacíos.</p></div>
<div class="paragraph"><p>Desde el menú general (arriba a la derecha) podremos acceder a otras partes del WAT que podremos investigar.</p></div>
<div class="paragraph"><p>La parte de gestión del WAT si que contendrá cosas, ya que para que un administrador pueda conectarse al WAT, son imprescindibles una serie de elementos como son la propia cuenta del administrador y al menos un rol que le proporcione permisos.</p></div>
<div class="paragraph"><p>En las diferentes guías iremos moviéndonos por estas secciones para los diferentes cometidos que se propongan, por lo cual conviene familiarizarnos con el entorno.</p></div>
<div class="paragraph"><p>Otro aspecto que nos conviene conocer es la dependencia entre los elementos que podemos crear para no dar palos de ciego al intentar crear unos sin tener los que sean necesarios, etc.</p></div>
</div>
<div class="sect2">
<h3 id="_dependencias_entre_elementos_de_qvd">1.3. Dependencias entre elementos de QVD</h3>
<div class="paragraph"><p>Algunos elementos de QVD tienen dependencia de otros:</p></div>
<div class="ulist"><ul>
<li>
<p>
Una imagen de disco pertenece a un OSF.
</p>
</li>
<li>
<p>
Las máquinas virtuales están asociadas a un usuario.
</p>
</li>
<li>
<p>
Las máquinas virtuales utilizan una imagen de disco.
</p>
</li>
<li>
<p>
Las máquinas virtuales arrancarán en un nodo.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Por lo tanto, deberemos seguir una secuencia lógica para crear los elementos.</p></div>
<div class="paragraph"><p>Lo veremos en el siguiente <strong>árbol de dependencias</strong> donde <strong>cada elemento tiene como hijo otros elementos necesarios para existir</strong>.</p></div>
<div class="ulist"><ul>
<li>
<p>
Máquina virtual
</p>
<div class="ulist"><ul>
<li>
<p>
Nodo(*)
</p>
</li>
<li>
<p>
Usuario
</p>
</li>
<li>
<p>
Imagen de disco
</p>
<div class="ulist"><ul>
<li>
<p>
OSF
</p>
</li>
</ul></div>
</li>
</ul></div>
</li>
</ul></div>
<div class="openblock">
<div class="content">
<div class="literalblock">
<div class="content">
<pre><code>(*) Tener al menos un Nodo no es necesario para la creación de la máquina virtual pero sí para poder arrancarla.</code></pre>
</div></div>
</div></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_crear_una_máquina_virtual_de_cero">2. Crear una máquina virtual de cero</h2>
<div class="sectionbody">
<div class="paragraph"><p>Aprenderemos los pasos para realizar el proceso completo de la creación de una máquina virtual y dejarla a punto para ser utilizada.</p></div>
<div class="paragraph"><p>Las máquinas virtuales utilizan otros elementos, que deberemos crear antes en cierto orden. Para saber más sobre este orden veremos la sección del manual <em>Dependencias entre elementos de QVD</em>.</p></div>
<div class="paragraph"><p>Atendiendo a esto realizaremos los siguientes pasos cuyo orden puede ser ligeramente alterado siempre que respetemos las dependencias:</p></div>
<div class="olist arabic"><ol class="arabic">
<li>
<p>
<strong>Creación de un Nodo</strong>
</p>
</li>
<li>
<p>
<strong>Creación de un OSF</strong>
</p>
</li>
<li>
<p>
<strong>Creación de una imagen de disco</strong>
</p>
</li>
<li>
<p>
<strong>Creación de un usuario</strong>
</p>
</li>
<li>
<p>
<strong>Creación de una máquina virtual</strong>
</p>
</li>
</ol></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/note.png" alt="Note" />
</td>
<td class="content">Las secciones utilizadas en este apartado se describen detalladamente en el apartado <em>Plataforma</em> de la guía <em>El WAT paso a paso</em>.</td>
</tr></table>
</div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/warning.png" alt="Warning" />
</td>
<td class="content">La cuenta de administrador que utilicemos en el WAT para llevar a cabo las siguientes acciones deberá tener los privilegios necesarios. Si no se tuvieran todos, es posible que alguna opción o sección no esté disponible.</td>
</tr></table>
</div>
<div class="sect2">
<h3 id="_creación_de_un_nodo">2.1. Creación de un Nodo</h3>
<div class="paragraph"><p>Un nodo en el WAT corresponde con un <em>servidor QVD</em>, por lo cual tendremos que tener configurado y corriendo un servidor QVD.</p></div>
<div class="paragraph"><p>Además debe ser <em>accesible</em>, debemos <em>conocer su dirección IP</em>.</p></div>
<div class="paragraph"><p>Para crear un nodo seguiremos los siguientes pasos:</p></div>
<div class="ulist"><ul>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
Accederemos al <em>apartado Nodos del menú</em>.
</p>
</li>
<li>
<p>
Haremos click en el botón <em>Nuevo nodo</em>.
</p>
</li>
<li>
<p>
Rellenaremos el formulario de creación.
</p>
<div class="ulist"><ul>
<li>
<p>
Asignaremos un <em>nombre</em> al nodo.
</p>
</li>
<li>
<p>
Asociaremos la <em>dirección IP</em> del servidor QVD.
</p>
</li>
<li>
<p>
Opcionalmente podremos crearle <em>otras propiedades</em> al nodo para gestión interna de nuestros scripts o simplemente añadir información.
</p>
</li>
</ul></div>
</li>
<li>
<p>
Comprobaremos que el nodo se ha creado correctamente viendo que aparece en la vista listado.
</p>
</li>
<li>
<p>
Una vez creado, deberemos comprobar que el nodo se encuentra en el estado <em>Corriendo</em>.
</p>
<div class="ulist"><ul>
<li>
<p>
<em>Desde la vista listado</em>: Aparecerá un icono de play en la columna informativa.
</p>
</li>
<li>
<p>
<em>Desde la vista detalle</em> haciendo click en el nombre del nodo en la vista listado: Entre sus atributos aparece el estado del nodo.
</p>
</li>
</ul></div>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_creación_de_un_osf">2.2. Creación de un OSF</h3>
<div class="paragraph"><p>Los OSFs son la forma de agrupar las imágenes de disco en QVD.</p></div>
<div class="paragraph"><p>Por ello, al menos habrá que tener uno para crear una imagen de disco.</p></div>
<div class="paragraph"><p>Además de agruparlas definen ciertos parámetros en su ejecución, como la memoria o el almacenamiento de usuario.</p></div>
<div class="paragraph"><p>Para crear un OSF seguiremos los siguientes pasos:</p></div>
<div class="ulist"><ul>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
Accederemos al <em>apartado OS Flavours del menú</em>.
</p>
</li>
<li>
<p>
Haremos click en el botón <em>Nuevo OS Flavour</em>.
</p>
</li>
<li>
<p>
Rellenaremos el formulario de creación.
</p>
<div class="ulist"><ul>
<li>
<p>
Asignaremos un <em>nombre</em> al OSF.
</p>
</li>
<li>
<p>
Definiremos la <em>memoria</em> que dispondrán las imágenes asociadas a este OSF. Si dejamos en blanco este campo se asignarán por defecto 256 MB.
</p>
</li>
<li>
<p>
Asignaremos <em>una cuota de almacenamiento de usuario</em> para las imágenes asociadas a este OSF. Si no queremos disponer de esta característica basta con dejar este campo a 0.
</p>
</li>
<li>
<p>
Opcionalmente podremos crearle <em>otras propiedades</em> al OSF para gestión interna de nuestros scripts o simplemente añadir información.
</p>
</li>
</ul></div>
</li>
<li>
<p>
Comprobaremos que el OSF se ha creado correctamente viendo que aparece en la vista listado.
</p>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_creación_de_una_imagen_de_disco">2.3. Creación de una imagen de disco</h3>
<div class="paragraph"><p>La creación de las imágenes de disco que serán montadas por QVD se realiza en dos partes:</p></div>
<div class="ulist"><ul>
<li>
<p>
La subida de la imagen al servidor del WAT.
</p>
</li>
<li>
<p>
La creación de la imagen en el WAT seleccionando una imagen de entre las subidas.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Uniendo estos dos pasos, deberemos seguir los siguientes pasos:</p></div>
<div class="ulist"><ul>
<li>
<p>
Subir, utilizando scp o cualquier otro método válido, la imagen que deseemeos al directorio <em>staging</em> del servidor del WAT. Las imágenes de este directorio serán las seleccionables en el proceso de creación desde el WAT.
</p>
</li>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
La creación de la imagen se puede realizar por <em>dos vias</em>:
</p>
<div class="openblock">
<div class="content">
<div class="dlist"><dl>
<dt class="hdlist1">
Desde la sección <em>Imágenes de disco</em>
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Accederemos al <em>apartado Imágenes de disco del menú</em>.
</p>
</li>
<li>
<p>
Haremos click en el botón <em>Nueva Imagen de disco</em>.
</p>
</li>
<li>
<p>
Rellenaremos el formulario de creación.
</p>
<div class="ulist"><ul>
<li>
<p>
Seleccionaremos <em>la imagen de disco</em>. En este menú desplegable aparecerán las imágenes previamente subidas al directorio <em>staging</em> del servidor del WAT.
</p>
</li>
<li>
<p>
Podemos definir una <em>versión de la imagen</em>. Si dejamos este campo en blanco se generará una versión automática basada en la fecha de creación (Ej.: 2015-05-03-000).
</p>
</li>
<li>
<p>
Seleccionamos el <em>OSF</em> al que se asociará la imagen.
</p>
</li>
<li>
<p>
Se puede definir que la imagen sea la <em>imagen por defecto</em> del OSF. Si es la primera imagen que se crea en un OSF, este campo no tendrá relevancia, ya que si solo hay una imagen en un OSF, ésta será la imagen por defecto.
</p>
</li>
<li>
<p>
Opcionalmente se le pueden asignar <em>tags</em> a la imagen para poder identificarla desde el gestor de máquinas virtuales. Estos tags son únicos por OSF. Si asignamos un tag que ya tiene otra imagen del mismo OSF, el tag será cambiado de imagen, evitando la duplicidad.
</p>
</li>
<li>
<p>
Opcionalmente podremos crearle <em>otras propiedades</em> a la imagen para gestión interna de nuestros scripts o simplemente añadir información.
</p>
</li>
</ul></div>
</li>
<li>
<p>
Comprobaremos que la imagen se ha creado correctamente viendo que aparece en la vista listado.
</p>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Desde la sección <em>OS Flavours</em>
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Accederemos al <em>apartado OS Flavours del menú</em>.
</p>
</li>
<li>
<p>
Escogemos el OSF al que queremos asociar la nueva imagen de disco y hacemos click en su nombre para acceder a su vista detalle.
</p>
</li>
<li>
<p>
En la parte derecha de la vista, encontramos un cuadro con las imágenes de disco asociadas al OS Flavour. Haremos click en el botón Nueva Imagen de disco situado en ese cuadro.
</p>
</li>
<li>
<p>
Rellenaremos el formulario de creación.
</p>
<div class="ulist"><ul>
<li>
<p>
Seleccionaremos <em>la imagen de disco</em>. En este menú desplegable aparecerán las imágenes previamente subidas al directorio <em>staging</em> del servidor del WAT.
</p>
</li>
<li>
<p>
Podemos definir una <em>versión de la imagen</em>. Si dejamos este campo en blanco se generará una versión automática basada en la fecha de creación (Ej.: 2015-05-03-000).
</p>
</li>
<li>
<p>
Se puede definir que la imagen sea la <em>imagen por defecto</em> del OSF. Si es la primera imagen que se crea en un OSF, este campo no tendrá relevancia, ya que si solo hay una imagen en un OSF, ésta será la imagen por defecto.
</p>
</li>
<li>
<p>
Opcionalmente se le pueden asignar <em>tags</em> a la imagen para poder identificarla desde el gestor de máquinas virtuales. Estos tags son únicos por OSF. Si asignamos un tag que ya tiene otra imagen del mismo OSF, el tag será cambiado de imagen, evitando la duplicidad.
</p>
</li>
<li>
<p>
Opcionalmente podremos crearle <em>otras propiedades</em> a la imagen para gestión interna de nuestros scripts o simplemente añadir información.
</p>
</li>
</ul></div>
</li>
<li>
<p>
Comprobaremos que la imagen se ha creado correctamente viendo que aparece en el cuadro de Imágenes de disco dentro de la vista detalle en la que nos encontramos.
</p>
</li>
</ul></div>
</div></div>
</dd>
</dl></div>
</div></div>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_creación_de_un_usuario">2.4. Creación de un usuario</h3>
<div class="paragraph"><p>Toda máquina virtual estará asignada a un usuario, por lo que tendremos que tener al menos uno en el sistema.</p></div>
<div class="paragraph"><p>Para crear un usuario seguiremos los siguientes pasos:</p></div>
<div class="ulist"><ul>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
Accederemos al <em>apartado Usuarios del menú</em>.
</p>
</li>
<li>
<p>
Haremos click en el botón <em>Nuevo Usuario</em>.
</p>
</li>
<li>
<p>
Rellenaremos el formulario de creación.
</p>
<div class="ulist"><ul>
<li>
<p>
Asignaremos un <em>nombre</em> al Usuario. Este nombre será único en el sistema.
</p>
</li>
<li>
<p>
Le asignaremos una contraseña. Esta contraseña será la que el usuario utilice para conectarse a sus máquinas virtuales.
</p>
</li>
<li>
<p>
Opcionalmente podremos crearle <em>otras propiedades</em> al OSF para gestión interna de nuestros scripts o simplemente añadir información.
</p>
</li>
</ul></div>
</li>
<li>
<p>
Comprobaremos que el usuario se ha creado correctamente viendo que aparece en la vista listado.
</p>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_creación_de_una_máquina_virtual">2.5. Creación de una máquina virtual</h3>
<div class="paragraph"><p>Teniendo ya creado al menos un usuario y una imagen de disco, ya es posible crear una máquina virtual.</p></div>
<div class="paragraph"><p>La creación de máquinas virtuales se puede llevar a cabo desde dos pantallas:</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Desde la vista listado de máquinas virtuales
</dt>
<dd>
<div class="ulist"><ul>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
Accederemos al <em>apartado Máquinas virtuales del menú</em>.
</p>
</li>
<li>
<p>
Haremos click en el botón <em>Nueva Máquina virtual</em>.
</p>
</li>
<li>
<p>
Rellenaremos el formulario de creación.
</p>
<div class="ulist"><ul>
<li>
<p>
Asignaremos un <em>nombre</em> a la máquina virtual.
</p>
</li>
<li>
<p>
Escogeremos el <em>usuario</em> al que queremos asignar la máquina virtual. Este dato no podrá ser cambiado más adelante.
</p>
</li>
<li>
<p>
Escogeremos el <em>OSF</em> que deseemos. Este dato no podrá ser cambiado más adelante.
</p>
</li>
<li>
<p>
Escogeremos el <em>tag de la imagen</em> que queremos usar en la máquina virtual. En este control se encontrarán las versiones y tags de las imágenes pertenecientes al OSF seleccionado en el control anterior del formulario, así como los tags especiales <em>head</em> y <em>default</em> que servirán para utilizar la última imagen creada del OSF y la establecida como imagen por defecto en el OSF respectivamente.
</p>
</li>
<li>
<p>
Opcionalmente podremos crearle <em>otras propiedades</em> a la Máquina virtual para gestión interna de nuestros scripts o simplemente añadir información.
</p>
</li>
</ul></div>
</li>
<li>
<p>
Comprobaremos que la máquina virtual se ha creado correctamente viendo que aparece en la vista listado.
</p>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Desde la vista detalle de un usuario
</dt>
<dd>
<div class="ulist"><ul>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
Accederemos al <em>apartado Usuarios del menú</em>.
</p>
</li>
<li>
<p>
Escogemos el usuario al que queremos asociar la nueva máquina virtual y hacemos click en su nombre para acceder a su vista detalle.
</p>
</li>
<li>
<p>
En la parte derecha de la vista, encontramos un cuadro con las máquinas virtuales asociadas al usuario. Haremos click en el botón <em>Nueva Máquina virtual</em> situado en ese cuadro.
</p>
</li>
<li>
<p>
Rellenaremos el formulario de creación.
</p>
<div class="ulist"><ul>
<li>
<p>
Asignaremos un <em>nombre</em> a la máquina virtual.
</p>
</li>
<li>
<p>
Escogeremos el <em>OSF</em> que deseemos. Este dato no podrá ser cambiado más adelante.
</p>
</li>
<li>
<p>
Escogeremos el <em>tag de la imagen</em> que queremos usar en la máquina virtual. En este control se encontrarán las versiones y tags de las imágenes pertenecientes al OSF seleccionado en el control anterior del formulario, así como los tags especiales <em>head</em> y <em>default</em> que servirán para utilizar la última imagen creada del OSF y la establecida como imagen por defecto en el OSF respectivamente.
</p>
</li>
<li>
<p>
Opcionalmente podremos crearle <em>otras propiedades</em> a la Máquina virtual para gestión interna de nuestros scripts o simplemente añadir información.
</p>
</li>
</ul></div>
</li>
<li>
<p>
Comprobaremos que la máquina virtual se ha creado correctamente viendo que aparece en el cuadro de máquinas virtuales asociadas al usuario.
</p>
</li>
</ul></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_arrancado_de_una_máquina_virtual">2.6. Arrancado de una máquina virtual</h3>
<div class="paragraph"><p>Una vez creada la máquina virtual, necesitamos arrancarla para que el usuario se pueda conectar a ella.</p></div>
<div class="paragraph"><p>Una máquina virtual se puede arrancar desde dos pantallas:</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Desde la vista detalle de la máquina virtual
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Los pasos son:</p></div>
<div class="ulist"><ul>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
Accederemos al <em>apartado Máquinas virtuales del menú</em>.
</p>
</li>
<li>
<p>
Escogemos la máquina virtual que queremos arrancar y hacemos click en su nombre para acceder a su vista detalle.
</p>
</li>
<li>
<p>
En la parte derecha localizamos el panel de estado de ejecución.
</p>
</li>
<li>
<p>
Hacemos click en el botón de arrancar la máquina virtual situado a la derecha del panel de estado de ejecución.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Observamos como el panel de estado de ejecución cambia de <em>Detenido</em> a <em>Arrancando</em>.</p></div>
<div class="paragraph"><p>Este proceso <em>puede tardar</em> en completarse, <em>especialmente si es la primera vez</em> que arrancamos una máquina.</p></div>
<div class="paragraph"><p>Cuando el proceso acabe, el panel de estado de ejecución cambiará mostrando que la máquina está corriendo y el nombre del Nodo donde corre. Además se podrán desplegar los parámetros de ejecución. Estos valores, como la dirección IP o la imagen de disco utilizadas, no cambiarán mientras la máquina esté en ejecución aunque se editen dichos valores en la máquina virtual.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Desde la vista listado de máquinas virtuales
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Esta vía permite arrancar varias máquinas virtuales a la vez, aunque en este caso lo utilizaremos como un método cómodo de arrancar una sola máquina virtual.</p></div>
<div class="paragraph"><p>Los pasos son:</p></div>
<div class="ulist"><ul>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
Accederemos al <em>apartado Máquinas virtuales del menú</em>.
</p>
</li>
<li>
<p>
Seleccionaremos la máquina virtual que queramos arrancar marcando la casilla de verificación correspondiente de la primera columna en la lista.
</p>
</li>
<li>
<p>
Bajo la lista de máquinas virtuales, en el control de acciones sobre elementos seleccionados, escogemos <em>Arrancar</em>.
</p>
</li>
<li>
<p>
Hacemos click en el botón <em>Aplicar</em>.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Observarmos como, en la columna informativa del elemento seleccionado, cambia el icono de stop a un icono animado que nos indica que la máquina está en proceso de arrancado. Si se encuentra visibe la columna con el Nodo asociado a la máquina, esta cambiará en este momento mostrando el Nodo donde la máquina está arrancando.</p></div>
<div class="paragraph"><p>Este proceso <em>puede tardar</em> en completarse, <em>especialmente si es la primera vez</em> que arrancamos una máquina.</p></div>
<div class="paragraph"><p>Cuando el proceso acabe, el icono cambiará a un icono de play, que nos indicará que la máquina virtual ha arrancado.</p></div>
<div class="paragraph"><p>Si en vez de el icono de play, vuelve a aparecer el icono de stop, significará que ha habido algún problema con el arrancado de la máquina y se ha detenido. Esto puede suceder por múltiples causas, y habrá que investigar en el servidor de QVD lo sucedido.</p></div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_conexión_del_usuario">2.7. Conexión del usuario</h3>
<div class="paragraph"><p>Una vez tengamos la máquina virtual arrancada, el usuario ya podrá conectarse a ella.</p></div>
<div class="paragraph"><p>Para ello utilizará el cliente de QVD y se conectará utilizando la dirección del servidor y el usuario/contraseña que se le asignaron desde el WAT.</p></div>
<div class="paragraph"><p>Cuando el cliente está conectado, esto se refleja en las vistas listado y detalle de las máquinas virtuales.</p></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_actualización_de_imagen">3. Actualización de imagen</h2>
<div class="sectionbody">
<div class="paragraph"><p>Veremos cómo se actualiza la imagen utilizada por una máquina virtual.</p></div>
<div class="paragraph"><p>El proceso consiste en crear una imagen con la nueva versión que queramos utilizar y cambiar la imagen asignada a la máquina virtual por la nueva.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/note.png" alt="Note" />
</td>
<td class="content">Las secciones utilizadas en este apartado se describen detalladamente en el apartado <em>Plataforma</em> de la guía <em>El WAT paso a paso</em>.</td>
</tr></table>
</div>
<div class="sect2">
<h3 id="_creación_de_nueva_imagen_de_disco">3.1. Creación de nueva imagen de disco</h3>
<div class="paragraph"><p>Debemos crear una nueva imagen de disco en el WAT con la versión de la imagen que queramos utilizar en lugar de la actual.</p></div>
<div class="paragraph"><p><strong>Es importante que creemos la imagen en el OSF asociado a la máquina virtual.</strong></p></div>
<div class="paragraph"><p>El proceso de creación de una imagen de disco se puede encontrar de forma detallada en el apartado <em>Creación de una imagen de disco</em> del manual.</p></div>
</div>
<div class="sect2">
<h3 id="_asignación_de_nueva_imagen">3.2. Asignación de nueva imagen</h3>
<div class="paragraph"><p>Hay varias formas de gestionar las imágenes asociadas a las máquinas virtuales.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Teniendo asignado a la máquina virtual el tag <em>head</em>
</dt>
<dd>
<p>
Si la máquina virtual tiene asignado el tag <em>head</em> siempre tendrá asociada la última imagen creada del OSF, por lo que con crearla bastará.
</p>
</dd>
<dt class="hdlist1">
Teniendo asignado a la máquina virtual el tag <em>default</em>
</dt>
<dd>
<p>
Si la máquina virtual tiene asignado el tag <em>default</em> tendrá asociada la imagen marcada como imagen por defecto en el OSF. Deberemos marcar la imagen que queramos como imagen por defecto si queremos que esta máquina virtual sea asociada a la nueva imagen.
</p>
</dd>
<dt class="hdlist1">
Teniendo asignado a la máquina virtual otro tag
</dt>
<dd>
<p>
Si en la máquina virtual tenemos asignado un tag identificativo de la imagen que ejecuta, deberemos cambiar este tag para seleccionar la nueva imagen en lugar de la actual.
</p>
</dd>
</dl></div>
<div class="sect3">
<h4 id="_cambio_de_tag_en_máquina_virtual">3.2.1. Cambio de tag en máquina virtual</h4>
<div class="paragraph"><p>Para cambiar de tag asociado a una máquina virtual hay que seguir los siguientes pasos:</p></div>
<div class="ulist"><ul>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
Accederemos al <em>apartado Máquinas virtuales del menú</em>.
</p>
</li>
<li>
<p>
Escogemos la máquina virtual que queremos editar y hacemos click en su nombre para acceder a su vista detalle.
</p>
</li>
<li>
<p>
En la vista detalle, a la derecha del nombre de la máquina virtual, entre los botones de acción, hacemos click en el <em>botón de Edición</em>.
</p>
</li>
<li>
<p>
En el formulario de edición cambiamos el tag de imagen y seleccionamos la versión de la nueva imagen de disco creada o bien alguno de sus tags.
</p>
</li>
<li>
<p>
Hacemos click en <em>Actualizar</em>
</p>
</li>
</ul></div>
<div class="paragraph"><p>Para comprobar que el cambio se ha hecho efectivo, observamos que en los atributos de la máquina virtual aparece el tag de imagen que hemos seleccionado y la imagen de disco correcta. Debe salir la última que hemos creado.</p></div>
<div class="paragraph"><p>Si la máquina está corriendo, podemos ver los parámetros de ejecución en el panel de estado de ejecución y comprobar que ahí sigue saliendo la imagen antigua, ya que <em>el cambio de imagen no se puede hacer en caliente, hará falta reiniciar la máquina virtual</em>.</p></div>
</div>
<div class="sect3">
<h4 id="_cambio_de_imagen_por_defecto">3.2.2. Cambio de imagen por defecto</h4>
<div class="paragraph"><p>Una imagen se puede establecer como imagen por defecto en varias pantallas.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Desde la vista detalle de la imagen
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
Accederemos al <em>apartado Imágenes de disco del menú</em>.
</p>
</li>
<li>
<p>
Escogemos la imagen que queremos establecer como imagen por defecto y hacemos click en su nombre para acceder a su vista detalle.
</p>
</li>
<li>
<p>
En la vista detalle, a la derecha del nombre de la imagen, entre los botones de acción, hacemos click en el <em>botón de Edición</em>.
</p>
</li>
<li>
<p>
En el formulario de edición activamos la casilla de verificación de <em>por defecto</em>.
</p>
</li>
<li>
<p>
Hacemos click en <em>Actualizar</em>
</p>
</li>
</ul></div>
<div class="paragraph"><p>Para comprobar que el cambio se ha hecho efectivo, observamos que en los atributos de la imagen aparece un atributo "Por defecto" avisándonos que esta es la imagen pro defecto de su OSF.</p></div>
<div class="paragraph"><p>Si ahora vamos a la vista detalle de la máquina virtual, observaremos que en sus atributos aparece la imagen de disco que acabamos de editar.</p></div>
<div class="paragraph"><p>Si la máquina está corriendo, como vimos con anterioridad, en los parámetros de ejecución aún saldrá la imagen anterior hasta que la reiniciemos.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Desde la vista detalle del OSF
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Nos situaremos en la <em>sección Plataforma</em>. Esta es la sección activa por defecto tras iniciar sesión.
</p>
</li>
<li>
<p>
Accederemos al <em>apartado OS Flavours del menú</em>.
</p>
</li>
<li>
<p>
Escogemos el OSF al que pertenece la imagen que queremos establecer como imagen por defecto y hacemos click en su nombre para acceder a su vista detalle.
</p>
</li>
<li>
<p>
A la derecha de la vista detalle del OSF hay un cuadro con las imágenes asociadas al OSF. Una de las columnas de este listado son casillas de verificación para establecer una imagen como imagen por defecto. Hacemos click en la casilla de verificación de la imagen.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Para comprobar que el cambio se ha hecho efectivo, observamos que en la columna informativa de la lista de imágenes de disco ha cambiado la imagen que tiene el icono que indica la imagen por defecto.</p></div>
<div class="paragraph"><p>Si ahora vamos a la vista detalle de la máquina virtual, observaremos que en sus atributos aparece la imagen de disco que acabamos de editar.</p></div>
<div class="paragraph"><p>Si la máquina está corriendo, como vimos con anterioridad, en los parámetros de ejecución aún saldrá la imagen anterior hasta que la reiniciemos.</p></div>
</div></div>
</dd>
</dl></div>
</div>
</div>
<div class="sect2">
<h3 id="_reiniciar_máquina_virtual">3.3. Reiniciar máquina virtual</h3>
<div class="paragraph"><p>Para que se haga efectivo el cambio de imagen, tendremos que parar y volver a arrancar la máquina.</p></div>
<div class="paragraph"><p>La parada de una máquina virtual se realiza de forma idéntica al arrancado. Podemos ver este proceso de forma detallada en el apartado <em>Arrancado de una máquina virtual</em> del manual.</p></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_situaciones_de_bloqueo">4. Situaciones de bloqueo</h2>
<div class="sectionbody">
<div class="paragraph"><p>Hay diferentes situaciones en las que por un error de configuración o un descuido, podemos perder alguna funcionalidad. A esto le llamaremos situación de bloqueo.</p></div>
<div class="paragraph"><p>Veremos algunas de las situaciones que pueden darse, ya que puede haber más, y cómo solucionarlas.</p></div>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Borrar el único administrador ya que no podríamos gestionar el WAT puesto que para crear un administrador es necesario otro administrador.
</p>
</li>
<li>
<p>
Modificar los permisos de tal manera que no quede ningún administrador que pueda gestionar los permisos.
</p>
</li>
<li>
<p>
Olvidar la contraseña del único administrador que pueda gestionar los permisos.
</p>
</li>
</ul></div>
</div></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Solución
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Para recuperar las funcionalidades perdidas podremos acceder al WAT en un modo especial. El uso de este modo lo encontraremos en la guía Modo de recuperación.</p></div>
</div></div>
</dd>
</dl></div>
</div>
</div>
<div class="sect1">
<h2 id="_modo_de_recuperación">5. Modo de recuperación</h2>
<div class="sectionbody">
<div class="paragraph"><p>Debido a algun cambio de configuración, de permisos o por el olvido de alguna contraseña, nos podemos ver en la situación de pérdida de funcionalidades.</p></div>
<div class="paragraph"><p>Esta situación se dará cuando no tengamos ningún administrador con la capacidad de gestionar permisos, ya que en caso contrario los podremos recuperar.</p></div>
<div class="paragraph"><p>Para restaurar las funcionalidades perdidas, el WAT dispone de un administrador especial de recuperación. Sus credenciales son:</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Usuario: batman
Contraseña: to the rescue</code></pre>
</div></div>
<div class="paragraph"><p>Este administrador tiene las siguientes características:</p></div>
<div class="ulist"><ul>
<li>
<p>
No aparecerá en la lista de administradores del sistema.
</p>
</li>
<li>
<p>
No se puede visualizar o alterar como otros administradores.
</p>
</li>
<li>
<p>
Tiene unos permisos predefinidos inalterables:
</p>
<div class="ulist"><ul>
<li>
<p>
Gestión de WAT: Configuración, Administradores, Roles.
</p>
</li>
<li>
<p>
Gestión de QVD: Configuración.
</p>
</li>
</ul></div>
</li>
</ul></div>
<div class="paragraph"><p>De esta forma, cuando nos veamos en una situación de bloqueo, podremos entrar con el administrador de recuperación y solucionarla, por ejemplo, con las siguientes acciones:</p></div>
<div class="ulist"><ul>
<li>
<p>
Cambiar la contraseña extraviada
</p>
</li>
<li>
<p>
Otorgar los permisos perdidos a un administrador
</p>
</li>
<li>
<p>
Crear un administrador que hayamos podido eliminar
</p>
</li>
<li>
<p>
&#8230;
</p>
</li>
</ul></div>
</div>
</div>
<div class="sect1">
<h2 id="_gestionar_administradores_y_permisos">6. Gestionar Administradores y Permisos</h2>
<div class="sectionbody">
<div class="paragraph"><p>La gestión de administradores y permisos está enmarcada dentro de la sección general <strong>Gestión del WAT</strong>.</p></div>
<div class="paragraph"><p>Las dos secciones útiles para esta gestión son:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Administradores</strong>: Creación/Borrado de administradores así como asignación de permisos.
</p>
</li>
<li>
<p>
<strong>Roles</strong>: Gestión de roles.
</p>
</li>
</ul></div>
<div class="paragraph"><p>QVD cuenta por defecto con algunos <strong>roles predefinidos</strong> que nos pueden ser útiles si no necesitamos permisos muy específicos.</p></div>
<div class="paragraph"><p>Es el caso del <strong>rol “Root”</strong>, que contiene todos los ACLs del sistema. Es el rol asociado al usuario “admin” creado por defecto en WAT.</p></div>
<div class="sect2">
<h3 id="_gestión_de_administradores">6.1. Gestión de administradores</h3>
<div class="paragraph"><p>La acción de crear un administrador solamente nos permitirá asignarle un nombre de usuario y una contraseña. Para que pueda acceder al WAT será necesario asignarle al menos un rol.</p></div>
<div class="paragraph"><p>El proceso será:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Crear el administrador con el botón “Nuevo administrador”</strong> de la vista listado de administradores. Escogeremos una contraseña sencilla para que al administrador no le cueste mucho iniciar sesión, aunque le advertiremos que deberá cambiarla por una contraseña personal.
</p>
</li>
<li>
<p>
<strong>Tras la creación</strong>, el administrador aparecerá en la lista. En la columna de información del administrador recién creado aparecerá un icono de advertencia al no tener ningún rol asociado. <strong>Haremos click en el nombre</strong> para acceder a la vista detalle.
</p>
</li>
<li>
<p>
En la vista detalle encontraremos un bloque con los roles asignados. Aparecerá vacío.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><strong>Asignaremos los roles que consideremos necesarios</strong>. Veremos como aparecen en la lista de roles asignados.</p></div>
<div class="paragraph"><p>Además, tendremos como apoyo un árbol de ACLs que tiene asignados el administrador en cada momento. Éste árbol tiene dos modalidades que analizaremos en la gestión de roles.</p></div>
<div class="paragraph"><p>Observando como aparecen/desaparecen ACLs en el árbol al asignar/desasignar roles, veremos exactamente qué permisos estamos dándole al administrador.</p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>Para nuestros primeros administradores podemos utilizar los roles disponibles por defecto en el sistema.</p></div>
<div class="paragraph"><p><span class="yellow-background">TODO: Cuando estén definidos los roles predefinidos del sistema, explicar con ejemplos la creación de algunos administradores útiles.</span></p></div>
<div class="paragraph"><p>Cuando nos surja la necesidad de crear administradores con permisos más específicos, será cuando necesitemos abordar la gestión de roles.</p></div>
</div>
<div class="sect2">
<h3 id="_gestión_de_roles">6.2. Gestión de roles</h3>
<div class="paragraph"><p>En la búsqueda de administradores con permisos personalizados, crearemos aquellos roles que necesitemos. Para facilitar nuestra labor, una buena estrategia será crear roles reutilizables, buscando que tengan los ACLs comunes que queremos para un conjunto de administradores.</p></div>
<div class="paragraph"><p>Al igual que con los administradores, al crear un rol, se creará vacío y tendremos que editarlo para asignarle ACLs.</p></div>
<div class="paragraph"><p>El proceso será:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Crear el rol con el botón “Nuevo rol”</strong> de la vista listado de roles. Escogeremos un nombre que tenga alguna relación con los permisos que va a tener para que sea fácilmente entendible en el futuro.
</p>
<div class="openblock">
<div class="content">
<div class="literalblock">
<div class="content">
<pre><code>Por ejemplo: Provisionador de usuarios</code></pre>
</div></div>
</div></div>
</li>
<li>
<p>
<strong>Tras la creación</strong>, el rol aparecerá en la lista. En las columnas de recuento de ACLs y Roles heredados de cada rol, aparecerá un 0. <strong>Haremos click en el nombre</strong> para acceder a la vista detalle.
</p>
</li>
<li>
<p>
En la vista detalle tenemos <strong>dos herramientas</strong> disponibles:
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
<strong>Herencia de ACLs</strong>: Se podrán heredar grupos de ACLs.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Para facilitar la tediosa labor de asignar ACLs a un rol, se pueden crear vínculos de herencia entre grupos de ACLs.</p></div>
<div class="paragraph"><p>Existen dos tipos de grupos de ACLs de los que se puede heredar:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Roles</strong>: Serán todos aquellos roles del WAT, ya vengan por defecto o se hayan creado posteriormente.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Son los roles normales que <strong>se muestran en la lista de roles</strong> y a parte de poder heredarse, se pueden asignar a los administradores.</p></div>
<div class="paragraph"><p>Existe una <strong>protección frente a bucles infinitos de herencia</strong> por la que <em>un rol A no puede heredar de un rol B si el rol B ya hereda del rol A</em>.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Plantillas</strong>: Las plantillas son agrupaciones de ACLs cuyo único objetivo es ser heredadas por los roles. <strong>Su utilización es recomendada</strong> por razones de mantenibilidad.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Los nombres de las plantillas son descriptivos de los ACLs que poseen, haciendo referencia normalmente a qué elementos afectan y en qué grado.</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Por ejemplo: Users Creator, Images Operator, VMs Manager, Roles Eraser...</code></pre>
</div></div>
<div class="paragraph"><p>En las <strong>futuras actualizaciones</strong> del WAT puedan aparecer <strong>nuevos ACLs</strong>. Para evitar tener que re-configurar los ACLs de nuestros administradores tras una actualización, <strong>se recomienda utilizar la herencia de Plantillas</strong> para configurar nuestros roles. Estos roles, serán actualizados con el WAT, conteniendo los nuevos ACLs de una forma coherente con su uso.</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Por ejemplo: Si se añadie un nuevo campo en la vista de usuarios, el ACL que permita su visualización será añadido el rol interno Users Reader. Los roles que hereden de este rol interno, se actualizarán y tendrán automáticamente dicho nuevo acceso.</code></pre>
</div></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>Cuando heredemos un rol o plantilla, observaremos como en el árbol de ACLs cambia, activándose los nuevos ACLs, sirviéndonos de guía sobre cuanto nos estamos acercando a los ACLs deseados a medida que configuramos el rol.</p></div>
<div class="paragraph"><p>Una ventaja de la herencia es que si en el futuro <strong>cambian los ACLs de un rol</strong>, todos los que lo hereden sufrirán sus cambios con él. Por eso hay que utilizar esta técnica con cuidado.</p></div>
<div class="paragraph"><p>Para conocer los roles y plantillas que una instalación de QVD incluye, ver la guía de usuario: <em>Referencia de ACLs Plantillas y Roles</em>.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Árbol de ACLs</strong>: Se mostrarán los ACLs del sistema en forma de árbol con casillas de verificación.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Seleccionaremos aquellos ACLs que queremos que el rol contenga, y así mismo deseleccionaremos los que queramos que deje de contener, hayan sido añadidos manualmente o provengan de la herencia de un rol o plantilla.</p></div>
<div class="paragraph"><p>Las ramas, a su vez, también disponen de casilla de verificación para seleccionar/deseleccionar ramas enteras con un solo click.</p></div>
<div class="paragraph"><p>Junto a cada ACL que provenga de un rol o plantilla heredado, aparecerá un icono. Al pasar el ratón sobre él nos aparecerá información a cerca de qué rol o plantilla procede.</p></div>
<div class="paragraph"><p><strong>Un ACL puede provenir de varios roles o plantillas</strong> si éstos tienen ACLs en común. Esto no tiene importancia más alla de que si dejamos de heredar un rol o plantilla de los que nos proporcionan estos ACLs no estaremos quitando el ACL, ya que aún permanecería heredado por otros. No obstante, ese ACL, como los demás, podrá ser eliminado manualmente deseleccionándolo desde el árbol de ACLs sin importar de cuantos roles o plantillas provenga.</p></div>
<div class="paragraph"><p>Según nuestras preferencias, podemos representar el árbol en <strong>dos clasificaciones</strong> distintas:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Por secciones</strong>: Si deseamos agrupar los ACLs según las secciones del WAT a las que afectan: usuarios, máquinas virtuales, nodos, administradores&#8230;
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Útil si queremos crear un rol que otorgue permisos con <strong>mucha profundidad pero poca amplitud</strong>.</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Por ejemplo, permisos totales en usuarios y máquinas virtuales.</code></pre>
</div></div>
</div></div>
</li>
<li>
<p>
<strong>Por acciones</strong>: Si nos es más cómodo agrupar los ACLs según el tipo de acción que permiten: crear, eliminar, acceder a vista principal, filtrar&#8230;
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Útil si queremos crear un rol que otorgue permisos con <strong>poca profundidad y mucha amplitud</strong>.</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Por ejemplo, permisos de solo lectura en casi todas las secciones.</code></pre>
</div></div>
</div></div>
</li>
</ul></div>
</div></div>
</li>
</ul></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>Hay que tener cuidado con la gestión de administradores y permisos ya que si realizamos una acción equivocada, podríamos perder funcionalidades e incluso el acceso al WAT. Ver la sección <em>Situaciones de bloqueo</em> en el manual.</p></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_referencia_de_acls_plantillas_y_roles">7. Referencia de ACLs, Plantillas y Roles</h2>
<div class="sectionbody">
<div class="paragraph"><p>En la siguiente guía de referencia se describen los diferentes ACLs del sistema así como las Plantillas y los Roles predefinidos.</p></div>
<div class="sect2">
<h3 id="_referencia_de_acls">7.1. Referencia de ACLs</h3>
<div class="paragraph"><p>Lista de ACLs repartidos por los distintos tipos de objetos a los que afectan. Cada categoría tiene una tabla donde hay una descipción corta, el código interno y una descripción más detallada para cada uno de los ACLs.</p></div>
<div class="sect3">
<h4 id="_acls_de_usuarios">7.1.1. ACLs de Usuarios</h4>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="33%" />
<col width="33%" />
<col width="33%" />
<thead>
<tr>
<th align="left" valign="top">ACL    </th>
<th align="left" valign="top">ACL code       </th>
<th align="left" valign="top">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create users</strong></p></td>
<td align="left" valign="top"><p class="table">user.create.</p></td>
<td align="left" valign="top"><p class="table">Creation of users including initial settings for name and password.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set properties on users in creation</strong></p></td>
<td align="left" valign="top"><p class="table">user.create.properties</p></td>
<td align="left" valign="top"><p class="table">Setting of custom properties in the creation process of users.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete users (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">user.delete-massive.</p></td>
<td align="left" valign="top"><p class="table">Deletion of users massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete users</strong></p></td>
<td align="left" valign="top"><p class="table">user.delete.</p></td>
<td align="left" valign="top"><p class="table">Deletion of users one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter users by blocking status</strong></p></td>
<td align="left" valign="top"><p class="table">user.filter.block</p></td>
<td align="left" valign="top"><p class="table">Filter of users list by disk image&#8217;s blocking status</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter users by creator</strong></p></td>
<td align="left" valign="top"><p class="table">user.filter.created-by</p></td>
<td align="left" valign="top"><p class="table">Filter of users list by administrator who created it</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter users by creation date</strong></p></td>
<td align="left" valign="top"><p class="table">user.filter.creation-date</p></td>
<td align="left" valign="top"><p class="table">Filter of users list by date when it was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter users by name</strong></p></td>
<td align="left" valign="top"><p class="table">user.filter.name</p></td>
<td align="left" valign="top"><p class="table">Filter of users list by user&#8217;s name.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter users by properties</strong></p></td>
<td align="left" valign="top"><p class="table">user.filter.properties</p></td>
<td align="left" valign="top"><p class="table">Filter of users list by desired custom property.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to user&#8217;s details view</strong></p></td>
<td align="left" valign="top"><p class="table">user.see-details.</p></td>
<td align="left" valign="top"><p class="table">This ACL grants the access to the details view. The minimum data on it is name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to user&#8217;s main section</strong></p></td>
<td align="left" valign="top"><p class="table">user.see-main.</p></td>
<td align="left" valign="top"><p class="table">This ACL grants the access to the list. The minimum data on it is name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user&#8217;s blocking state</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.block</p></td>
<td align="left" valign="top"><p class="table">Blocking state (blocked/unblocked) of users</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user&#8217;s creator</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.created-by</p></td>
<td align="left" valign="top"><p class="table">WAT administrator who created a user.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user&#8217;s creation date</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.creation-date</p></td>
<td align="left" valign="top"><p class="table">Datetime when a user was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user&#8217;s ID</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.id</p></td>
<td align="left" valign="top"><p class="table">The database identiefier of the users. Useful to make calls from CLI.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user&#8217;s properties</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.properties</p></td>
<td align="left" valign="top"><p class="table">The custom properties of the users.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user&#8217;s virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.vm-list</p></td>
<td align="left" valign="top"><p class="table">See the virtual machines of one user in his details view. This view will contain: name, state, block and expire information of each vm</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user&#8217;s virtual machines' blocking state</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.vm-list-block</p></td>
<td align="left" valign="top"><p class="table">Blocking info of the virtual machines shown in user details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user&#8217;s virtual machines' expiration</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.vm-list-expiration</p></td>
<td align="left" valign="top"><p class="table">Expiration info of the virtual machines shown in user details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user&#8217;s virtual machines' running state</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.vm-list-state</p></td>
<td align="left" valign="top"><p class="table">State (stopped/started) of the virtual machines shown in user details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user&#8217;s virtual machines' user state</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.vm-list-user-state</p></td>
<td align="left" valign="top"><p class="table">User state (connected/disconnected)) of the virtual machines shown in user details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See number of user&#8217;s virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">user.see.vms-info</p></td>
<td align="left" valign="top"><p class="table">Total and connected virtual machines of this user</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of number of users</strong></p></td>
<td align="left" valign="top"><p class="table">user.stats.blocked</p></td>
<td align="left" valign="top"><p class="table">Total of blocked users in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of number of blocked users</strong></p></td>
<td align="left" valign="top"><p class="table">user.stats.summary</p></td>
<td align="left" valign="top"><p class="table">Total of users in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Block-Unblock users (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">user.update-massive.block</p></td>
<td align="left" valign="top"><p class="table">Update the blocking state (blocked/unblocked) of users massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create properties when update users (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">user.update-massive.properties-create</p></td>
<td align="left" valign="top"><p class="table">Create properties in user&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete properties when update users (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">user.update-massive.properties-delete</p></td>
<td align="left" valign="top"><p class="table">Update properties in user&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change properties when update users (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">user.update-massive.properties-update</p></td>
<td align="left" valign="top"><p class="table">Delete properties in user&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Block-Unblock users</strong></p></td>
<td align="left" valign="top"><p class="table">user.update.block</p></td>
<td align="left" valign="top"><p class="table">Update the blocking state (blocked/unblocked) of users one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update user&#8217;s password</strong></p></td>
<td align="left" valign="top"><p class="table">user.update.password</p></td>
<td align="left" valign="top"><p class="table">Update the password of users.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create properties when update users</strong></p></td>
<td align="left" valign="top"><p class="table">user.update.properties-create</p></td>
<td align="left" valign="top"><p class="table">Create properties in user&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete properties when update users</strong></p></td>
<td align="left" valign="top"><p class="table">user.update.properties-delete</p></td>
<td align="left" valign="top"><p class="table">Update properties in user&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change properties when update users</strong></p></td>
<td align="left" valign="top"><p class="table">user.update.properties-update</p></td>
<td align="left" valign="top"><p class="table">Delete properties in user&#8217;s one by one update process.</p></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="sect3">
<h4 id="_acls_de_máquinas_virtuales">7.1.2. ACLs de Máquinas virtuales</h4>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="33%" />
<col width="33%" />
<col width="33%" />
<thead>
<tr>
<th align="left" valign="top">ACL    </th>
<th align="left" valign="top">ACL code       </th>
<th align="left" valign="top">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">vm.create.</p></td>
<td align="left" valign="top"><p class="table">Creation of virtual machines including initial setting for name, user and OS flavour.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set tag in virtual macine&#8217;s creation</strong></p></td>
<td align="left" valign="top"><p class="table">vm.create.di-tag</p></td>
<td align="left" valign="top"><p class="table">Setting of disk image&#8217;s tag in the creation process of virtual machines. Without this ACL, the system will set <em>default</em> automatically.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set properties in virtual machine&#8217;s creation</strong></p></td>
<td align="left" valign="top"><p class="table">vm.create.properties</p></td>
<td align="left" valign="top"><p class="table">Setting of custom properties in the creation process of virtual machines.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete virtual machines (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">vm.delete-massive.</p></td>
<td align="left" valign="top"><p class="table">Deletion of virtual machines massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">vm.delete.</p></td>
<td align="left" valign="top"><p class="table">Deletion of virtual machines one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter virtual machines by creator</strong></p></td>
<td align="left" valign="top"><p class="table">vm.filter.created-by</p></td>
<td align="left" valign="top"><p class="table">Filter of virtual machines list by administrator who created it</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter virtual machines by creation date</strong></p></td>
<td align="left" valign="top"><p class="table">vm.filter.creation-date</p></td>
<td align="left" valign="top"><p class="table">Filter of virtual machines list by date when it was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter virtual machines by expiration date</strong></p></td>
<td align="left" valign="top"><p class="table">vm.filter.expiration-date</p></td>
<td align="left" valign="top"><p class="table">Filter of virtual machines list by date when it will expire. This is refered to the hard expiration.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter virtual machines by host</strong></p></td>
<td align="left" valign="top"><p class="table">vm.filter.host</p></td>
<td align="left" valign="top"><p class="table">Filter of virtual machines list by host where the virtual machines are running.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter virtual machines by name</strong></p></td>
<td align="left" valign="top"><p class="table">vm.filter.name</p></td>
<td align="left" valign="top"><p class="table">Filter of virtual machines list by virtual machine&#8217;s name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter virtual machines by OS Flavour</strong></p></td>
<td align="left" valign="top"><p class="table">vm.filter.osf</p></td>
<td align="left" valign="top"><p class="table">Filter of virtual machines list by OS flavour assigned to the virtual machine.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter virtual machines by properties</strong></p></td>
<td align="left" valign="top"><p class="table">vm.filter.properties</p></td>
<td align="left" valign="top"><p class="table">Filter of virtual machines list by desired custom property.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter virtual machines by running state</strong></p></td>
<td align="left" valign="top"><p class="table">vm.filter.state</p></td>
<td align="left" valign="top"><p class="table">Filter of virtual machines list by virtual machine&#8217;s state (stopped/started)</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter virtual machines by user</strong></p></td>
<td align="left" valign="top"><p class="table">vm.filter.user</p></td>
<td align="left" valign="top"><p class="table">Filter of virtual machines list by user who the virtual machines belong.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to virtual machine&#8217;s details view</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see-details.</p></td>
<td align="left" valign="top"><p class="table">This ACL grants the access to the details view. The minimum data on it is name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to virtual machine&#8217;s main section</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see-main.</p></td>
<td align="left" valign="top"><p class="table">This ACL grants the access to the list. The minimum data on it is disk_image</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s blocking status</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.block</p></td>
<td align="left" valign="top"><p class="table">Blocking state (blocked/unblocked) of virtual machines</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s creator</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.created-by</p></td>
<td align="left" valign="top"><p class="table">WAT administrator who created a virtual machine.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s creation date</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.creation-date</p></td>
<td align="left" valign="top"><p class="table">Datetime when a virtual machine was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s disk image</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.di</p></td>
<td align="left" valign="top"><p class="table">Disk images used by each virtual machine</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s disk image&#8217;s tag</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.di-tag</p></td>
<td align="left" valign="top"><p class="table">Disk image&#8217;s tag assigned in each virtual machine to define which disk image will be used.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s disk image&#8217;s version</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.di-version</p></td>
<td align="left" valign="top"><p class="table">Disk image&#8217;s version used by each virtual machine</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s Expiration</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.expiration</p></td>
<td align="left" valign="top"><p class="table">Expiration info of the virtual machines.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s Node</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.host</p></td>
<td align="left" valign="top"><p class="table">Host where each virtual machines are running</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s ID</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.id</p></td>
<td align="left" valign="top"><p class="table">The database identiefier of the virtual machines. Useful to make calls from CLI.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s IP address</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.ip</p></td>
<td align="left" valign="top"><p class="table">Current IP addres of the virtual machines.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s MAC address</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.mac</p></td>
<td align="left" valign="top"><p class="table">MAC address of the virtual machines.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s IP address for next boot</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.next-boot-ip</p></td>
<td align="left" valign="top"><p class="table">IP address that will be assigned in the next boot of the virtual machines.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s OS Flavour</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.osf</p></td>
<td align="left" valign="top"><p class="table">OS flavours assigned to each virtual machine.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s Serial port</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.port-serial</p></td>
<td align="left" valign="top"><p class="table">Serial port assigned to a running virtual machine.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s SSH port</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.port-ssh</p></td>
<td align="left" valign="top"><p class="table">SSH port assigned to a running virtual machine.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s VNC port</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.port-vnc</p></td>
<td align="left" valign="top"><p class="table">VNC port assigned to a running virtual machine.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s properties</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.properties</p></td>
<td align="left" valign="top"><p class="table">The custom properties of the virtual machines.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s state</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.state</p></td>
<td align="left" valign="top"><p class="table">The status of the virtual machines (stopped/started)</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s user</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.user</p></td>
<td align="left" valign="top"><p class="table">The user owner of the virtual machines.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See virtual machine&#8217;s user&#8217;s connection state</strong></p></td>
<td align="left" valign="top"><p class="table">vm.see.user-state</p></td>
<td align="left" valign="top"><p class="table">The user state of a virtual machine (connected/disconnected)</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of number of blocked virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">vm.stats.blocked</p></td>
<td align="left" valign="top"><p class="table">Total of blocked virtual machines in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of virtual machines close to expire</strong></p></td>
<td align="left" valign="top"><p class="table">vm.stats.close-to-expire</p></td>
<td align="left" valign="top"><p class="table">Info of the virutal machines that will be expire (hard expiration) in next 7 days.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of running virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">vm.stats.running-vms</p></td>
<td align="left" valign="top"><p class="table">Total of running virtual machines in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of number of virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">vm.stats.summary</p></td>
<td align="left" valign="top"><p class="table">Total of virtual machines in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Block-Unblock virtual machines (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update-massive.block</p></td>
<td align="left" valign="top"><p class="table">Update the blocking state (blocked/unblocked) of virtual machines massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update virtual machine&#8217;s tag (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update-massive.di-tag</p></td>
<td align="left" valign="top"><p class="table">Update the disk image&#8217;s tag setted on virtual machines massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Disconnect user from virtual machine (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update-massive.disconnect-user</p></td>
<td align="left" valign="top"><p class="table">Disconnect the user connected to virtual machines massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update virtual machine&#8217;s expiration (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update-massive.expiration</p></td>
<td align="left" valign="top"><p class="table">Update the expiration date times of virtual machines massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create properties when update virtual machines (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update-massive.properties-create</p></td>
<td align="left" valign="top"><p class="table">Create properties in virtual machine&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete properties when update virtual machines (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update-massive.properties-delete</p></td>
<td align="left" valign="top"><p class="table">Update properties in virtual machine&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change properties when update virtual machines (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update-massive.properties-update</p></td>
<td align="left" valign="top"><p class="table">Delete properties in virtual machine&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Start-Stop virtual machines (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update-massive.state</p></td>
<td align="left" valign="top"><p class="table">Start/Stop virtual machines massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Block-Unblock virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update.block</p></td>
<td align="left" valign="top"><p class="table">Update the blocking state (blocked/unblocked) of virtual machines one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update virtual machine&#8217;s tag</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update.di-tag</p></td>
<td align="left" valign="top"><p class="table">Update the disk image&#8217;s tag setted on virtual machines one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Disconnect user from virtual machine</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update.disconnect-user</p></td>
<td align="left" valign="top"><p class="table">Disconnect the user connected to virtual machines one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update virtual machine&#8217;s expiration</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update.expiration</p></td>
<td align="left" valign="top"><p class="table">Update the expiration date times of virtual machines one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update virtual machine&#8217;s name</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update.name</p></td>
<td align="left" valign="top"><p class="table">Update the name of virtual machines.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create properties when update virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update.properties-create</p></td>
<td align="left" valign="top"><p class="table">Create properties in virtual machine&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete properties when update virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update.properties-delete</p></td>
<td align="left" valign="top"><p class="table">Update properties in virtual machine&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change properties when update virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update.properties-update</p></td>
<td align="left" valign="top"><p class="table">Delete properties in virtual machine&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Start-Stop virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">vm.update.state</p></td>
<td align="left" valign="top"><p class="table">Start/Stop virtual machines one by one.</p></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="sect3">
<h4 id="_acls_de_nodos">7.1.3. ACLs de Nodos</h4>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="33%" />
<col width="33%" />
<col width="33%" />
<thead>
<tr>
<th align="left" valign="top">ACL    </th>
<th align="left" valign="top">ACL code       </th>
<th align="left" valign="top">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create nodes</strong></p></td>
<td align="left" valign="top"><p class="table">host.create.</p></td>
<td align="left" valign="top"><p class="table">Creation of hosts including initial setting for name and address.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set properties on nodes in creation</strong></p></td>
<td align="left" valign="top"><p class="table">host.create.properties</p></td>
<td align="left" valign="top"><p class="table">Setting of custom properties in the creation process of hosts.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete nodes (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">host.delete-massive.</p></td>
<td align="left" valign="top"><p class="table">Deletion of hosts massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete nodes</strong></p></td>
<td align="left" valign="top"><p class="table">host.delete.</p></td>
<td align="left" valign="top"><p class="table">Deletion of hosts one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter nodes by blocking status</strong></p></td>
<td align="left" valign="top"><p class="table">host.filter.block</p></td>
<td align="left" valign="top"><p class="table">Filter of hosts list by disk image&#8217;s blocking status</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter nodes by creator</strong></p></td>
<td align="left" valign="top"><p class="table">host.filter.created-by</p></td>
<td align="left" valign="top"><p class="table">Filter of hosts list by administrator who created it</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter nodes by creation date</strong></p></td>
<td align="left" valign="top"><p class="table">host.filter.creation-date</p></td>
<td align="left" valign="top"><p class="table">Filter of hosts list by date when it was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter nodes by name</strong></p></td>
<td align="left" valign="top"><p class="table">host.filter.name</p></td>
<td align="left" valign="top"><p class="table">Filter of hosts list by host&#8217;s name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter nodes by properties</strong></p></td>
<td align="left" valign="top"><p class="table">host.filter.properties</p></td>
<td align="left" valign="top"><p class="table">Filter of hosts list by desired custom property.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter nodes by running state</strong></p></td>
<td align="left" valign="top"><p class="table">host.filter.state</p></td>
<td align="left" valign="top"><p class="table">Filter of hosts list by running state.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter nodes by virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">host.filter.vm</p></td>
<td align="left" valign="top"><p class="table">Filter of hosts list by virtual machine that is running in the host.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to node&#8217;s details view</strong></p></td>
<td align="left" valign="top"><p class="table">host.see-details.</p></td>
<td align="left" valign="top"><p class="table">This ACL grants the access to the details view. The minimum data on it is name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to node&#8217;s main section</strong></p></td>
<td align="left" valign="top"><p class="table">host.see-main.</p></td>
<td align="left" valign="top"><p class="table">Access to hosts section (without it, it won&#8217;t appear in menu)</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s IP address</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.address</p></td>
<td align="left" valign="top"><p class="table">IP address of the hosts.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s blocking state</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.block</p></td>
<td align="left" valign="top"><p class="table">Blocking state (blocked/unblocked) of hosts</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s creator</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.created-by</p></td>
<td align="left" valign="top"><p class="table">WAT administrator who created a host.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s creation date</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.creation-date</p></td>
<td align="left" valign="top"><p class="table">Datetime when a host was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s ID</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.id</p></td>
<td align="left" valign="top"><p class="table">The database identiefier of the hosts. Useful to make calls from CLI.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s properties</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.properties</p></td>
<td align="left" valign="top"><p class="table">The custom properties of the hosts.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s running state</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.state</p></td>
<td align="left" valign="top"><p class="table">State of the hosts (stopped/started)</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s running virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.vm-list</p></td>
<td align="left" valign="top"><p class="table">See the virtual machines running on one host in his details view. This view will contain: name, state, block and expire information of each vm</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s running virtual machines' blocking state</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.vm-list-block</p></td>
<td align="left" valign="top"><p class="table">Blocking info of the virtual machines shown in host details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s running virtual machines' expiration</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.vm-list-expiration</p></td>
<td align="left" valign="top"><p class="table">Expiration info of the virtual machines shown in host details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s running virtual machines' running state</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.vm-list-state</p></td>
<td align="left" valign="top"><p class="table">State (stopped/started) of the virtual machines shown in host details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See node&#8217;s running virtual machines' user state</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.vm-list-user-state</p></td>
<td align="left" valign="top"><p class="table">User state (connected/disconnected) of the virtual machines shown in host details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See number of running vms running on nodes</strong></p></td>
<td align="left" valign="top"><p class="table">host.see.vms-info</p></td>
<td align="left" valign="top"><p class="table">Virtual machines information such as how many virtual machines are running in each host</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of number of blocked nodes</strong></p></td>
<td align="left" valign="top"><p class="table">host.stats.blocked</p></td>
<td align="left" valign="top"><p class="table">Total of blocked hosts in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of running nodes</strong></p></td>
<td align="left" valign="top"><p class="table">host.stats.running-hosts</p></td>
<td align="left" valign="top"><p class="table">Total of running hosts in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of number of nodes</strong></p></td>
<td align="left" valign="top"><p class="table">host.stats.summary</p></td>
<td align="left" valign="top"><p class="table">Total of hosts in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of nodes with most running Vms</strong></p></td>
<td align="left" valign="top"><p class="table">host.stats.top-hosts-most-vms</p></td>
<td align="left" valign="top"><p class="table">Top 5 of hosts with most running virtual machines.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Block-Unblock nodes (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">host.update-massive.block</p></td>
<td align="left" valign="top"><p class="table">Update the blocking state (blocked/unblocked) of hosts massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create properties when update nodes (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">host.update-massive.properties-create</p></td>
<td align="left" valign="top"><p class="table">Create properties in host&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete properties when update nodes (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">host.update-massive.properties-delete</p></td>
<td align="left" valign="top"><p class="table">Delete properties in host&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change properties when update nodes (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">host.update-massive.properties-update</p></td>
<td align="left" valign="top"><p class="table">Update properties in host&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Stop all virtual machines of a node (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">host.update-massive.stop-vms</p></td>
<td align="left" valign="top"><p class="table">Stop all the virtual machines of hosts massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update node&#8217;s address</strong></p></td>
<td align="left" valign="top"><p class="table">host.update.address</p></td>
<td align="left" valign="top"><p class="table">Update the IP address of the hosts.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Block-Unblock nodes</strong></p></td>
<td align="left" valign="top"><p class="table">host.update.block</p></td>
<td align="left" valign="top"><p class="table">Update the blocking state (blocked/unblocked) of hosts one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update node&#8217;s name</strong></p></td>
<td align="left" valign="top"><p class="table">host.update.name</p></td>
<td align="left" valign="top"><p class="table">Update the name of the hosts.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create properties when update nodes</strong></p></td>
<td align="left" valign="top"><p class="table">host.update.properties-create</p></td>
<td align="left" valign="top"><p class="table">Create properties in host&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete properties when update nodes</strong></p></td>
<td align="left" valign="top"><p class="table">host.update.properties-delete</p></td>
<td align="left" valign="top"><p class="table">Delete properties in host&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change properties when update nodes</strong></p></td>
<td align="left" valign="top"><p class="table">host.update.properties-update</p></td>
<td align="left" valign="top"><p class="table">Update properties in host&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Stop all virtual machines of a node</strong></p></td>
<td align="left" valign="top"><p class="table">host.update.stop-vms</p></td>
<td align="left" valign="top"><p class="table">Stop all the virtual machines of hosts one by one.</p></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="sect3">
<h4 id="_acls_de_osfs">7.1.4. ACLs de OSFs</h4>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="33%" />
<col width="33%" />
<col width="33%" />
<thead>
<tr>
<th align="left" valign="top">ACL    </th>
<th align="left" valign="top">ACL code       </th>
<th align="left" valign="top">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create OS Flavours</strong></p></td>
<td align="left" valign="top"><p class="table">osf.create.</p></td>
<td align="left" valign="top"><p class="table">Creation of OS flavours including initial setting for name.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set memory in OS Flavour&#8217;s creation</strong></p></td>
<td align="left" valign="top"><p class="table">osf.create.memory</p></td>
<td align="left" valign="top"><p class="table">Setting of memory in the creation process of OS flavours.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set properties in OS Flavour&#8217;s creation</strong></p></td>
<td align="left" valign="top"><p class="table">osf.create.properties</p></td>
<td align="left" valign="top"><p class="table">Setting of custom properties in the creation process of OS flavours.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set user storage in OS Flavour&#8217;s creation</strong></p></td>
<td align="left" valign="top"><p class="table">osf.create.user-storage</p></td>
<td align="left" valign="top"><p class="table">Setting of user storage in the creation process of OS flavours.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete OS Flavours (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">osf.delete-massive.</p></td>
<td align="left" valign="top"><p class="table">Deletion of OS flavours massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete OS Flavours</strong></p></td>
<td align="left" valign="top"><p class="table">osf.delete.</p></td>
<td align="left" valign="top"><p class="table">Deletion of OS flavours one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter OS Flavours by creator</strong></p></td>
<td align="left" valign="top"><p class="table">osf.filter.created-by</p></td>
<td align="left" valign="top"><p class="table">Filter of OS flavours list by administrator who created it</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter OS Flavours by creation date</strong></p></td>
<td align="left" valign="top"><p class="table">osf.filter.creation-date</p></td>
<td align="left" valign="top"><p class="table">Filter of OS flavours list by date when it was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter OS Flavours by disk image</strong></p></td>
<td align="left" valign="top"><p class="table">osf.filter.di</p></td>
<td align="left" valign="top"><p class="table">Filter of OS flavours list by disk image&#8217;s that belong to the OSF.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter OS Flavours by name</strong></p></td>
<td align="left" valign="top"><p class="table">osf.filter.name</p></td>
<td align="left" valign="top"><p class="table">Filter of OS flavours list by OSF&#8217;s name.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter OS Flavours by properties</strong></p></td>
<td align="left" valign="top"><p class="table">osf.filter.properties</p></td>
<td align="left" valign="top"><p class="table">Filter of OSF flavours list by desired custom property.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter OS Flavours by virtual machine</strong></p></td>
<td align="left" valign="top"><p class="table">osf.filter.vm</p></td>
<td align="left" valign="top"><p class="table">Filter of OS flavours list by virtual machines assigned to the OSFs.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to OS Flavour&#8217;s details view</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see-details.</p></td>
<td align="left" valign="top"><p class="table">This ACL grants the access to the details view. The minimum data on it is name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to OS Flavour&#8217;s main section</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see-main.</p></td>
<td align="left" valign="top"><p class="table">This ACL grants the access to the list. The minimum data on it is nname</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s creator</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.created-by</p></td>
<td align="left" valign="top"><p class="table">WAT administrator who created an OS flavour.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s creation date</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.creation-date</p></td>
<td align="left" valign="top"><p class="table">Datetime when an OS flavour image was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s disk images</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.di-list</p></td>
<td align="left" valign="top"><p class="table">See the disk images of this osf in his details view. This view will contain: name, block, tags, default, head and the feature of change which is default one</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s disk blocking state</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.di-list-block</p></td>
<td align="left" valign="top"><p class="table">Blocking info of the disk images shown in osf details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s disk images' default state</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.di-list-default</p></td>
<td align="left" valign="top"><p class="table">What of the Dis is the default one in osf details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change OS Flavour&#8217;s disk images' default info</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.di-list-default-update</p></td>
<td align="left" valign="top"><p class="table">Controls to change the default disk image of an osf in osf details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s disk images' head info</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.di-list-head</p></td>
<td align="left" valign="top"><p class="table">What of the Dis is the head (last created) in osf details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s disk images' tags</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.di-list-tags</p></td>
<td align="left" valign="top"><p class="table">Tags of the disk images shown in osf details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See number of OS Flavour&#8217;s disk images</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.dis-info</p></td>
<td align="left" valign="top"><p class="table">Number of disk images assigned to each OS flavours</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s ID</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.id</p></td>
<td align="left" valign="top"><p class="table">The database identiefier of the OS flavours. Useful to make calls from CLI.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s memory</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.memory</p></td>
<td align="left" valign="top"><p class="table">Amount of memory in the OS flavours</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s overlay</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.overlay</p></td>
<td align="left" valign="top"><p class="table">Overlay configuration of the OS flavours</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s properties</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.properties</p></td>
<td align="left" valign="top"><p class="table">The custom properties of the OS flavours</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s user storage</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.user-storage</p></td>
<td align="left" valign="top"><p class="table">User storage of the OS flavours</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.vm-list</p></td>
<td align="left" valign="top"><p class="table">See the virtual machines using this osf in his details view. This view will contain: name, state, block, di tag and expire information of each vm</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s virtual machines' blocking state</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.vm-list-block</p></td>
<td align="left" valign="top"><p class="table">Blocking info of the virtual machines shown in osf details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s virtual machines' expiration</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.vm-list-expiration</p></td>
<td align="left" valign="top"><p class="table">Expiration info of the virtual machines shown in osf details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s virtual machines' running state</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.vm-list-state</p></td>
<td align="left" valign="top"><p class="table">State (stopped/started) of the virtual machines shown in osf details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OS Flavour&#8217;s virtual machines' user state</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.vm-list-user-state</p></td>
<td align="left" valign="top"><p class="table">User state (connected/disconnected) of the virtual machines shown in osf details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See number of OS Flavour&#8217;s virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">osf.see.vms-info</p></td>
<td align="left" valign="top"><p class="table">Number of virtual machines that are using a Disk image of each OS flavours</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of number of OS Flavours</strong></p></td>
<td align="left" valign="top"><p class="table">osf.stats.summary</p></td>
<td align="left" valign="top"><p class="table">Total of OS flavours in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update OS Flavour&#8217;s memory (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update-massive.memory</p></td>
<td align="left" valign="top"><p class="table">Update the memory of OSF flavours massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create properties when update OS Flavours (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update-massive.properties-create</p></td>
<td align="left" valign="top"><p class="table">Create properties in OS flavour&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete properties when update OS Flavours (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update-massive.properties-delete</p></td>
<td align="left" valign="top"><p class="table">Update properties in OS flavour&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change properties when update OS Flavours (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update-massive.properties-update</p></td>
<td align="left" valign="top"><p class="table">Delete properties in OS flavour&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update OS Flavour&#8217;s user storage (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update-massive.user-storage</p></td>
<td align="left" valign="top"><p class="table">Update the memory of OSF flavours massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update OS Flavour&#8217;s memory</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update.memory</p></td>
<td align="left" valign="top"><p class="table">Update the memory of OSF flavours one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update OS Flavour&#8217;s name</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update.name</p></td>
<td align="left" valign="top"><p class="table">Update the name of OSF flavour&#8217;s.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create properties when update OS Flavours</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update.properties-create</p></td>
<td align="left" valign="top"><p class="table">Create properties in OS flavour&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete properties when update OS Flavours</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update.properties-delete</p></td>
<td align="left" valign="top"><p class="table">Update properties in OS flavour&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change properties when update OS Flavours</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update.properties-update</p></td>
<td align="left" valign="top"><p class="table">Delete properties in OS flavour&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update OS Flavour&#8217;s user storage</strong></p></td>
<td align="left" valign="top"><p class="table">osf.update.user-storage</p></td>
<td align="left" valign="top"><p class="table">Update the user storage of OSF flavours one by one.</p></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="sect3">
<h4 id="_acls_de_imágenes_de_disco">7.1.5. ACLs de Imágenes de disco</h4>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="33%" />
<col width="33%" />
<col width="33%" />
<thead>
<tr>
<th align="left" valign="top">ACL    </th>
<th align="left" valign="top">ACL code       </th>
<th align="left" valign="top">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create disk images</strong></p></td>
<td align="left" valign="top"><p class="table">di.create.</p></td>
<td align="left" valign="top"><p class="table">Creation of hosts including initial setting for disk image and OS flavour.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set disk images as default on disk images creation</strong></p></td>
<td align="left" valign="top"><p class="table">di.create.default</p></td>
<td align="left" valign="top"><p class="table">Setting of disk image as default in the creation process of disk images.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set properties on disk images creation</strong></p></td>
<td align="left" valign="top"><p class="table">di.create.properties</p></td>
<td align="left" valign="top"><p class="table">Setting of custom properties in the creation process of disk images.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set tags on disk images creation</strong></p></td>
<td align="left" valign="top"><p class="table">di.create.tags</p></td>
<td align="left" valign="top"><p class="table">Setting of tags in the creation process of disk images.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set version on disk images creation</strong></p></td>
<td align="left" valign="top"><p class="table">di.create.version</p></td>
<td align="left" valign="top"><p class="table">Setting of version in the creation process of disk images. Without this ACL, the system will set it automatically with a string based on the timestamp and an order digit.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete disk images (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">di.delete-massive.</p></td>
<td align="left" valign="top"><p class="table">Deletion of disk images massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete disk images</strong></p></td>
<td align="left" valign="top"><p class="table">di.delete.</p></td>
<td align="left" valign="top"><p class="table">Deletion of disk images one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter disk images by blocking status</strong></p></td>
<td align="left" valign="top"><p class="table">di.filter.block</p></td>
<td align="left" valign="top"><p class="table">Filter of disk images list by disk image&#8217;s blocking status</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter disk images by creator</strong></p></td>
<td align="left" valign="top"><p class="table">di.filter.created-by</p></td>
<td align="left" valign="top"><p class="table">Filter of disk images list by administrator who created it</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter disk images by creation date</strong></p></td>
<td align="left" valign="top"><p class="table">di.filter.creation-date</p></td>
<td align="left" valign="top"><p class="table">Filter of disk images list by date when it was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter disk images by DI&#8217;s name</strong></p></td>
<td align="left" valign="top"><p class="table">di.filter.disk-image</p></td>
<td align="left" valign="top"><p class="table">Filter of disk images list by disk image&#8217;s name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter disk images by OS Flavour</strong></p></td>
<td align="left" valign="top"><p class="table">di.filter.osf</p></td>
<td align="left" valign="top"><p class="table">Filter of disk images list by OS flavour</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter disk images by properties</strong></p></td>
<td align="left" valign="top"><p class="table">di.filter.properties</p></td>
<td align="left" valign="top"><p class="table">Filter of disk images list by desired custom property.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to disk image&#8217;s details view</strong></p></td>
<td align="left" valign="top"><p class="table">di.see-details.</p></td>
<td align="left" valign="top"><p class="table">This ACL grants the access to the details view. The minimum data on it is disk image</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to disk image&#8217;s main section</strong></p></td>
<td align="left" valign="top"><p class="table">di.see-main.</p></td>
<td align="left" valign="top"><p class="table">This ACL grants the access to the list. The minimum data on it is disk_image</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk image&#8217;s blocking state</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.block</p></td>
<td align="left" valign="top"><p class="table">Blocking state of disk images</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk image&#8217;s creator</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.created-by</p></td>
<td align="left" valign="top"><p class="table">Wat administrator who created a disk image</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk image&#8217;s creation date</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.creation-date</p></td>
<td align="left" valign="top"><p class="table">Datetime when a disk image was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OSF&#8217;s default disk image</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.default</p></td>
<td align="left" valign="top"><p class="table">If a disk image is setted as default image within the OSF where it belongs</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See OSF&#8217;s last created disk image</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.head</p></td>
<td align="left" valign="top"><p class="table">If a disk image is the last created image within the OSF where it belongs</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk image&#8217;s ID</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.id</p></td>
<td align="left" valign="top"><p class="table">The database identiefier of disk images. Useful to make calls from CLI.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk image&#8217;s OS Flavour</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.osf</p></td>
<td align="left" valign="top"><p class="table">The OS Flavour associated to the disk images.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk image&#8217;s properties</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.properties</p></td>
<td align="left" valign="top"><p class="table">The custom properties of the disk images.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk image&#8217;s tags</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.tags</p></td>
<td align="left" valign="top"><p class="table">The disk images tags</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk image&#8217;s version</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.version</p></td>
<td align="left" valign="top"><p class="table">The disk images version</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk image&#8217;s list of virtual machines</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.vm-list</p></td>
<td align="left" valign="top"><p class="table">Virtual machines using this image in his details view. This view will contain: name and tag of each vm</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See blocking state of VM&#8217;s list of DI&#8217;s</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.vm-list-block</p></td>
<td align="left" valign="top"><p class="table">Blocking info of the virtual machines shown in DI details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See expiration of VM&#8217;s list of DI&#8217;s</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.vm-list-expiration</p></td>
<td align="left" valign="top"><p class="table">Expiration info of the virtual machines shown in DI details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See running state of VM&#8217;s list of DI&#8217;s</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.vm-list-state</p></td>
<td align="left" valign="top"><p class="table">State (stop/started) of the virtual machines shown in DI details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See user state of VM&#8217;s list of DI&#8217;s</strong></p></td>
<td align="left" valign="top"><p class="table">di.see.vm-list-user-state</p></td>
<td align="left" valign="top"><p class="table">User state (connected/disconnected) of the virtual machines shown in DI details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of number of blocked disk images</strong></p></td>
<td align="left" valign="top"><p class="table">di.stats.blocked</p></td>
<td align="left" valign="top"><p class="table">Total of blocked disk images in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See statistics of number of disk images</strong></p></td>
<td align="left" valign="top"><p class="table">di.stats.summary</p></td>
<td align="left" valign="top"><p class="table">Total of disk images in current tenant or all system for superadministrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Block-Unblock disk images (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">di.update-massive.block</p></td>
<td align="left" valign="top"><p class="table">Update the blocking state (blocked/unblocked) of disk images massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create properties when update disk images (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">di.update-massive.properties-create</p></td>
<td align="left" valign="top"><p class="table">Create properties in disk image&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete properties when update disk images (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">di.update-massive.properties-delete</p></td>
<td align="left" valign="top"><p class="table">Update properties in disk image&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change properties when update disk images (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">di.update-massive.properties-update</p></td>
<td align="left" valign="top"><p class="table">Delete properties in disk image&#8217;s massive update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update disk image&#8217;s tags (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">di.update-massive.tags</p></td>
<td align="left" valign="top"><p class="table">Update the tags (create and delete) of disk images massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Block-Unblock disk images</strong></p></td>
<td align="left" valign="top"><p class="table">di.update.block</p></td>
<td align="left" valign="top"><p class="table">Update the blocking state (blocked/unblocked) of disk images one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set disk images as default</strong></p></td>
<td align="left" valign="top"><p class="table">di.update.default</p></td>
<td align="left" valign="top"><p class="table">Set as default a disk image in the OS flavour where it belongs.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create properties when update disk images</strong></p></td>
<td align="left" valign="top"><p class="table">di.update.properties-create</p></td>
<td align="left" valign="top"><p class="table">Create properties in disk image&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete properties when update disk images</strong></p></td>
<td align="left" valign="top"><p class="table">di.update.properties-delete</p></td>
<td align="left" valign="top"><p class="table">Update properties in disk image&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change properties when update disk images</strong></p></td>
<td align="left" valign="top"><p class="table">di.update.properties-update</p></td>
<td align="left" valign="top"><p class="table">Delete properties in disk image&#8217;s one by one update process.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update disk image&#8217;s tags</strong></p></td>
<td align="left" valign="top"><p class="table">di.update.tags</p></td>
<td align="left" valign="top"><p class="table">Update the tags (create and delete) of disk images one by one.</p></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="sect3">
<h4 id="_acls_de_administradores">7.1.6. ACLs de Administradores</h4>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="33%" />
<col width="33%" />
<col width="33%" />
<thead>
<tr>
<th align="left" valign="top">ACL    </th>
<th align="left" valign="top">ACL code       </th>
<th align="left" valign="top">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create administrators</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.create.</p></td>
<td align="left" valign="top"><p class="table">Create WAT Administrators. It includes name and password setting</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set language on administrator creation</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.create.language</p></td>
<td align="left" valign="top"><p class="table">Setting of language in the creation process of administrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete administrators</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.delete-massive.</p></td>
<td align="left" valign="top"><p class="table">Deletion of WAT administrators massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete administrators (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.delete.</p></td>
<td align="left" valign="top"><p class="table">Deletion of WAT administrators one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter administrators by creator</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.filter.created-by</p></td>
<td align="left" valign="top"><p class="table">Filter of administrators list by administrator who created it</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter administrators by creation date</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.filter.creation-date</p></td>
<td align="left" valign="top"><p class="table">Filter of administrators list by date when it were created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter administrators by name</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.filter.name</p></td>
<td align="left" valign="top"><p class="table">Filter of administrators list by administrator&#8217;s name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to administrator&#8217;s details view</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.see-details.</p></td>
<td align="left" valign="top"><p class="table">Access to details view of WAT administrators. This view includes name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to administrator&#8217;s main section</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.see-main.</p></td>
<td align="left" valign="top"><p class="table">Access to WAT Administrators section (without it, it won&#8217;t appear in menu). This list view includes name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See administrator&#8217;s ACLs</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.see.acl-list</p></td>
<td align="left" valign="top"><p class="table">Effective ACL list for a WAT administrator calculated from the assigned roles</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Source roles of Administrator&#8217;s ACL</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.see.acl-list-roles</p></td>
<td align="left" valign="top"><p class="table">Which role is the origin of each effective acls in WAT administrator details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk administrator&#8217;s creator</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.see.created-by</p></td>
<td align="left" valign="top"><p class="table">Wat administrator who created an administrator</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See disk administrator&#8217;s creation date</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.see.creation-date</p></td>
<td align="left" valign="top"><p class="table">Datetime when an administrator was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See administrator&#8217;s ID</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.see.id</p></td>
<td align="left" valign="top"><p class="table">The database identiefier of the WAT administrators. Useful to make calls from CLI.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See administrator&#8217;s language</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.see.language</p></td>
<td align="left" valign="top"><p class="table">Language of the WAT administrators.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See administrator&#8217;s Roles</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.see.roles</p></td>
<td align="left" valign="top"><p class="table">Assigned roles to the WAT administrator</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Assign-Unassign administrator&#8217;s roles</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.update.assign-role</p></td>
<td align="left" valign="top"><p class="table">Assign roles to WAT administrators to give to them their ACLs.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update administrator&#8217;s language</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.update.language</p></td>
<td align="left" valign="top"><p class="table">Update the language of administrators one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Change administrator&#8217;s password</strong></p></td>
<td align="left" valign="top"><p class="table">administrator.update.password</p></td>
<td align="left" valign="top"><p class="table">Update WAT administrator password (it doesn&#8217;t include roles management)</p></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="sect3">
<h4 id="_acls_de_roles">7.1.7. ACLs de Roles</h4>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="33%" />
<col width="33%" />
<col width="33%" />
<thead>
<tr>
<th align="left" valign="top">ACL    </th>
<th align="left" valign="top">ACL code       </th>
<th align="left" valign="top">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table"><strong>Create roles</strong></p></td>
<td align="left" valign="top"><p class="table">role.create.</p></td>
<td align="left" valign="top"><p class="table">Creation of roles including initial setting for name.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete roles (massive)</strong></p></td>
<td align="left" valign="top"><p class="table">role.delete-massive.</p></td>
<td align="left" valign="top"><p class="table">Deletion of roles massively.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Delete roles</strong></p></td>
<td align="left" valign="top"><p class="table">role.delete.</p></td>
<td align="left" valign="top"><p class="table">Deletion of roles one by one.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter roles by creator</strong></p></td>
<td align="left" valign="top"><p class="table">role.filter.created-by</p></td>
<td align="left" valign="top"><p class="table">Filter of roles list by administrator who created it</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter roles by creation date</strong></p></td>
<td align="left" valign="top"><p class="table">role.filter.creation-date</p></td>
<td align="left" valign="top"><p class="table">Filter of roles list by date when it was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filter roles by name</strong></p></td>
<td align="left" valign="top"><p class="table">role.filter.name</p></td>
<td align="left" valign="top"><p class="table">Filter of roles list by role&#8217;s name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to role&#8217;s details view</strong></p></td>
<td align="left" valign="top"><p class="table">role.see-details.</p></td>
<td align="left" valign="top"><p class="table">Access to details view of Roles. This view includes name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to role&#8217;s main section</strong></p></td>
<td align="left" valign="top"><p class="table">role.see-main.</p></td>
<td align="left" valign="top"><p class="table">Access to the roles view. The minimum data on it is name</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See role&#8217;s acls</strong></p></td>
<td align="left" valign="top"><p class="table">role.see.acl-list</p></td>
<td align="left" valign="top"><p class="table">Effective ACL list for a role  calculated from the inherited roles</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See role&#8217;s acls' origin roles</strong></p></td>
<td align="left" valign="top"><p class="table">role.see.acl-list-roles</p></td>
<td align="left" valign="top"><p class="table">Which role is the origin of each effective acls in role details view</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See role&#8217;s creator</strong></p></td>
<td align="left" valign="top"><p class="table">role.see.created-by</p></td>
<td align="left" valign="top"><p class="table">Wat administrator who created a role</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See role&#8217;s creation date</strong></p></td>
<td align="left" valign="top"><p class="table">role.see.creation-date</p></td>
<td align="left" valign="top"><p class="table">Datetime when a role was created</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See role&#8217;s ID</strong></p></td>
<td align="left" valign="top"><p class="table">role.see.id</p></td>
<td align="left" valign="top"><p class="table">The database identiefier of the roles. Useful to make calls from CLI.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>See role&#8217;s inherited roles</strong></p></td>
<td align="left" valign="top"><p class="table">role.see.inherited-roles</p></td>
<td align="left" valign="top"><p class="table">Inherited roles of a role.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Assign-Unassign role&#8217;s ACLs</strong></p></td>
<td align="left" valign="top"><p class="table">role.update.assign-acl</p></td>
<td align="left" valign="top"><p class="table">Add/Remove acl on role.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Assign-Unassign role&#8217;s inherited roles</strong></p></td>
<td align="left" valign="top"><p class="table">role.update.assign-role</p></td>
<td align="left" valign="top"><p class="table">Manage the inheritance of roles adding roles in others.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Update role&#8217;s name</strong></p></td>
<td align="left" valign="top"><p class="table">role.update.name</p></td>
<td align="left" valign="top"><p class="table">Update the name of roles.</p></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="sect3">
<h4 id="_acls_de_vistas">7.1.8. ACLs de Vistas</h4>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="33%" />
<col width="33%" />
<col width="33%" />
<thead>
<tr>
<th align="left" valign="top">ACL    </th>
<th align="left" valign="top">ACL code       </th>
<th align="left" valign="top">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table"><strong>Access to default view&#8217;s main section</strong></p></td>
<td align="left" valign="top"><p class="table">views.see-main.</p></td>
<td align="left" valign="top"><p class="table">Access to WAT Customize section (without it, it won&#8217;t appear in menu).</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set default columns on list views</strong></p></td>
<td align="left" valign="top"><p class="table">views.update.columns</p></td>
<td align="left" valign="top"><p class="table">Set what columns will be shown in list views by default by tenant</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set default filters on list views for desktop</strong></p></td>
<td align="left" valign="top"><p class="table">views.update.filters-desktop</p></td>
<td align="left" valign="top"><p class="table">Set what filters will be shown in list views by default for desktop version by tenant</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Set default filters on list views for mobile</strong></p></td>
<td align="left" valign="top"><p class="table">views.update.filters-mobile</p></td>
<td align="left" valign="top"><p class="table">Set what filters will be shown in list views by default for mobile version by tenant</p></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="sect3">
<h4 id="_acls_de_configuración">7.1.9. ACLs de Configuración</h4>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="33%" />
<col width="33%" />
<col width="33%" />
<thead>
<tr>
<th align="left" valign="top">ACL    </th>
<th align="left" valign="top">ACL code       </th>
<th align="left" valign="top">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table"><strong>QVD&#8217;s configuration management</strong></p></td>
<td align="left" valign="top"><p class="table">config.qvd.</p></td>
<td align="left" valign="top"><p class="table">Manage QVD configuration (add/update tokens).</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>WAT&#8217;s configuration management</strong></p></td>
<td align="left" valign="top"><p class="table">config.wat.</p></td>
<td align="left" valign="top"><p class="table">Manage WAT configuration (language&#8230;).</p></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
<div class="sect2">
<h3 id="_referencia_de_plantillas">7.2. Referencia de Plantillas</h3>
<div class="paragraph"><p>Lista de plantillas predefinidas en el sistema. Las plantillas son conjuntos de ACLs, pero al igual que los Roles, utilizan herencia entre ellas.</p></div>
<div class="paragraph"><p>En esta guía de referencia se encuentran las plantillas predefinidas en el sistema incluyendo diagramas con la relación entre ellas.</p></div>
<div class="sect3">
<h4 id="_plantillas_primitivas">7.2.1. Plantillas primitivas</h4>
<div class="paragraph"><p>Tienen asignados sólamente ACLs.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Notación
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/Templates_Hierarchy_Legend_-_Primitives.png" alt="Templates_Hierarchy_Legend_-_Primitives.png" width="300px" />
</span>
</p>
</dd>
<dt class="hdlist1">
Listado
</dt>
<dd>
<div class="ulist"><ul>
<li>
<p>
Administrators
</p>
<div class="ulist"><ul>
<li>
<p>
Administrators Creator
</p>
</li>
<li>
<p>
Administrators Eraser
</p>
</li>
<li>
<p>
Administrators Operator
</p>
</li>
<li>
<p>
Administrators Reader
</p>
</li>
<li>
<p>
Administrators Updater
</p>
</li>
</ul></div>
</li>
<li>
<p>
Configuration
</p>
<div class="ulist"><ul>
<li>
<p>
QVD Config Manager
</p>
</li>
<li>
<p>
WAT Config Manager
</p>
</li>
</ul></div>
</li>
<li>
<p>
Images
</p>
<div class="ulist"><ul>
<li>
<p>
Images Creator
</p>
</li>
<li>
<p>
Images Eraser
</p>
</li>
<li>
<p>
Images Operator
</p>
</li>
<li>
<p>
Images Reader
</p>
</li>
<li>
<p>
Images Updater
</p>
</li>
</ul></div>
</li>
</ul></div>
</dd>
</dl></div>
<div class="ulist"><ul>
<li>
<p>
Nodes
</p>
<div class="ulist"><ul>
<li>
<p>
Nodes Creator
</p>
</li>
<li>
<p>
Nodes Eraser
</p>
</li>
<li>
<p>
Nodes Operator
</p>
</li>
<li>
<p>
Nodes Reader
</p>
</li>
<li>
<p>
Nodes Updater
</p>
</li>
</ul></div>
</li>
<li>
<p>
OSFs
</p>
<div class="ulist"><ul>
<li>
<p>
OSFs Creator
</p>
</li>
<li>
<p>
OSFs Eraser
</p>
</li>
<li>
<p>
OSFs Operator
</p>
</li>
<li>
<p>
OSFs Reader
</p>
</li>
<li>
<p>
OSFs Updater
</p>
</li>
</ul></div>
</li>
<li>
<p>
Roles
</p>
<div class="ulist"><ul>
<li>
<p>
Roles Creator
</p>
</li>
<li>
<p>
Roles Eraser
</p>
</li>
<li>
<p>
Roles Operator
</p>
</li>
<li>
<p>
Roles Reader
</p>
</li>
<li>
<p>
Roles Updater
</p>
</li>
</ul></div>
</li>
<li>
<p>
Users
</p>
<div class="ulist"><ul>
<li>
<p>
Users Creator
</p>
</li>
<li>
<p>
Users Eraser
</p>
</li>
<li>
<p>
Users Operator
</p>
</li>
<li>
<p>
Users Reader
</p>
</li>
<li>
<p>
Users Updater
</p>
</li>
<li>
<p>
Users Operator
</p>
</li>
</ul></div>
</li>
<li>
<p>
Views
</p>
<div class="ulist"><ul>
<li>
<p>
Views Operator
</p>
</li>
<li>
<p>
Views Reader
</p>
</li>
</ul></div>
</li>
<li>
<p>
VMs
</p>
<div class="ulist"><ul>
<li>
<p>
VMs Creator
</p>
</li>
<li>
<p>
VMs Eraser
</p>
</li>
<li>
<p>
VMs Operator
</p>
</li>
<li>
<p>
VMs Reader
</p>
</li>
<li>
<p>
VMs Updater
</p>
</li>
</ul></div>
</li>
</ul></div>
</div>
<div class="sect3">
<h4 id="_plantillas_de_acción">7.2.2. Plantillas de acción</h4>
<div class="paragraph"><p>Heredan Plantillas primitivas y compenden los ACLs relacionados por el tipo de acción de todos los elementos de QVD. Por ejemplo 'QVD Reader" reúne los permisos de lectura sobre Usuarios, Máquinas virtuales, OSFs e Imágenes de disco.*</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Notación
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/Templates_Hierarchy_Legend_-_Action.png" alt="Templates_Hierarchy_Legend_-_Action.png" width="300px" />
</span>
</p>
</dd>
<dt class="hdlist1">
Listado
</dt>
<dd>
<div class="ulist"><ul>
<li>
<p>
QVD Creator
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
Users Creator
</p>
</li>
<li>
<p>
VMs Creator
</p>
</li>
<li>
<p>
OSFs Creator
</p>
</li>
<li>
<p>
Images Creator
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_QVD_Creator.png" alt="Templates_Hierarchy_-_QVD_Creator.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
QVD Updater
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
Users Updater
</p>
</li>
<li>
<p>
VMs Updater
</p>
</li>
<li>
<p>
OSFs Updater
</p>
</li>
<li>
<p>
Images Updater
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_QVD_Updater.png" alt="Templates_Hierarchy_-_QVD_Updater.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
QVD Reader
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
Users Reader
</p>
</li>
<li>
<p>
VMs Reader
</p>
</li>
<li>
<p>
OSFs Reader
</p>
</li>
<li>
<p>
Images Reader
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_QVD_Reader.png" alt="Templates_Hierarchy_-_QVD_Reader.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
QVD Operator
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
Users Operator
</p>
</li>
<li>
<p>
VMs Operator
</p>
</li>
<li>
<p>
OSFs Operator
</p>
</li>
<li>
<p>
Images Operator
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_QVD_Operator.png" alt="Templates_Hierarchy_-_QVD_Operator.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
QVD Eraser
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
Users Eraser
</p>
</li>
<li>
<p>
VMs Eraser
</p>
</li>
<li>
<p>
OSFs Eraser
</p>
</li>
<li>
<p>
Images Eraser
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_QVD_Eraser.png" alt="Templates_Hierarchy_-_QVD_Eraser.png" width="600px" />
</span></p></div>
</div></div>
</li>
</ul></div>
</dd>
</dl></div>
</div>
<div class="sect3">
<h4 id="_plantillas_de_gestión">7.2.3. Plantillas de gestión</h4>
<div class="paragraph"><p>Heredan Plantillas primitivas y compenden los ACLs relacionados por el elemento afectado, otorgándole todos los tipos de acción posibles sobre él. Por ejemplo <em>Users Manager</em> reúne los permisos de lectura, operación, actualización, creación y borrado sobre los Usuarios de QVD.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Notación
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/Templates_Hierarchy_Legend_-_Manager.png" alt="Templates_Hierarchy_Legend_-_Manager.png" width="300px" />
</span>
</p>
</dd>
<dt class="hdlist1">
Listado
</dt>
<dd>
<div class="ulist"><ul>
<li>
<p>
Users Manager
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
Users Reader
</p>
</li>
<li>
<p>
Users Creator
</p>
</li>
<li>
<p>
Users Updater
</p>
</li>
<li>
<p>
Users Operator
</p>
</li>
<li>
<p>
Users Eraser
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_Users_Manager.png" alt="Templates_Hierarchy_-_Users_Manager.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
VMs Manager
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
VMs Reader
</p>
</li>
<li>
<p>
VMs Creator
</p>
</li>
<li>
<p>
VMs Updater
</p>
</li>
<li>
<p>
VMs Operator
</p>
</li>
<li>
<p>
VMs Eraser
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_VMs_Manager.png" alt="Templates_Hierarchy_-_VMs_Manager.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
OSFs Manager
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
OSFs Reader
</p>
</li>
<li>
<p>
OSFs Creator
</p>
</li>
<li>
<p>
OSFs Updater
</p>
</li>
<li>
<p>
OSFs Operator
</p>
</li>
<li>
<p>
OSFs Eraser
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_OSFs_Manager.png" alt="Templates_Hierarchy_-_OSFs_Manager.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Images Manager
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
Images Reader
</p>
</li>
<li>
<p>
Images Creator
</p>
</li>
<li>
<p>
Images Updater
</p>
</li>
<li>
<p>
Images Operator
</p>
</li>
<li>
<p>
Images Eraser
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_Images_Manager.png" alt="Templates_Hierarchy_-_Images_Manager.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Administrators Manager
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
Administrators Reader
</p>
</li>
<li>
<p>
Administrators Creator
</p>
</li>
<li>
<p>
Administrators Updater
</p>
</li>
<li>
<p>
Administrators Operator
</p>
</li>
<li>
<p>
Administrators Eraser
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_Administrators_Manager.png" alt="Templates_Hierarchy_-_Administrators_Manager.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Roles Manager
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
Roles Reader
</p>
</li>
<li>
<p>
Roles Creator
</p>
</li>
<li>
<p>
Roles Updater
</p>
</li>
<li>
<p>
Roles Operator
</p>
</li>
<li>
<p>
Roles Eraser
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_Roles_Manager.png" alt="Templates_Hierarchy_-_Roles_Manager.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Views Manager
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
Views Reader
</p>
</li>
<li>
<p>
Views Operator
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_Views_Manager.png" alt="Templates_Hierarchy_-_Views_Manager.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
Nodes Manager
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
Nodes Reader
</p>
</li>
<li>
<p>
Nodes Creator
</p>
</li>
<li>
<p>
Nodes Updater
</p>
</li>
<li>
<p>
Nodes Operator
</p>
</li>
<li>
<p>
Nodes Eraser
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_Nodes_Manager.png" alt="Templates_Hierarchy_-_Nodes_Manager.png" width="600px" />
</span></p></div>
</div></div>
</li>
</ul></div>
</dd>
</dl></div>
</div>
<div class="sect3">
<h4 id="_plantillas_de_gestión_global_qvd_wat">7.2.4. Plantillas de gestión global (QVD/WAT)</h4>
<div class="paragraph"><p>Heredan de las plantillas de gestión para formar una plantilla con los ACLs de gestión de todo QVD ó todo WAT.*</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Notación
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/Templates_Hierarchy_Legend_-_Global_Manager.png" alt="Templates_Hierarchy_Legend_-_Global_Manager.png" width="300px" />
</span>
</p>
</dd>
<dt class="hdlist1">
Listado
</dt>
<dd>
<div class="ulist"><ul>
<li>
<p>
WAT Manager
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
Views Manager
</p>
</li>
<li>
<p>
Roles Manager
</p>
</li>
<li>
<p>
Administrator Manager
</p>
</li>
<li>
<p>
WAT Config Manager
</p>
</li>
</ul></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Esquema
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_WAT_Manager.png" alt="Templates_Hierarchy_-_WAT_Manager.png" width="600px" />
</span>
</p>
</dd>
</dl></div>
</div></div>
</li>
<li>
<p>
QVD Manager
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
Users Manager
</p>
</li>
<li>
<p>
VMs Manager
</p>
</li>
<li>
<p>
OSFs Manager
</p>
</li>
<li>
<p>
Images Manager
</p>
</li>
<li>
<p>
QVD Config Manager
</p>
</li>
</ul></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Esquema
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_QVD_Manager.png" alt="Templates_Hierarchy_-_QVD_Manager.png" width="600px" />
</span>
</p>
</dd>
</dl></div>
</div></div>
</li>
</ul></div>
</dd>
</dl></div>
</div>
<div class="sect3">
<h4 id="_plantillas_maestras">7.2.5. Plantillas maestras</h4>
<div class="paragraph"><p>Heredan de las Plantillas de gestión global formando una Plantilla con todos los ACLs. En esta tipología se encuentran dos plantillas:</p></div>
<div class="ulist"><ul>
<li>
<p>
Master
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Hereda de las plantillas de gestión global de QVD y WAT obteniendo todos los ACLs posibles excepto los de los Nodos.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Notación
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/Templates_Hierarchy_Legend_-_Master.png" alt="Templates_Hierarchy_Legend_-_Master.png" width="300px" />
</span>
</p>
</dd>
<dt class="hdlist1">
Esquema
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_Master.png" alt="Templates_Hierarchy_-_Master.png" width="600px" />
</span>
</p>
</dd>
</dl></div>
</div></div>
</li>
<li>
<p>
Total master
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Hereda de la plantilla Master así como de la Plantilla de gestión de Nodos.*</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Notación
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/Templates_Hierarchy_Legend_-_Total_Master.png" alt="Templates_Hierarchy_Legend_-_Total_Master.png" width="300px" />
</span>
</p>
</dd>
<dt class="hdlist1">
Esquema
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/Templates_Hierarchy_-_Total_Master.png" alt="Templates_Hierarchy_-_Total_Master.png" width="600px" />
</span>
</p>
</dd>
</dl></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>* Los nodos están fuera de la clasificación de QVD en las plantillas al ser elementos arquitectónicos físicos importantes. Tendrán sus propias plantillas de ACLs.</p></div>
</div>
<div class="sect3">
<h4 id="_jerarquía_de_plantillas">7.2.6. Jerarquía de Plantillas</h4>
<div class="paragraph"><p>En el siguiente esquema se observa de un solo vistazo toda la jerarquía de Plantillas.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_Monotenant.png" alt="Templates_Hierarchy_Monotenant.png" width="960px" />
</span></p></div>
</div>
</div>
<div class="sect2">
<h3 id="_referencia_de_roles">7.3. Referencia de Roles</h3>
<div class="paragraph"><p>Esta es una referncia de los Roles del WAT que vienen por defecto en una instalación limpia de QVD.</p></div>
<div class="paragraph"><p>Estos roles heredan la mayoría de los ACLs de plantillas.</p></div>
<div class="paragraph"><p>Para evitar el mal funcionamiento indeseado, los roles por defecto estan <strong>bloqueados</strong>, por lo que no se podrán ni editar ni eliminar.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Lista de roles por defecto
</dt>
<dd>
<div class="ulist"><ul>
<li>
<p>
<strong>Operador L1</strong>
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Este rol garantiza los permisos suficientes para poder ver los elementos de QVD aunque sin poder crear, editar, eliminar ni realizar cualquier otra acción sobre ellos. Es un <strong>rol de solo lectura</strong> enfocado a detección de problemas.</p></div>
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
QVD Reader
</p>
</li>
</ul></div>
</div></div>
</li>
<li>
<p>
<strong>Operador L2</strong>
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Este rol otorga los permisos del Operador L1 (de hecho, hereda ese rol) y además otorga permisos para realizar ciertas <strong>acciones operativas</strong> como iniciar/detener máquinas virtuales, desconectar usuarios o bloquear elementos.</p></div>
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
Operador L1
</p>
</li>
<li>
<p>
QVD Operator
</p>
</li>
</ul></div>
</div></div>
</li>
<li>
<p>
<strong>Operador L3</strong>
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Este rol otorga permisos totales para los elementos de QVD. Creación, Actualización, Operación y Eliminado. Además da acceso a los Nodos</p></div>
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
Operador L2
</p>
</li>
<li>
<p>
QVD Manager
</p>
</li>
<li>
<p>
Node Manager
</p>
</li>
</ul></div>
</div></div>
</li>
<li>
<p>
<strong>Root</strong>
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Este rol otorga <strong>poderes totales</strong> sobre todos los elementos de QVD y además del WAT: Administradores, roles, etc.</p></div>
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
Total Master
</p>
</li>
</ul></div>
</div></div>
</li>
</ul></div>
</dd>
</dl></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_propiedades_libres">8. Propiedades libres</h2>
<div class="sectionbody">
<div class="paragraph"><p><strong>Los elementos de QVD tienen atributos</strong> como por ejemplo el nombre, su estado de bloqueo, su dirección IP asociada (en el caso de las máquinas virtuales o nodos) o la referencia a otros objetos de QVD a los que están asociados. Por ejemplo las imágenes de disco tienen asignado un OSF o las máquinas virtuales están unívocamente relacionadas con un usuario.</p></div>
<div class="paragraph"><p>Todos estos atributos nos describen cómo son los objetos de QVD, nos permiten diferenciarlos del resto, nos dan información de qué dependencias tienen y nos enseñan a cerca de su comportamiento. Esta información será fija, aunque puede configurarse su visibilidad a través de los ACLs, pudiendo crearse roles de administradores que solo permitan ver parte de ellos.</p></div>
<div class="paragraph"><p>Debido a las diversas necesidades que puedan tenerse en diferentes entornos QVD, existe una manera de <strong>personalizar la información</strong> que se almacena de cada objeto QVD. Esta personalización es posible gracias a las <strong>propiedades libres</strong>, que son unos <strong>atributos especiales de los objetos de QVD</strong> creados por los administradores para cubrir sus necesidades.</p></div>
<div class="paragraph"><p>Estas propiedades serán atributos extra que podrán configurarse como una columna más así como habilitarlos como filtro en la vista listado.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">Podemos crear una propiedad en los usuarios llamada <em>Company</em>, para almacenar la empresa a la que pertenecen los diferentes usuarios y luego filtrar el listado por ese dato. Otra interesante utilidad de estas propiedades es utilizarlas por scripts externos a través del CLI para realizar acciones por lotes sobre un subconjunto de elementos filtrados según nuestras necesidades.</td>
</tr></table>
</div>
<div class="paragraph"><p>Estos atributos especiales <strong>podrán restringirse también a través de ACLs</strong> pero en <strong>bloque</strong>. Osea podemos <strong>permitir o denegar la visualización de todas las propiedades</strong> libres por cada tipo de objeto de QVD (Usuarios, Máquinas virtuales, OSFs&#8230;), pero no permitir unas propiedades sí y otras no.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/important.png" alt="Important" />
</td>
<td class="content">Los elementos con propiedades libres son: Usuarios, Máquinas virtuales, Nodos, OSFs e Imágenes de disco.</td>
</tr></table>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_acciones_masivas">9. Acciones masivas</h2>
<div class="sectionbody">
<div class="paragraph"><p>En algunas vistas listado existe la posibilidad de realizar acciones masivas. Cuando esto sucede observaremos que la primera columna de la tabla listado es una columna de casillas de verificación.</p></div>
<div class="sect2">
<h3 id="_selección_de_elementos">9.1. Selección de elementos</h3>
<div class="paragraph"><p>Con la columna de casillas de verificación se podrán seleccionar los elementos a los que queramos aplicar la misma acción. Esta selección se puede hacer de uno en uno o de forma múltiple.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Selección de uno en uno
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Se pueden ir seleccionando los elementos de uno en uno marcando las casillas de verificación de la primera columna.</p></div>
<div class="paragraph"><p>Cuando hay más de una página de elementos, se puede ir navegando entre ellas sin perder los elementos seleccionados. Esto hace posible <strong>seleccionar a la vez elementos de diferentes páginas</strong>.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Selección múltiple
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>La columna de casillas de verificación dispone de una <strong>casilla especial en la cabecera de la tabla</strong>. Con esta casilla podremos hacer una selección múltiple. Al seleccionar esta casilla, se seleccionarán automáticamente todos los elementos del listado.</p></div>
<div class="paragraph"><p>Pueden darse dos situaciones:</p></div>
<div class="ulist"><ul>
<li>
<p>
No haya elementos fuera del listado:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>El número de elementos del listado sea menor o igual al bloque de paginación, por lo que solo haya una página y todos los elementos estén mostrándose.</p></div>
<div class="paragraph"><p>En este caso, al marcar la casilla de selección múltiple <strong>se marcarán todos los elementos de forma inmediata</strong>.</p></div>
</div></div>
</li>
<li>
<p>
Haya elementos fuera del listado:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>El número de elementos del listado sea mayor que el bloque de paginación, por lo que se muestre una página de X páginas totales.</p></div>
<div class="paragraph"><p>En este caso, al marcar la casilla de selección múltiple <strong>aparecerá un diálogo advirtiéndonos de que hay elementos fuera de la vista</strong> y dándonos dos opciones:</p></div>
<div class="ulist"><ul>
<li>
<p>
Seleccionar sólamente los elementos que están a la vista
</p>
</li>
<li>
<p>
Seleccionar todos los elementos del listado, incluyendo los de otras páginas
</p>
</li>
</ul></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
</dl></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">En la parte izquierda justo debajo de la tabla del listado podremos ver en cada momento el número de elementos que tenemos seleccionados.</td>
</tr></table>
</div>
</div>
<div class="sect2">
<h3 id="_selector_de_acciones_masivas">9.2. Selector de acciones masivas</h3>
<div class="paragraph"><p>De estar disponibles, debajo de la tabla de un listado, habrá un control de selección de acciones masivas. Bastará con seleccionar la acción deseada y hacer click en el botón <em>Aplicar</em> para llevarlas a cabo <strong>sobre los elementos seleccionados</strong>.</p></div>
</div>
<div class="sect2">
<h3 id="_tipos_de_acciones_masivas">9.3. Tipos de acciones masivas</h3>
<div class="paragraph"><p>Las acciones masivas pueden ser de diferente naturaleza:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Edición</strong>:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Con la acción de edición se pueden editar los <strong>atributos comunes</strong> de los elementos que se seleccionen.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Borrado</strong>:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Con la acción de borrado se pueden eliminar elementos de forma masiva.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Ejecución</strong>:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>En esta categoría se engloban las acciones que no son ni de edición ni de borrado: <em>Arrancar/Detener máquinas virtuales, desconectar usuarios, bloquear/desbloquear elementos&#8230;</em></p></div>
</div></div>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_restricción_de_acciones_masivas">9.4. Restricción de acciones masivas</h3>
<div class="paragraph"><p>Por medio del control de ACLs, se puede permitir o no realizar las diversas acciones masivas <strong>con independencia de las acciones normales</strong>. Esto quiere decir que, por ejemplo, <em>la acción de eleminar una máquina virtual y la opción de eliminar máquinas virtuales a través de acciones masivas están reguladas por ACLs diferentes</em>.</p></div>
</div>
</div>
</div>
</div>
<div id="footnotes"><hr /></div>
<div id="footer">
<div id="footer-text">
Last updated 2015-04-28 11:47:21 CEST
</div>
</div>
</body>
</html>
