<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
<meta name="generator" content="AsciiDoc 8.6.9" />
<title>Introduction</title>
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
<h1>Introduction</h1>
<div id="toc">
  <div id="toctitle">Table of Contents</div>
  <noscript><p><b>JavaScript must be enabled in your browser to display the table of contents.</b></p></noscript>
</div>
</div>
<div id="content">
<div class="sect1">
<h2 id="_what_is_wat">1. What is WAT?</h2>
<div class="sectionbody">
<div class="paragraph"><p>WAT is the <strong>QVD Web administration panel</strong>. A web tool to <strong>manage QVD users, virtual machines, nodes, images and set&#8212;up parameters</strong>.</p></div>
<div class="paragraph"><p>To this end, it will show on the screen <strong>lists with system elements</strong> containing enough information to be able to <strong>setting them up</strong> as well as <strong>spotting problems</strong>. It will have <strong>filtered</strong> controls and a wide range of possible <strong>actions</strong> on the QVD elements, for instance, <strong>creating, updating or deleting</strong>; and other more specific ones such as starting or stopping the virtual machine, blocking a user to do some maintenance tasks, etc.</p></div>
<div class="paragraph"><p><strong>Client- Server</strong></p></div>
<div class="paragraph"><p>Regarding QVD administration, WAT refers to the <strong>clients</strong> part, feeding from the server  via  HTTP. In this way it extracts and manages QVD information by <strong>calls</strong> <strong>certified ones to the API</strong> of the server. This API also helps the application of command line administration (QVD CLI).</p></div>
</div>
</div>
<div class="sect1">
<h2 id="_browser_compatibility">2. Browser compatibility</h2>
<div class="sectionbody">
<div class="paragraph"><p>Hereafter the supported browsers are specified to use WAT with all their functionality. The use of older versions and/or browsers do not ensure its proper functioning.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Desktop
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
<th align="left" valign="top">Chrome</th>
<th align="left" valign="top">Firefox</th>
<th align="left" valign="top">Internet Explorer</th>
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
Mobile devices
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
<th align="left" valign="top">iOS Safari</th>
<th align="left" valign="top">iOS Chrome</th>
<th align="left" valign="top">Android Browser</th>
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
<h2 id="_interface_general_structure">3. Interface general structure</h2>
<div class="sectionbody">
<div class="paragraph"><p>WAT interface structure has 6 basic components:</p></div>
<div class="ulist"><ul>
<li>
<p>
Screenshot
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
Components screenshot
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
Detailed components
</p>
<div class="olist arabic"><ol class="arabic">
<li>
<p>
<strong>QVD logo</strong>: It is located at the top left-hand corner, by clicking on it you will access the home page.
</p>
</li>
<li>
<p>
<strong>General menu</strong>: A permanent menu at the top right-hand corner from where we can select different sections which include a classification of all QVD options:
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
<strong>Help</strong>: System information and documentation access.
</p>
</li>
<li>
<p>
<strong>Platform</strong>: QVD Element Management (Users, Virtual machines, Images&#8230;)
</p>
</li>
<li>
<p>
<strong>WAT Management</strong>: WAT set-up sections as well as administrators management, permits management, etc.
</p>
</li>
<li>
<p>
<strong>QDV Management</strong>: QDV parameter set-up sections.
</p>
</li>
<li>
<p>
<strong>Administrator Area</strong>: This section will have the name of the logged on administrator who will be able to access his/her profile, view customization or log out.
</p>
</li>
</ul></div>
<div class="paragraph"><p>This is a drop-down menu, so someone can have direct access to each section options just with one click.</p></div>
<div class="ulist"><ul>
<li>
<p>
Screenshot
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_drop_down.png" alt="menu_drop_down.png" width="960px" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>In the <strong>WAT step by step</strong> section, we will separately analise every section to learn its functioning.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Section Menu</strong>: Depending on which section of the general menu we are, there will be a menu with its different options under the head top.
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Screenshot
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
<strong>Breadcrumbs</strong>: Below the section menu, there will be at all times a link trace from the homepage to the current one.
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Screenshot
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/breadcrumbs.png" alt="breadcrumbs.png" width="300px" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>After the breadcrumbs, an icon of a book linked to a modal window will appear with the general documentation of the current section.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Content</strong>: Most of the screen, below the section menu and the breadcrumbs, will be left to show the page content.
</p>
</li>
<li>
<p>
<strong>Related documentation</strong>: At the bottom of each screen there are several links to parts of the documentation related to the section we are in. These links will open a modal window without exiting the screen where one can check the specific documentation.
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
Screenshot
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
<strong>Footnote</strong>: After all the content, it is the footnote with the application information.
</p>
</li>
</ol></div>
</li>
</ul></div>
</div>
</div>
<div class="sect1">
<h2 id="_detail_list_structure">4. Detail-list structure</h2>
<div class="sectionbody">
<div class="paragraph"><p>The management of WAT elements has common components throughout many sections. These elements form the detail-list structure.</p></div>
<div class="sect2">
<h3 id="_list_view">4.1. List view</h3>
<div class="paragraph"><p>View where a list of paged elements with filter and action controls are shown.</p></div>
<div class="ulist"><ul>
<li>
<p>
Screenshot
</p>
<div class="openblock">
<div class="content">
<div class="dlist"><dl>
<dt class="hdlist1">
Basic list view
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/interface_list.png" alt="interface_list.png" width="960px" />
</span>
</p>
</dd>
<dt class="hdlist1">
List view after applying a filter
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/interface_list_filtered.png" alt="interface_list_filtered.png" width="960px" />
</span>
</p>
</dd>
</dl></div>
<div class="paragraph"><p>When a view is filtered by some field, so as to point out that it may be possible that all the existing elements are not being shown, a yellow stripe will appear over the list containing all the filters which are on.</p></div>
<div class="paragraph"><p>From the panel, the filters can be disabled with the cross icon that goes with each of them, by automatically putting "All" value in the corresponding selector.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
List view after applying a filter and selecting an element
</dt>
<dd>
<p>
<span class="image">
<img src="images/doc_images/interface_list_checked.png" alt="interface_list_checked.png" width="960px" />
</span>
</p>
</dd>
</dl></div>
<div class="paragraph"><p>If we select one of the elements, a lateral menu will appear with all the available options on the selected elements. This menu can be closed with a button at the top of the same menu, or by selecting all the elements on the list.</p></div>
<div class="paragraph"><p>If only one element is edited, it will be a standard edition. However, if two or more are edited at the same time, it will be consider a massive edition, so some fields will not be available for the edition as it will not make sense.</p></div>
</div></div>
</li>
<li>
<p>
Components capture
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
Detailed components
</p>
<div class="olist arabic"><ol class="arabic">
<li>
<p>
<strong>Elements table</strong>: Elements list which matches the filtered ones (if there is any).
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Some of this list columns will have links to other WAT sections (if the system administrator is allowed to see those).
The main column which usually corresponds to the element name will have a link to the element detailed view. This link will go together with a magnifier link.</p></div>
<div class="paragraph"><p>This list will be paged to a number of elements by stting page. The columns in this table can be set <code>(See View Customization in the manual)</code>.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Button to create a new element</strong>
</p>
</li>
<li>
<p>
<strong>Pagination control</strong>: If there are not enough elements so as to have several pages, this control will be off. But if there are enough elements, it will allow us to browse within the different pages one by one or to go directly to the first or the last.
</p>
</li>
<li>
<p>
<strong>Selected element and current page information</strong>: the number of selected elements (either if they are in the current page or not) and the number of the page shown in relation to the total number of pages.
</p>
</li>
<li>
<p>
<strong>Checkboxes columns</strong> to select several elements at the same time and  apply an action on them.
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
It is possible <strong>to select some elements from different pages</strong> by moving within them with the paging control (3). Below the table the number of seleted elements will appear at all times (4).
</p>
</li>
<li>
<p>
It is also possible <strong>to select all the elements with just one click</strong> with the checkbox which is at the top of the table in that same column. If there are some pages it will give us the option to select only the visible ones or the elements from all the pages.
</p>
</li>
</ul></div>
</div></div>
</li>
<li>
<p>
<strong>Massive action control</strong> on the selected elements. When we select one or more elements from the list with the checkbox column, a menu will be shown on the right with the avalibale options for the selected elements. Among these actions are editing, deleting, locking, unlocking and some more specific actions for each view such as starting and stopping virtual machines.
</p>
</li>
<li>
<p>
<strong>Filtering controls</strong>: Depending on the element there will be some filters or others. Besides, these filters can also be set up (see View Customization in the manual).
</p>
</li>
<li>
<p>
<strong>Active filters</strong>: If there is some filter on, because it has been selected on the filtering control (7) or because the view has been loaded with the filter on, a box with the active filters will be shown. The unwanted filters can be deleted from here.
</p>
</li>
<li>
<p>
<strong>Information column</strong>: Many views contain a column with information icons. With these icons it is possible to see element information in a little place as well as to check if they are blocked, their executing status or if a user is connected or not in the case of the virtual machines, etc.
</p>
</li>
</ol></div>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_detail_view">4.2. Detail view</h3>
<div class="paragraph"><p>View where the element detail data is shown with the related information and the action, edition and deletion controls.</p></div>
<div class="ulist"><ul>
<li>
<p>
Screenshot
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
Componets capture
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
Detailed components
</p>
<div class="olist arabic"><ol class="arabic">
<li>
<p>
<strong>Element name</strong>
</p>
</li>
<li>
<p>
<strong>Action buttons</strong>: On both sides of the name we can find buttons to delete, edit, lock/unlock, start/stop&#8230; depending on the kind of element we are in, these buttons may vary.
</p>
</li>
<li>
<p>
<strong>Element data table</strong>: Some of them have links to other views.
</p>
</li>
<li>
<p>
<strong>Embedded lists of related elements</strong>. Many elements have detail views on a simplify embedded list of related elements.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><em>For instance, on a screenshot, a user&#8217;s virtual machines.</em></p></div>
<div class="paragraph"><p>This embedded view has a button to access the complete view of those elements, which by default will appear filtered by current element.</p></div>
<div class="paragraph"><p><em>For instance, on the screenshoot, we would go to the list view of the filtered virtual machines by user  'muser001'</em></p></div>
</div></div>
</li>
</ol></div>
</li>
</ul></div>
</div>
<div class="sect2">
<h3 id="_creation_edition_forms">4.3. Creation-edition forms</h3>
<div class="paragraph"><p>In both views, to create or edit an element, the different forms will be shown on modal windows, without leaving the view context.</p></div>
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
<h2 id="_mobile_version">5. Mobile version</h2>
<div class="sectionbody">
<div class="paragraph"><p>The WAT interface is designed to display not only high resolution devices (Desktops, Tablets&#8230;) but mobile devices as well. A simplified version will automatically be loaded for small screens.</p></div>
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
<div class="paragraph"><p>In this version the menu will be a  drop-down which we can access by clicking the usual horizontal stripes icon from the menu.</p></div>
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
Features
</dt>
<dd>
<p>
The mobile version will have all the functions regarding QVD management. This includes the QVD elements reading, creation, update, deletion and operation: Users, Virtual Machines, Nodes, ODFs and Disc Images.
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
<div class="paragraph"><p>In this way actions such as starting or stopping the virtual machine are available in the same way they are for the Desktop version.</p></div>
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
<div class="paragraph"><p>Features regarding WAT management, such as permit management or system administrators, will only be accessed from WAT desktop version.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Forced desktop version
</dt>
<dd>
<p>
It is possible to force the desktop version in mobile devices and in that way access all the functions.
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
<h2 id="_permits_system_administrator_acl_role">6. Permits: System Administrator-ACL-Role</h2>
<div class="sectionbody">
<div class="paragraph"><p>A <strong>system administrator</strong> is a user who has been provided with credentials and permits to manage a QVD solution with the administration web tool (WAT).</p></div>
<div class="sect2">
<h3 id="_system_administrators">6.1. System Administrators</h3>
<div class="paragraph"><p>A system administrator will be created in place of <strong>other system administrator</strong> from WAT as long as he has the required permits.</p></div>
<div class="paragraph"><p>It is not enough creating a system administrator so that he can access the system. It will be necessary to assign permits.</p></div>
</div>
<div class="sect2">
<h3 id="_permits">6.2. Permits</h3>
<div class="paragraph"><p>WAT system administrators can be set up to have * different permits to see specific information or to carry out different actions*. These permits are named <strong>ACLs</strong>.</p></div>
<div class="paragraph"><p>That assignment will not be carried out directly, but several <strong>roles with desirable ACLs</strong> will be set up and those roles will be given to the system administrators.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/acls_roles_administrators.png" alt="acls_roles_administrators.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>If we don&#8217;t have the role or roles we wish for those system administratos, we must create them.</p></div>
<div class="sect3">
<h4 id="_roles">6.2.1. Roles</h4>
<div class="paragraph"><p>We can assign ACLs to a role and/or it can inherit it from other roles.</p></div>
<div class="paragraph"><p>Regarding role inheritance, it is possible to choose which ACLs to inherit and which not to.</p></div>
<div class="paragraph"><p>A role can inherit from one or more roles, as well as a system administrator can have one or more assigned roles, by adquiring his ACLs.
==== ACLs</p></div>
<div class="paragraph"><p>The features and the rest of the things to consider from ACLs can be summarise on the following points:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>ACLs are fixed</strong> in the system. They cannot be added or deleted.
</p>
</li>
<li>
<p>
Every ACL will give permission to <strong>see or do only one thing</strong> in a type or element or section.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>For example:</p></div>
</div></div>
<div class="ulist"><ul>
<li>
<p>
Access disc images section
</p>
</li>
<li>
<p>
See nodes IP address
</p>
</li>
<li>
<p>
Delete users
</p>
</li>
<li>
<p>
Create OSFs
</p>
</li>
<li>
<p>
Filter virtual machines by user
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
There are specific ACLs to manage system administrators' permits: To assign ACLs to roles, roles to system administrator, etc.
</p>
</li>
<li>
<p>
A system administrator with the ACLs to manage permits will be able to:
</p>
<div class="ulist"><ul>
<li>
<p>
Manage all ACLs in the system, and not only those the administrator has in his assigned roles. The system administrator will be able to assign ACLs, which he does not have, to roles and thus to administrators.
</p>
</li>
<li>
<p>
Manage his own ACLs, in this way being able to get total permits or even lose them. That is why <strong>ACLs management is very sensitive</strong>.
</p>
</li>
</ul></div>
</li>
</ul></div>
<div class="paragraph"><p>To learn more about set up premits see <code>System Administrators and Permits</code> guide.</p></div>
</div>
</div>
</div>
</div>
</div>
<div id="footnotes"><hr /></div>
<div id="footer">
<div id="footer-text">
Last updated 2016-11-14 12:42:19 CET
</div>
</div>
</body>
</html>
