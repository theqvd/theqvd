<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
<meta name="generator" content="AsciiDoc 8.6.9" />
<title>Introducción</title>
<style type="text/css">


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
<div class="dlist"><dl>
<dt class="hdlist1">
Vista listado básica
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/interface_list.png" alt="interface_list.png" width="960px" />
</span>
</p>
</dd>
<dt class="hdlist1">
Vista listado tras aplicar un filtro
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/interface_list_filtered.png" alt="interface_list_filtered.png" width="960px" />
</span>
</p>
</dd>
</dl></div>
<div class="paragraph"><p>Cuando una vista está filtrada por algún campo, para indicar que puede que no se estén mostrando el total de los elementos existentes, aparecerá sobre la lista una franja amarilla con los diferentes filtros activados.</p></div>
<div class="paragraph"><p>Desde este panel se pueden desactivar los filtros con el icono de un aspa que acompaña a cada uno, poniéndose automáticamente con el valor "Todos" en el selector correspondiente.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Vista listado tras aplicar un filtro y seleccionar un elemento
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/interface_list_checked.png" alt="interface_list_checked.png" width="960px" />
</span>
</p>
</dd>
</dl></div>
<div class="paragraph"><p>Si seleccionamos uno o varios elementos, aparecerá un menú lateral con las opciones a realizar sobre los elementos seleccionados. Este menú se puede cerrar con un botón en la parte superior del propio menú, o deseleccionando todos los elementos del listado.</p></div>
<div class="paragraph"><p>Si se edita un solo elemento será una edición estándar. Sin embargo, si se editan dos o más a la vez, se considera una edición masiva, por lo que algunos campos no estarán disponibles para la edición al no tener sentido.</p></div>
</div></div>
</li>
<li>
<p>
Captura por componentes
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/interface_list_components.png" alt="interface_list_components.png" width="960px" />
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
<strong>Control de acciones masivas</strong> sobre elementos seleccionados. Cuando seleccionamos una o varios elementos de la lista mediante la columna de casillas de verificación, aparecerá a la derecha un menú con las acciones disponibles sobre los elementos seleccionados. Entre estas acciones se encuentran editar, eliminar, bloquear, desbloquear y otras más concretas de cada vista como por ejemplo arrancar y parar máquinas virtuales.
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
<h2 id="_versión_móvil">5. Versión móvil</h2>
<div class="sectionbody">
<div class="paragraph"><p>La interfaz del WAT está diseñada para ser visualizada tanto en dispositivos con resoluciones grandes (Escritorio, Tablets&#8230;) como en dipositivos móviles. Para las pantallas pequeñas automáticamente se cargará una versión simplificada.</p></div>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="100%" />
<tbody>
<tr>
<td align="center" valign="top"><p class="table"><span class="image">
<img src="images/doc_images/mobile_version_home.png" alt="mobile_version_home.png" width="300px" />
</span></p></td>
</tr>
</tbody>
</table>
</div>
<div class="paragraph"><p>En esta versión el menú será un desplegable al que se accede haciendo click en el tipico icono de menú formado por barras horizontales.</p></div>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="100%" />
<tbody>
<tr>
<td align="center" valign="top"><p class="table"><span class="image">
<img src="images/doc_images/mobile_version_menu.png" alt="mobile_version_menu.png" width="300px" />
</span></p></td>
</tr>
</tbody>
</table>
</div>
<div class="dlist"><dl>
<dt class="hdlist1">
Características
</dt>
<dd>
<p>
La versión móvil tendrá todas las funcionalidades relativas a la administración de QVD. Esto incluye la lectura, creación, actualizado, eliminación y operación en los elementos de QVD: Usuarios, Máquinas virtuales, Nodos, OSFs e Imágenes de disco.
</p>
</dd>
</dl></div>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="100%" />
<tbody>
<tr>
<td align="center" valign="top"><p class="table"><span class="image">
<img src="images/doc_images/mobile_version_list_view.png" alt="mobile_version_list_view.png" width="300px" />
</span></p></td>
</tr>
</tbody>
</table>
</div>
<div class="paragraph"><p>De este modo acciones como arrancar o parar una máquina virtual estarán disponibles del mismo modo que en la versión de escritorio.</p></div>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="100%" />
<tbody>
<tr>
<td align="center" valign="top"><p class="table"><span class="image">
<img src="images/doc_images/mobile_version_actions.png" alt="mobile_version_actions.png" width="300px" />
</span></p></td>
</tr>
</tbody>
</table>
</div>
<div class="paragraph"><p>Las características relativas a la administración del WAT, tales como gestión de permisos y administradores, serán solo accesibles desde la versión escritorio del WAT.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Forzado de versión escritorio
</dt>
<dd>
<p>
Es posible forzar la versión de escritorio en los dispositivos móviles y con ello acceder a todas las funcionalidades.
</p>
</dd>
</dl></div>
<div class="tableblock">
<table rules="all"
width="100%"
frame="border"
cellspacing="0" cellpadding="4">
<col width="100%" />
<tbody>
<tr>
<td align="center" valign="top"><p class="table"><span class="image">
<img src="images/doc_images/mobile_version_desktop_button.png" alt="mobile_version_desktop_button.png" width="300px" />
</span></p></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_permisos_administrador_rol_acl">6. Permisos: Administrador-Rol-ACL</h2>
<div class="sectionbody">
<div class="paragraph"><p>Un <strong>administrador</strong> es un usuario dotado de credenciales y permisos para administrar una solución QVD a través de la herramienta de administración web (WAT).</p></div>
<div class="sect2">
<h3 id="_administradores">6.1. Administradores</h3>
<div class="paragraph"><p>Un administrador será creado por <strong>otro administrador</strong> del WAT siempre que tenga permisos para ello.</p></div>
<div class="paragraph"><p>No basta con crear un administrador para que pueda acceder al sistema. Hará falta asignarle permisos.</p></div>
</div>
<div class="sect2">
<h3 id="_permisos">6.2. Permisos</h3>
<div class="paragraph"><p>Los administradores del WAT pueden ser configurados para tener <strong>diferentes permisos para ver determinada información o realizar diferentes acciones</strong>. A estos permisos los denominamos <strong>ACLs</strong>.</p></div>
<div class="paragraph"><p>Dicha asignación no se realiza directamente, sino que se configuran una serie de <strong>roles con los ACLs deseados</strong> y dichos roles se asignan a los administradores.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/acls_roles_administrators.png" alt="acls_roles_administrators.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Si no tenemos el rol o conjunto de roles deseados para ese administrador deberemos crearlo.</p></div>
<div class="sect3">
<h4 id="_roles">6.2.1. Roles</h4>
<div class="paragraph"><p>A un rol se le pueden asignar ACLs y/o heredarlos de otros roles.</p></div>
<div class="paragraph"><p>En la herencia de roles es posible escoger qué ACLs heredar y cuales no.</p></div>
<div class="paragraph"><p>Un rol puedo heredar de uno o varios roles, así como un administrador puede tener uno o más roles asignados, adquiriendo sus ACLs.</p></div>
</div>
<div class="sect3">
<h4 id="_acls">6.2.2. ACLs</h4>
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
&#8230;
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
Last updated 2016-12-13 14:08:52 CET
</div>
</div>
</body>
</html>
