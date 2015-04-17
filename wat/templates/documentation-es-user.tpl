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
<strong>Árbol de ACLs</strong>: Se mostrarán los ACLs del sistema en forma de árbol con casillas de verificación. Seleccionaremos aquellos ACLs que queremos que el rol contenga.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Las ramas, a su vez, también disponen de casilla de verificación para seleccionar/deseleccionar ramas enteras con un solo click.</p></div>
<div class="paragraph"><p>Según nuestras preferencias, podemos representar el árbol en <strong>dos clasificaciones</strong> distintas:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Por secciones</strong>: Si deseamos agrupar los ACLs según las secciones del WAT a las que afectan: usuarios, máquinas virtuales, nodos, administradores&#8230;
</p>
</li>
</ul></div>
<div class="paragraph"><p>Útil si queremos crear un rol que otorgue permisos con mucha profundidad pero poca amplitud.</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Por ejemplo, permisos totales en usuarios y máquinas virtuales.</code></pre>
</div></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Por acciones</strong>: Si nos es más cómodo agrupar los ACLs según el tipo de acción que permiten: crear, eliminar, acceder a vista principal, filtrar&#8230;
</p>
</li>
</ul></div>
<div class="paragraph"><p>Útil si queremos crear un rol que otorgue permisos con poca profundidad y mucha amplitud.</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Por ejemplo, permisos de solo lectura en casi todas las secciones.</code></pre>
</div></div>
</div></div>
</li>
<li>
<p>
<strong>Herencia de roles</strong>: Se podrán heredar tantos roles como queramos, adoptando sus ACLs.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Cuando heredemos un rol, observaremos como en el árbol cambia, activándose los nuevos ACLs.</p></div>
<div class="paragraph"><p>Junto a cada ACL que provenga de uno o varios roles heredados, aparecerá un icono. Al pasar el ratón sobre él nos aparecerá información a cerca de qué roles procede.</p></div>
<div class="paragraph"><p>Se podrán heredar dos tipos de roles:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Roles normales</strong>: Son los roles creados a través del WAT. Serán los que <strong>se muestran en la lista de roles</strong> y se pueden asignar a los administradores.
</p>
</li>
<li>
<p>
<strong>Roles internos</strong>: Estos roles son roles especiales que vienen en la instalación de QVD y no pueden ser gestionados ni asignados a un administrador. <strong>No saldrán en la lista de roles</strong>.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Estos roles solamente aparecen como roles heredables en la gestión de un rol.</p></div>
<div class="paragraph"><p>Están pensados para facilitar la gestión de roles abstrayendo al administrador de los ACLs.</p></div>
<div class="paragraph"><p>Los nombres de los roles internos son descriptivos de los ACLs que poseen.</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Por ejemplo: Users Creator, Images Operator, VMs Manager o Master.</code></pre>
</div></div>
<div class="paragraph"><p>No obstante heredándolos en un rol y observando los cambios en el árbol de ACLs podemos observar los ACLs que nos aportarán.</p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>Para conocer los roles, tanto internos como normales, que una instalación de QVD incluye, ver Referencia de roles en el manual.</p></div>
<div class="paragraph"><p>Un inconveniente de la herencia es que si en el futuro <strong>cambian los ACLs de un rol</strong>, todos los que lo hereden sufrirán cambios con él. Por eso hay que utilizar esta técnica con cuidado.</p></div>
<div class="paragraph"><p>Otro inconveniente son las futuras actualizaciones del WAT dónde puedan aparecer <strong>nuevos ACLs</strong>. Para evitar esto heredaremos, en la medida de lo posible, los roles Internos para configurar nuestros roles. Estos roles, serán actualizados con el WAT, conteniendo los nuevos ACLs de una forma coherente con su uso.</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Por ejemplo: Si se añadie un nuevo campo en la vista de usuarios, el ACL que permita su visualización será añadido el rol interno Users Reader. Los roles que hereden de este rol interno, se actualizarán y no perderán funcionalidad, evitando molestas revisiones de los roles en cada actualización.</code></pre>
</div></div>
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
<h2 id="_propiedades_libres">7. Propiedades libres</h2>
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
<h2 id="_acciones_masivas">8. Acciones masivas</h2>
<div class="sectionbody">
<div class="paragraph"><p>En algunas vistas listado existe la posibilidad de realizar acciones masivas. Cuando esto sucede observaremos que la primera columna de la tabla listado es una columna de casillas de verificación.</p></div>
<div class="sect2">
<h3 id="_selección_de_elementos">8.1. Selección de elementos</h3>
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
<h3 id="_selector_de_acciones_masivas">8.2. Selector de acciones masivas</h3>
<div class="paragraph"><p>De estar disponibles, debajo de la tabla de un listado, habrá un control de selección de acciones masivas. Bastará con seleccionar la acción deseada y hacer click en el botón <em>Aplicar</em> para llevarlas a cabo <strong>sobre los elementos seleccionados</strong>.</p></div>
</div>
<div class="sect2">
<h3 id="_tipos_de_acciones_masivas">8.3. Tipos de acciones masivas</h3>
<div class="paragraph"><p>Las acciones masivas pueden ser de diferente naturaleza:</p></div>
<div class="ulist"><ul>
<li>
<p>
Edición:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Con la acción de edición se pueden editar los <strong>atributos comunes</strong> de los elementos que se seleccionen.</p></div>
</div></div>
</li>
<li>
<p>
Borrado:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Con la acción de borrado se pueden eliminar elementos de forma masiva.</p></div>
</div></div>
</li>
<li>
<p>
Ejecución:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>En esta categoría se engloban las acciones que no son ni de edición ni de borrado: <em>Arrancar/Detener máquinas virtuales, desconectar usuarios, bloquear/desbloquear elementos&#8230;</em></p></div>
</div></div>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_restricción_de_acciones_masivas">8.4. Restricción de acciones masivas</h3>
<div class="paragraph"><p>Por medio del control de ACLs, se puede permitir o no realizar las diversas acciones masivas <strong>con independencia de las acciones normales</strong>. Esto quiere decir que, por ejemplo, <em>la acción de eleminar una máquina virtual y la opción de eliminar máquinas virtuales a través de acciones masivas están reguladas por ACLs diferentes</em>.</p></div>
</div>
</div>
</div>
</div>
<div id="footnotes"><hr /></div>
<div id="footer">
<div id="footer-text">
Last updated 2015-04-17 14:57:59 CEST
</div>
</div>
</body>
</html>
