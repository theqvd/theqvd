<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
<meta name="generator" content="AsciiDoc 8.6.9" />
<title>Guía multitenant</title>
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
<div class="content">
<pre><code>Por ejemplo, si a un administrador le damos permisos de lectura sobre las imágenes de disco, podrá ver todas las imágenes del sistema, no podremos limitarlo a un subconjunto de ellas.</code></pre>
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
<div class="content">
<pre><code>Por ejemplo, a un administrador se le podrán asignar permisos de lectura sobre imágenes de disco, con el que solo podrá ver las que haya en su tenant, y un nivel más avanzado de gestión en máquinas virtuales, con el que podrá, además de visualizar, crear y actualizar las máquinas virtuales a las que tenga acceso (las de su tenant).</code></pre>
</div></div>
<div class="paragraph"><p>Los administradores de un tenant estarán <strong>aislados en su tenant</strong>, sin que sepan que existen otros ámbitos. Solo verán los elementos de QVD que hay en ese tenant. El administrador ni siquiera será consciente de si está trabajando en un WAT monotenant o en un tenant dentro de un WAT multitenant.</p></div>
<div class="paragraph"><p>En un WAT multitenant, existirá un <strong>ámbito superior</strong> al que denominaremos <strong>Supertenant ó Tenant <em></strong></em>* que englobará a todos los demás. Los administradores de este Supertenant están pensados para tareas de <strong>configuración y supervisión</strong> ya que podrán gestionar elementos de QVD de <strong>cualquier tenant</strong> siendo conscientes de la distribución, pudiendo filtrar elementos por tenant, o elegir en qué tenant crear un determinado elemento.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">Cuando un administrador del Supertenant crea elementos, puede <strong>escoger en qué Tenant</strong> hacerlo. Del mismo modo, deberá tener en cuenta que <strong>no puede relacionar elementos de diferentes Tenants entre sí</strong>, por lo que, por ejemplo, si desea crear una máquina virtual en el Tenant A, deberá existir al menos un OSF, una Imagen de disco asociada a dicho OSF y un usuario en el Tenant A.</td>
</tr></table>
</div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Monotenant-Multitenant.png" alt="Monotenant-Multitenant.png" width="600px" />
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
<img src="images/doc_images/login_multitenant.png" alt="login_multitenant.png" width="960px" />
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
<div class="paragraph"><p>La vista principal es un listado con los tenants del WAT.
<span class="image">
<img src="images/doc_images/screenshot_tenant_list.png" alt="screenshot_tenant_list.png" width="960px" />
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
<img src="images/doc_images/screenshot_tenant_massiveactions.png" alt="screenshot_tenant_massiveactions.png" width="960px" />
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
<img src="images/doc_images/screenshot_tenant_create.png" alt="screenshot_tenant_create.png" width="960px" />
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
<img src="images/doc_images/screenshot_tenant_details.png" alt="screenshot_tenant_details.png" width="960px" />
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
<img src="images/doc_images/icons/warning.png" alt="Warning" />
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
<img src="images/doc_images/screenshot_tenant_edit.png" alt="screenshot_tenant_edit.png" width="960px" />
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
<img src="images/doc_images/default_views_multitenant.png" alt="default_views_multitenant.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>A la hora de reestablecer las vistas por defecto, también podremos escoger si queremos aplicar esta acción sobre el tenant cargado en ese momento en la sección o bien sobre todos los tenants del sistema, incluyendo el supertenant *.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/default_views_multitenant_reset.png" alt="default_views_multitenant_reset.png" width="960px" />
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
<div class="paragraph"><p><strong>En el caso de los Nodos</strong>, al no pertenecer a ningún tenant pero sí poder tener propiedades diferentes en cada uno de los tenants incluído el supertenant <em>*</em>, <strong>la vista será simplificada</strong>. Cada administrador verá las propiedades de Nodos del tenant al que pertenece. Esto se extiende tambien al superadministrador, que sólamente verá las propiedades de Nodos del supertenant <em>*</em>.</p></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_primeros_pasos_multitenant">6. Primeros pasos multitenant</h2>
<div class="sectionbody">
<div class="paragraph"><p>Si es la primera vez que activamos el modo multitenant, podremos iniciar sesión con el superadministrador que viene por defecto en el sistema. Sus credenciales son:</p></div>
<div class="literalblock">
<div class="content">
<pre><code>Usuario: superadmin
Contraseña: superadmin</code></pre>
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
<th align="left" valign="top">ACL </th>
<th align="left" valign="top">código ACL </th>
<th align="left" valign="top">Descripción</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left" valign="top"><p class="table"><strong>Crear tenants</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.create.</p></td>
<td align="left" valign="top"><p class="table">Crear tenants incluyendo la configuración inicial por nombre.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Eliminar tenants (masivamente)</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.delete-massive.</p></td>
<td align="left" valign="top"><p class="table">eliminar masivamente los tenants.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Eliminar tenants</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.delete.</p></td>
<td align="left" valign="top"><p class="table">Eliminación de tenants uno por uno.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filtrar los tenants bloqueando su estatus</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.filter.block</p></td>
<td align="left" valign="top"><p class="table">Filtrar listado de tenants bloqueando sus estatus</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filtrar tenants por creador</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.filter.created-by</p></td>
<td align="left" valign="top"><p class="table">Filtro del listado de tenants por el administrador que lo creo</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filtrar tenants por fecha de creación</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.filter.creation-date</p></td>
<td align="left" valign="top"><p class="table">Filtrar el listado de tenants por la fecha cuando fue creado</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Filtrar tenants por nombre</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.filter.name</p></td>
<td align="left" valign="top"><p class="table">Filtrar el listado de tenants por el nombre del tenant.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Acceso a la vista de los detalles del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see-details.</p></td>
<td align="left" valign="top"><p class="table">Acceso a la vista de detalles de los Tenants. Esta vista incluye nombre</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Acceso a la sección principal del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see-main.</p></td>
<td align="left" valign="top"><p class="table">Acceso al listado de tenants. Esta vista incluye nombre</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver el tamaño del bloque del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.blocksize</p></td>
<td align="left" valign="top"><p class="table">El tamaño del bloque en los listados de paginación de los tenants..</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver el estado de bloqueo del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.block</p></td>
<td align="left" valign="top"><p class="table">Estado bloqueado (bloqueado/desbloqueado) de los tenants.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver el creador del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.created-by</p></td>
<td align="left" valign="top"><p class="table">El administrador WAT que creó el tenant</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver fecha de creación del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.creation-date</p></td>
<td align="left" valign="top"><p class="table">Fecha y hora de creación cuando se creó el tenant</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver la descripción del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.description</p></td>
<td align="left" valign="top"><p class="table">La descripción de los tenants.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver imagenes de disco del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.di-list</p></td>
<td align="left" valign="top"><p class="table">Ver imágenes de disco de este tenant en su vista detalle. Esta vista contiene: nombre, bloque, etiquetas, por defecto y encabezado</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver el estado bloqueado del disco del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.di-list-block</p></td>
<td align="left" valign="top"><p class="table">Bloqueado de la información del disco de imágenes que se muestra en la vista detalle del tenant</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver las etiquetas de las imágenes de disco del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.di-list-tags</p></td>
<td align="left" valign="top"><p class="table">Etiquetas de imágenes de disco que aparecen en la vista detalle en el tenant.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver identificación del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.id</p></td>
<td align="left" valign="top"><p class="table">La base de datos que identifica los tenants. Útil para hacer llamadas desde CLI.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver idioma del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.language</p></td>
<td align="left" valign="top"><p class="table">El idioma establecido por defecto para cualquier administrador que pertenezca a un tenant</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver usuarios del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.user-list</p></td>
<td align="left" valign="top"><p class="table">Ver usuarios de un tenant en su vista detalle. Esta vista incluirá: el nombre y la información de bloqueo para cada usuario.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver el estado bloqueado del usuario del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.user-list-block</p></td>
<td align="left" valign="top"><p class="table">Información de bloqueo de los usuarios que aparece en la vista detalle del tenant.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver máquinas virtuales del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.vm-list</p></td>
<td align="left" valign="top"><p class="table">Ver las máquinas virtuales de un tenant en la vista detallada. Esta vista incluye: nombre, estado,de bloqueo y fecha de vencimiento de cada mv</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver el estado de bloqueo de las máquinas virtuales</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.vm-list-block</p></td>
<td align="left" valign="top"><p class="table">La información del bloqueo de las máquinas virtuales aparece en la vista detallada del tenant</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver fecha de vencimiento de las máquinas virtuales del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.vm-list-expiration</p></td>
<td align="left" valign="top"><p class="table">La información sobre el vencimiento de las máquinas virtuales aparece en las vista detallada del tenant</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver estado de funcionamiento de las máquinas virtuales del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.vm-list-state</p></td>
<td align="left" valign="top"><p class="table">El estado (apagado/encendido) de las máquinas virtuales aparece en la vista detallada del tenant</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Ver el estado de usuario de las máquinas virtuales del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.see.vm-list-user-state</p></td>
<td align="left" valign="top"><p class="table">Estado del usuario (conectado/desconectado) de las máquinas virtuales que aparece en la vista detallada del tenant</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Tenants bloqueados y desbloqueados (masivo)</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.update-massive.block</p></td>
<td align="left" valign="top"><p class="table">Actualizar masivamente el estado de bloqueo (bloqueado/desbloqueado)</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Actualizar el tamaño del bloque del tenant (masivo)</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.update-massive.blocksize</p></td>
<td align="left" valign="top"><p class="table">Actualizar el tamaño del bloque en el listado de paginación de los tenants masivamente.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Actualizar la descripción del tenant (masiva)</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.update-massive.description</p></td>
<td align="left" valign="top"><p class="table">Actualizar masivamente la descripción de los tenants.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Actualizar el lidioma del tenant (masivo)</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.update-massive.language</p></td>
<td align="left" valign="top"><p class="table">Actualizar el idioma de los tenant de forma masiva.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Tenants bloqueados-desbloqueados</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.update.block</p></td>
<td align="left" valign="top"><p class="table">Actualizar el estado de bloqueo (bloqueado/desbloqueado) de los tenants uno por uno.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Actualizar el tamaño bloque del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.update.blocksize</p></td>
<td align="left" valign="top"><p class="table">Actualizar el tamaño del bloque en los listados de paginación uno por uno.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Actualizar la descripción del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.update.description</p></td>
<td align="left" valign="top"><p class="table">Actualizar la descripción de los tenants uno por uno.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Actualizar el lenguaje del tenant</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.update.language</p></td>
<td align="left" valign="top"><p class="table">Actualizar el lenguaje de los tenants uno por uno.</p></td>
</tr>
<tr>
<td align="left" valign="top"><p class="table"><strong>Actualizar el nombre de los tenants</strong></p></td>
<td align="left" valign="top"><p class="table">tenant.update.name</p></td>
<td align="left" valign="top"><p class="table">Actualizar el nombre de los tenants.</p></td>
</tr>
</tbody>
</table>
</div>
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
<img src="images/doc_images/Templates_Hierarchy_-_Tenants_Manager.png" alt="Templates_Hierarchy_-_Tenants_Manager.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>Los Tenants no tienen plantilla de operación al no tener operativa más allá de ver, crear, actualizar y borrar. Si en un futuro se añadiera, sería heredada por esta plantilla de gestión.</p></div>
</div></div>
</li>
</ul></div>
<div class="sect3">
<h4 id="_jerarquía_de_plantillas_multitenant">7.6.1. Jerarquía de Plantillas (Multitenant)</h4>
<div class="paragraph"><p>Cuando el sistema está en modo multitenant, la jerarquía de Plantillas tiene Plantillas adicionales. Se pueden ver de un vistazo en el siguiente esquema:</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/Templates_Hierarchy_Monotenant.png" alt="Templates_Hierarchy_Monotenant.png" width="960px" />
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
<div class="content">
<pre><code>Usuario: batman
Contraseña: to the rescue</code></pre>
</div></div>
<div class="paragraph"><p>En este caso tendrá ligeras diferencias con el que tendremos en modo monotenant.</p></div>
<div class="paragraph"><p>Básicamente <strong>la diferencia será</strong>, que en este modo, <strong>el administrador de recuperación tendrá</strong>, además de los que tiene en modo monotenant, <strong>acceso a gestión de Tenants</strong>.</p></div>
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
