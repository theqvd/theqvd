<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
<meta name="generator" content="AsciiDoc 8.6.9" />
<title>WAT step by step</title>
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
<h1>WAT step by step</h1>
<div id="toc">
  <div id="toctitle">Table of Contents</div>
  <noscript><p><b>JavaScript must be enabled in your browser to display the table of contents.</b></p></noscript>
</div>
</div>
<div id="content">
<div id="preamble">
<div class="sectionbody">
<div class="paragraph"><p>In the guide ' WAT step by step ' we will see from the user login to the most complex sections, going over the different WAT sections, analyzing its use and key aspects.</p></div>
<div class="paragraph"><p>We find these sections in the general menu placed on the right part of the header.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_general.png" alt="menu_general.png" width="960px" />
</span></p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/important.png" alt="Important" />
</td>
<td class="content">it is necessary to bear in mind that <strong>no all the administrators need to have the same permissions</strong>, and therefore, not all of them will see each of the sections or buttons that are going to be described next.</td>
</tr></table>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_login_screen">1. Login screen</h2>
<div class="sectionbody">
<div class="paragraph"><p>When WAT is loaded, the first thing that appears will be a login screen, where we can authenticate with our credentials <em>username / password</em>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/login.png" alt="login.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The first time you log in, you will be asked if you want to save username and password for the future (when the browser allows it)</p></div>
</div>
</div>
<div class="sect1">
<h2 id="_home_page">2. Home Page</h2>
<div class="sectionbody">
<div class="paragraph"><p>The first screen which is shown when you log in is a tactical view formed by graphs and tables summary of the system.</p></div>
<div class="paragraph"><p>In addition to this, below the title, there are some buttons available with the uses.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/home.png" alt="home.png" width="960px" />
</span></p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Uses
</dt>
<dd>
<div class="ulist"><ul>
<li>
<p>
<strong>Help</strong>: Link to WAT documentation.
</p>
</li>
<li>
<p>
<strong>Export to PDF</strong>: With this button a PDF document with the Widgets of statistics will be made and downloaded.
</p>
</li>
<li>
<p>
<strong>Export to CSV</strong>: With this button a plain text document with CSV format will be downloaded. It will contain the different statistic data in which the graphs are based.
</p>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Widgets of statistics
</dt>
<dd>
<div class="ulist"><ul>
<li>
<p>
*Row 1: Summary of elements. Of each of the basic elements of QVD (Users, Virtual Machines, Nodes, OSFs and Disk Images) their main statistics will be displayed.
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Users</strong>: Number of users, how many of them are blocked and how many of them are connected at least to a virtual machine.
</p>
</li>
<li>
<p>
<strong>Virtual Machines</strong>: Number of users, how many of them are blocked and how many of them are connected to at least a virtual machine.
</p>
</li>
</ul></div>
</li>
<li>
<p>
*Row 2: Circular graphs * with relevant information.
</p>
<div class="ulist"><ul>
<li>
<p>
*Running virtual machines *: The relation between the virtual machines running with regard to the total of virtual existing machines is shown in a pie chart.
</p>
</li>
<li>
<p>
<strong>Connected Users</strong>: The relation between the connected users to at least a virtual machine with regard to the total of existing users is shown in a pie chart.
</p>
</li>
<li>
<p>
<strong>Running Nodes</strong>: The relation between the running nodes with regard to the total of existing nodes is shown in a pie chart.
</p>
</li>
</ul></div>
</li>
<li>
<p>
<strong>Row 3: Other summaries.</strong>
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Virtual machines close to expire</strong>: The virtual machines whose expiration date is near are displayed.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>In this list * hard expiration date *will be taken into account, displaying the time remaining up to that moment. According to the proximity of the expiration the dates will appear in different colours: red (very near), yellow (near) or green (slightly near).</p></div>
<div class="paragraph"><p>The virtual machines are arranged from the closest to the expiration date to the furthest, taking a critical colour as it gets closer to the moment.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Nodes with more virtual machines running</strong>: In a bar chart the nodes of the system with more virtual machines running will be displayed. The nodes will be arranged from the one which has more virtual machines to the one with fewest.
</p>
</li>
<li>
<p>
<strong>Blocked elements</strong>: In a summary table the counting of QVD <strong>blocked</strong> elements is displayed. The elements which are likely to be blocked are the users, virtual machines, nodes and disk images.
</p>
</li>
</ul></div>
</li>
</ul></div>
</dd>
</dl></div>
</div>
</div>
<div class="sect1">
<h2 id="_help">3. Help</h2>
<div class="sectionbody">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_help.png" alt="menu_help.png" width="600px" />
</span></p></div>
<div class="sect2">
<h3 id="_about">3.1. About</h3>
<div class="paragraph"><p>This section shows information about which QVD version is being used as well as the WAT revision.</p></div>
</div>
<div class="sect2">
<h3 id="_documentation">3.2. Documentation</h3>
<div class="paragraph"><p>In this section we can check the WAT documentation.</p></div>
<div class="paragraph"><p>The documentation is divided in several guides, we can find among them:</p></div>
<div class="ulist"><ul>
<li>
<p>
An <strong>Introduction</strong> guide, including a general description of the WAT interface elements, as well as some clues to understand some complex functions.
</p>
</li>
<li>
<p>
A <strong>WAT step by step</strong> description where every screen on the different menus is explained through screenshots.
</p>
</li>
<li>
<p>
A <strong>User&#8217;s guide</strong> with instructions to deal with common tasks, such as, how to face the first steps,  change the password, create a virtual machine from scratch, update an image or manage administrators' permits.
</p>
</li>
</ul></div>
<div class="paragraph"><p>Besides, the documentation has a search box to quickly find the results on any available guide.</p></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_platform">4. Platform</h2>
<div class="sectionbody">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_platform.png" alt="menu_platform.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>In this section we will find the different QVD elements. It is considered * core administration of QVD*.</p></div>
<div class="literalblock">
<div class="content">
<pre><code>All of them have some *common components* with a list view, paging controls, filtering and massive actions, detail view and creation/edition forms. For further information visit "Structure list-detail" in the introduction of the documentation.</code></pre>
</div></div>
<div class="sect2">
<h3 id="_users">4.1. Users</h3>
<div class="paragraph"><p>In this part the users of QVD are managed including their credentials to access the virtual machines that are configured through the client of the QVD.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
List view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>The main view is a list with the users of QVD.
<span class="image">
<img src="images/doc_images/screenshot_user_list.png" alt="screenshot_user_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Information column
</dt>
<dd>
<p>
The information column will indicate us:
</p>
<div class="ulist"><ul>
<li>
<p>
The <strong>blocking state</strong> of the users:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Locked</strong> Lock icon.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_locked.png" alt="icon_locked.png" />
</span></p></div>
<div class="paragraph"><p>A blocked user will not be able to log in to any of their virtual machines.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Unlocked</strong> If the lock icon does not appear.
</p>
</li>
</ul></div>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Massive actions
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_massiveactions.png" alt="screenshot_user_massiveactions.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Ths massive actions give us the following options to do on the selected users:</p></div>
<div class="paragraph"><p>*Lock users
*Unlock users
*Disconnect users of all the virtual machines where they are connected
*Delete users
*Edit users: The password of the users will not appear in the massive editor. To change the password it will be needed to be done one by one from the detail view.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">If only one element is selected, in the case of the edition we can edit the same fields that with the normal edition of an element in the detail view.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Massive editor
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_massiveeditor.png" alt="screenshot_user_massiveeditor.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The massive editor of the users only let us modify the custom properties.</p></div>
<div class="paragraph"><p>As any other massive editor, the value which will be defined, it would rewrite the one that could exist in all the edited elements unless "No changes" option were selected.</p></div>
<div class="paragraph"><p>If custom properties do not exist in the users the massive edition will not be authorised.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Creation
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_create.png" alt="screenshot_user_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When creating a user we will establish its name, password and properties.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Detail view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_details.png" alt="screenshot_user_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>We observe a small <strong>head top</strong> next to the <strong>username</strong> where <strong>the buttom to delete it and the action buttoms</strong> are.</p></div>
<div class="paragraph"><p>The available buttoms in the detail view of the user are:</p></div>
<div class="paragraph"><p>*Locking/Unlocking the user
*Editing the user</p></div>
<div class="paragraph"><p>Below this head top there is a <strong>table with the attributes of the user</strong> including the properties, if there were.</p></div>
<div class="paragraph"><p>And on the right part we find:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>The virtual machines asociated to this user</strong>
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>If we want more actions on them with the extended view buttom we go to the list of the virtual machines filtered by this user.</p></div>
<div class="paragraph"><p>In this case, which is different from other detail views, we also have a <strong>buttom to create a virtual machine asociated to the current user</strong>, where the same creation form of the virtual machines, except the user, will appear to which the machine will be asociated, that is implicit since it is created from here.</p></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Edition
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_user_edit.png" alt="screenshot_user_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When editing a new user we can choose among changing the <strong>password</strong> (if we do not select the check box, it will remain unchanged) and <strong>editing properties.</strong></p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">We can also access to the edition of the element from the list view with the massive actions only if we select one element.</td>
</tr></table>
</div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_virtual_machines">4.2. Virtual Machines</h3>
<div class="paragraph"><p>In this part the virtual machines of QVD including the image that they execute are managed.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
List view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>The main view is a list with the virtual machines of QVD.
<span class="image">
<img src="images/doc_images/screenshot_vm_list.png" alt="screenshot_vm_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Information column
</dt>
<dd>
<p>
The information column will indicate us:
</p>
<div class="ulist"><ul>
<li>
<p>
The <strong>blocking stauts</strong> of the virtual machines:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Locked</strong>. Lock icon
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_locked.png" alt="icon_locked.png" />
</span></p></div>
<div class="paragraph"><p>A blocked virtual machine will not be able to start.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Unlocked</strong> If the lock icon does not appear.
</p>
</li>
</ul></div>
</li>
<li>
<p>
If the virtual machines have defined an <strong>expiration date</strong>
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>With expiration date</strong> Clock icon.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_expire.png" alt="icon_expire.png" />
</span></p></div>
<div class="paragraph"><p>This icon shows that there is an expiration stablished, <strong>whether it is soft or hard</strong>.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Without expiration date</strong>. If the clock icon does not appear.
</p>
</li>
</ul></div>
</li>
<li>
<p>
<strong>Executing State</strong> of the virtual machines.
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Stopped</strong>. Stop icon.
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
<strong>Stopping</strong>. Blinking stop icon.
</p>
</li>
<li>
<p>
<strong>Running</strong>. Play icon.
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
<strong>Starting</strong>. Blinking play icon.
</p>
</li>
</ul></div>
</li>
<li>
<p>
<strong>Connection status of the user</strong> of the virtual machines
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>User connected</strong>. User icon.
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
<strong>User not connected</strong>. If the user icon does not appear.
</p>
</li>
</ul></div>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Massive actions
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_massiveactions.png" alt="screenshot_vm_massiveactions.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The massive actions give us the following options to do on the selected virtual machines:</p></div>
<div class="ulist"><ul>
<li>
<p>
Start virtual machines
</p>
</li>
<li>
<p>
Stop virtual machines
</p>
</li>
<li>
<p>
Locki virtual machines
</p>
</li>
<li>
<p>
Unlock virtual machines
</p>
</li>
<li>
<p>
Disconnect the user of the virtual machines
</p>
</li>
<li>
<p>
Delete user session
</p>
</li>
<li>
<p>
Edit virtual machines: the name of the virtual machines will not appear in the massive editor. To change the name it will be needed to do it one by one from the detail view.
</p>
</li>
</ul></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">If only one element is selected, in the case of the edition we can edit the same fields that with the normal edition of an element in the detail view.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Massive editor
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_massiveeditor.png" alt="screenshot_vm_massiveeditor.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The massive editor of the virtual machines let us change the tag of the image used, assign an expiration date and modify custom properties.</p></div>
<div class="paragraph"><p>As any other massive editor, the value which will be defined, it would rewrite the one that could exist in all the edited elements unless "No changes" option were selected.</p></div>
<div class="paragraph"><p>The expiration control will be seen in the part of the Edition of the virtual machines.</p></div>
<div class="paragraph"><p>Regarding the tag of the image, when we edit massively virtual machines we have two posibilities:</p></div>
</div></div>
<div class="ulist"><ul>
<li>
<p>
The virtual machines having assigned the same OSF: In this case the tag selector of an image will show all the tags of the images of the <strong>assigned OSF</strong> as well as the special tags <em>default</em> and <em>head</em> to use the default stablished image or the last created one respectively.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_massiveeditor_opencombo.png" alt="screenshot_vm_massiveeditor_opencombo.png" width="960px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
The vitual machines having assigned different OSFs. In this case a warning will be shown.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_massiveeditor_differentOSF.png" alt="screenshot_vm_massiveeditor_differentOSF.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>As we can not obtain a real list of tags for all the selected virtual machines, we can only choose between <em>default</em> and <em>head</em>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_massiveeditor_differentOSF_opencombo.png" alt="screenshot_vm_massiveeditor_differentOSF_opencombo.png" width="960px" />
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
Creation
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_create.png" alt="screenshot_vm_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When creating a virtual machine we will establish its <strong>name</strong>, the <strong>user</strong> that it belongs to (except if we create it from the user detail view) and the <strong>image</strong> it will use.</p></div>
<div class="paragraph"><p>We will select the image by choosing an OSF and the image tag wanted. When selecting the OSF, the tags of the images asociated to thar OSF will be charged in the following combo, where you can choose one of them as well as the special tags <em>default</em> and <em>head</em>, with which the default image or the last created image in the OSF respectively will be charged.</p></div>
<div class="paragraph"><p>OSF is the only datum that we will not be able to edit later in a virtual machine.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Detail view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_details.png" alt="screenshot_vm_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>We observe a small <strong>head top</strong> next to the <strong>name of the virtual machine</strong> where <strong>the buttom to delete it and the action buttoms</strong> are.</p></div>
<div class="paragraph"><p>The available buttoms in the detail view of the virtual machine are:
* Disconnecting the user from the virtual machine. This buttom will only be available if the user in connected.
* Spy the user session. This buttom will only be available if the virtual machine is running.
* Locking/Unlocking the virtual machine
* Editing the virtual machine</p></div>
<div class="paragraph"><p>Below this head top there is a <strong>table with the attributes of the virtual machine</strong> including the properties, if there were.</p></div>
<div class="paragraph"><p>On the right part we finde:</p></div>
</div></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Execution state of the virtual machine</strong>
</p>
</li>
</ul></div>
</dd>
</dl></div>
<div class="openblock">
<div class="content">
<div class="dlist"><dl>
<dt class="hdlist1">
Expiration dates
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>According or not to the definition of expiration or the state of the same, different things will be shown in the field <em>Expiration</em> of the attributes:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Without expiration</strong>: The machine that will not expire is the only that will be shown.
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
<strong>With expiration that is not over</strong>: Soft, hard or both expirations will be shown together with the time that is left for them to occur. When the expiration moment is approaching they will be shown in different colors (green, yellow or red).
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
<strong>With a hard expiration that is over</strong>: If the machine has definetively expired, it will be only shown that it has expired.
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
Execution status
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>On the right part of the detail view there is a <strong>chart with the execution state</strong> of the virtual machine. If the machine is running, we will be able to see the <strong>execution parameters</strong>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_details_execparams.png" alt="screenshot_vm_details_execparams.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>These parameters can change from one execution to another and they do not need to coincide with the current attributes of the machine.</p></div>
<div class="paragraph"><p><em>For exaple, in the snapshot, we observe that the default tag is set, so the machine is executing the image that the OSF has set as a default. If the default image of the OSF changes, we observe that in the attributes another disk image appears, but in the execution parameters the previous one still appears, since it is the one that is being executed.</em></p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_details_execparams_warning.png" alt="screenshot_vm_details_execparams_warning.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>In this case a warning will appear to make us realise that an execution parameter is different to the current ones, and if we want it to change we will have to restart the virtual machine.</p></div>
<div class="paragraph"><p>The chart with the execution state also has a control to start/stop the virtual machine.</p></div>
<div class="paragraph"><p>Depending on the moment, the virtual machine can go through 4 different states:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Running</strong>: A simple version will appear with a buttom to show the execution parameters. The buttom to stop the machine will be available
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/vm_execution_state_running.png" alt="vm_execution_state_running.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Stopped</strong>: When the machine is stopped, it will be shown like this and the buttom to start it will be available.
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
<strong>Starting</strong> When the virtual machine is starting an icon in movement will be shown. There will not be neccessary to refresh the page, and the status will change to <em>Running</em> when the proccess is over.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/vm_execution_state_starting.png" alt="vm_execution_state_starting.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
<strong>Stopping</strong>: When the virtual machine is stapping an icon in movement will be shown. There will not be neccessary to refresh the page, and the status will change to <em>Stopped</em> when the proccess is over.
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
Edition
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_edit.png" alt="screenshot_vm_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When editing the virtual machine we can change the <strong>name</strong>, the <strong>tag</strong> of the image, the <strong>expiration dates</strong> and <strong>edit properties</strong>.</p></div>
<div class="paragraph"><p>Two expiration dates can be configured:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Soft</strong>: it will only warn the user that the machine is going to expire. This warning is done through some scripts designed to them. See documents.
</p>
</li>
<li>
<p>
<strong>Hard</strong>: It will not let the user get connected to the virtual machine.
</p>
</li>
</ul></div>
<div class="paragraph"><p>To edit the dates of expiration a control of calendar exists.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_vm_edit_expiration.png" alt="screenshot_vm_edit_expiration.png" width="960px" />
</span></p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">We can also access to the edition of the element from the list view with the massive actions only if we select one element.</td>
</tr></table>
</div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_nodes">4.3. Nodes</h3>
<div class="paragraph"><p>In this section, QVD nodes are managed.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
List view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>The main view is a list with QVD nodes.
<span class="image">
<img src="images/doc_images/screenshot_host_list.png" alt="screenshot_host_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Information column
</dt>
<dd>
<p>
The information column will indicate us about:
</p>
<div class="ulist"><ul>
<li>
<p>
*Executing State*of the nodes.
</p>
<div class="openblock">
<div class="content">
<div class="ulist"><ul>
<li>
<p>
<strong>Stopped</strong>. Stop icon
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
<strong>Running</strong>. Play icon.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_running.png" alt="icon_running.png" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>The execution status of a node does not depend on the WAT. It can not be started nor stopped. The WAT only knows the IP address of the node and receives its state.</p></div>
</div></div>
<div class="ulist"><ul>
<li>
<p>
The *Locking Status*of the nodes:
</p>
</li>
</ul></div>
</li>
<li>
<p>
<strong>Locked</strong> Lock icon.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_locked.png" alt="icon_locked.png" />
</span></p></div>
<div class="paragraph"><p>In a blocked node, virtual machines will not run.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Unlocked</strong>. If the lock icon does not appear.
</p>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Massive actions
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_host_massiveactions.png" alt="screenshot_host_massiveactions.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Massive actions give us the following options to do on the selected nodes:</p></div>
<div class="ulist"><ul>
<li>
<p>
Lock nodes
</p>
</li>
<li>
<p>
Unlock nodes
</p>
</li>
<li>
<p>
Stop all the virtual machines running in the nodes
</p>
</li>
<li>
<p>
Delete nodes
</p>
</li>
<li>
<p>
Edit nodes: neither the name nor the IP address of the nodes will appear in the massive editor. To change the name and the IP address, it will be needed to do it one by one from the detail view.
</p>
</li>
</ul></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">If only one element is selected, in the case of the edition we can edit the same fields that with the normal edition of an element in the detail view.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Massive editor
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_host_massiveeditor.png" alt="screenshot_host_massiveeditor.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The massive editor of nodes only let us modify custom properties.</p></div>
<div class="paragraph"><p>As any other massive editor, the value which will be defined, it would rewrite the one that could exist in all the edited elements unless "No changes" option were selected.</p></div>
<div class="paragraph"><p>If custom properties do not exist in the nodes the massive edition will not be authorised.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Creation
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_host_create.png" alt="screenshot_host_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When creating a node we will establish its name, IP address and properties.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Detail view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_host_details.png" alt="screenshot_host_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>We observe a small <strong>head top</strong> next to the <strong>name of the node</strong> where <strong>the buttom to delete it and the action buttoms</strong> are.</p></div>
<div class="paragraph"><p>The available buttoms in the detail view of the user are:</p></div>
<div class="ulist"><ul>
<li>
<p>
Locking/Unlocking the node
</p>
</li>
<li>
<p>
Editing the node
</p>
</li>
</ul></div>
<div class="paragraph"><p>Below this head top there is a <strong>table with the attributes of the nodes</strong> including the properties, if there were.</p></div>
<div class="paragraph"><p>On the right part we find:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>The virtual machines running in the nodes</strong>
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>If we want more actions on them with the extended view buttom we go to the list of the virtual machines filtered by this node.</p></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Edition
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_host_edit.png" alt="screenshot_host_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When editing a node we will be able to edit its <strong>name, IP address or edit properties</strong>.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">We can also access to the edition of the element from the list view with the massive actions only if we select one element.</td>
</tr></table>
</div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_os_flavours">4.4. OS Flavours</h3>
<div class="paragraph"><p>In this part OSFs of QVD are managed, in which the images of the disc are grouped.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
List view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>The main view is a list with the OSFs of QVD.
<span class="image">
<img src="images/doc_images/screenshot_osf_list.png" alt="screenshot_osf_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Information column
</dt>
<dd>
<p>
In the OSFs there is not an information column, they are not lockable elements and they do not have any other interesting attribute for this column.
</p>
</dd>
<dt class="hdlist1">
Massive actions
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_osf_massiveactions.png" alt="screenshot_osf_massiveactions.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The massive actions give us the following options to do on the selected OSFs.</p></div>
<div class="ulist"><ul>
<li>
<p>
Delete OSFs
</p>
</li>
<li>
<p>
Edit OSFs: the name will not appear in the massive editor. To change it, it will be needed to do it one by one from the detail view.
</p>
</li>
</ul></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">If only one element is selected, in the case of the edition we can edit the same fields that with the normal edition of an element in the detail view.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Massive editor
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_osf_massiveeditor.png" alt="screenshot_osf_massiveeditor.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The massive editor of OSFs let us modify the memory, the user storage and the custom properties.</p></div>
<div class="paragraph"><p>*If we leave the memory box and the user storage in blank they will not be modified.</p></div>
<div class="paragraph"><p>As any other massive editor, the value which will be defined, it would rewrite the one that could exist in all the edited elements unless "No changes" option were selected.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Creation
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_osf_create.png" alt="screenshot_osf_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When creating an OSFs we will establish its name, memory, user storage and properties.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Detail view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_osf_details.png" alt="screenshot_osf_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>We observe a small <strong>head top</strong> next to the <strong>name of the OSFs</strong> where <strong>the buttoms to delete it and edit it</strong> are.</p></div>
<div class="paragraph"><p>Below this head top there is a <strong>table with the attributes of the OSF</strong> including the properties, if there were.</p></div>
<div class="paragraph"><p>On the right part, in this case, we find-</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>The images of this OSF</strong>.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>In this case, apart from seeing the names of the images and their information column, we will be able to <strong>change the defined image as the default image</strong> marking the square of the last column.</p></div>
<div class="paragraph"><p>Furthermore, as in the case of the virtual machines from the users view, we also have a <strong>buttom to create a disk image asociated to the current OSF</strong> where the same creation form of the disk images, except OSF, will appear to which the image will be asociated, that is implicit since it is created from here.</p></div>
</div></div>
</li>
<li>
<p>
<strong>The virtual machines</strong> that are using an image of this OSF, only as an information mode. If we want more actions over them with the extended view buttom we go to the list of the virtual machines filtered by this OSF.
</p>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Edition
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_osf_edit.png" alt="screenshot_osf_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When editing an OSF we will be able to edit its <strong>name, memory, user storage and edit properties</strong>.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">We can also access to the edition of the element from the list view with the massive actions only if we select one element.</td>
</tr></table>
</div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_disk_images">4.5. Disk images</h3>
<div class="paragraph"><p>In this section, QVD disk images are managed including versions and tags.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
List view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>The main view is a list with QVD disk images.
<span class="image">
<img src="images/doc_images/screenshot_di_list.png" alt="screenshot_di_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Information column
</dt>
<dd>
<p>
The information column will show:
</p>
<div class="ulist"><ul>
<li>
<p>
The images <strong>blocking status</strong>:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>Locked</strong>: Lock icon.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_locked.png" alt="icon_locked.png" />
</span></p></div>
<div class="paragraph"><p>An image which is locked cannot be used, so the virtual machines which use them could not be started.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Unlocked</strong>: If the lock icon is not shown.
</p>
</li>
</ul></div>
</li>
<li>
<p>
The <strong>tags</strong> combined with the images: if an image has some tags, it will show a tag icon when we go over it and it will show those tags.
</p>
</li>
</ul></div>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_tags.png" alt="icon_tags.png" />
</span></p></div>
<div class="paragraph"><p>If an image does not have tags, this icon will not show.</p></div>
</div></div>
<div class="ulist"><ul>
<li>
<p>
If an image is the <strong>OSF default image</strong>. Home icon
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_default.png" alt="icon_default.png" />
</span></p></div>
<div class="paragraph"><p>In some view we can find this feature as the special tag <em>default</em>.</p></div>
</div></div>
</li>
<li>
<p>
If an image is <strong>the last one created in its OSF</strong>. Flag icon.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_head.png" alt="icon_head.png" />
</span></p></div>
<div class="paragraph"><p>In some view we can find this feature as the special tag <em>head</em>.</p></div>
</div></div>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Massive actions
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_massiveactions.png" alt="screenshot_di_massiveactions.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Massive actions provide us with the following options to carry out on the selected disk images:</p></div>
<div class="ulist"><ul>
<li>
<p>
Lock images
</p>
</li>
<li>
<p>
Unlock images
</p>
</li>
<li>
<p>
Delete images
</p>
</li>
<li>
<p>
Edit images: Tags edition will not appear in the massive editor. In order to manage an image tags, we must do it one by one from the detail view.
</p>
</li>
</ul></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">If only one element is selected, in the case of the edition, we can edit the same fields that with the normal edition of an element in the detail view.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Massive editor
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_massiveeditor.png" alt="screenshot_di_massiveeditor.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The massive editor of disk images only allows us to modify custom properties.</p></div>
<div class="paragraph"><p>As any other massive editor, the value which will be defined, it would rewrite the one that could exist in all the edited elements unless "No changes" option were selected.</p></div>
<div class="paragraph"><p>If there are not custom properties in the disk images, the massive edition will not be enabled.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Creation
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>When we create an image we will choose the <strong>image file</strong>, <strong>the version</strong> (if we leave a blank, an automatic version will be set based on the date of creation)  and <strong>the OSF</strong> where we want to associate the image. Optionally, we can select it as the image <strong>by default</strong> for its OSF, add <strong>tags</strong> and create <strong>properties</strong>.</p></div>
<div class="paragraph"><p>The image file can be set up in three ways:</p></div>
<div class="ulist"><ul>
<li>
<p>
By selecting an image among the ones available in the <em>staging</em> directory in the server.
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
By uploading an image from our computer:
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
By providing an image URL which will be downloaded and hosted on the server:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_create_url.png" alt="screenshot_di_create_url.png" width="960px" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>Unlike the creation of the rest of the elements, disk images need more time as they are the physical copy of large files.</p></div>
<div class="paragraph"><p>Thus, when we create a disk image, an upload  screen will show with a creating progress chart.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_creating.png" alt="screenshot_di_creating.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Detail view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_details.png" alt="screenshot_di_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>We notice a small <strong>head top</strong> where next to the <strong>image name</strong> there are the <strong>button to delete it and the action buttons</strong>.</p></div>
<div class="paragraph"><p>The available buttons in the detail view are:</p></div>
<div class="ulist"><ul>
<li>
<p>
Establishing the image as the default one in its OSF. This button will only be available for the images which are not its OSF own default image.
</p>
</li>
<li>
<p>
Locking/unlocking image
</p>
</li>
<li>
<p>
Editing image
</p>
</li>
</ul></div>
<div class="paragraph"><p>Below this head top there is a  <strong>chart with image attributes</strong>, including the properties, in case there are some:</p></div>
<div class="paragraph"><p>Two fields in this table will be to point if it is the default image or the last one created by its OSF (<strong>default and head</strong>). These lines will only appear if these premises are fulfilled.</p></div>
<div class="paragraph"><p>On the right we can find:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>The virtual machines which use</strong> this image.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>If we want more actions on them, we will go to the list view of the virtual machines filtered by image with the extended view button.</p></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Edition
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_di_edit.png" alt="screenshot_di_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When we edit an image we will be able to manage its <strong>tags and edit properties</strong>. Moreover, we can establish it as its OSF default image, in case it is not so yet. If it already is, a warning will appear.</p></div>
<div class="paragraph"><p><strong>A disc Image tags can not be repeated in the same OSF</strong>. <strong>If we add a tag to a disc Image which already exists</strong> in other Image in the same OSF, the system will allow it, but what we will be doing, in fact, is to <strong>move the tag between the Images</strong>, it will disappear from the one it has it at the beginning, to establish itself in the Image we are editing.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">An element edition can also be accessed from the list view with the massive actions if we only select an element.</td>
</tr></table>
</div>
</div></div>
</dd>
<dt class="hdlist1">
Consequences of Image changes
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>Sometimes, a change in a disc Image can have <strong>consequences in the virtual Machines</strong> in several ways.</p></div>
<div class="paragraph"><p>This will happen in <strong>running</strong> virtual Machines which are linked to the <strong>same OSF</strong> as the modified disc Image.</p></div>
<div class="paragraph"><p>A virtual Machine has assigned a tag among the tags of the linked disk images, in other words, the OSF disk images linked to the Machine. This include special tags, <em>head</em> and <em>default</em>, which refer to the last disk image created and the default disk image respectively.</p></div>
<div class="paragraph"><p>Remember when we change a tag linked to a virtual Machine while it is running, we can get into a situation in which the linked disk image is different to the one we are using in the execution.</p></div>
<div class="paragraph"><p>It is possible to get to the same situation when the tag, linked to the virtual Machine which is running, change from one image to another. This can happen in different situations:</p></div>
<div class="ulist"><ul>
<li>
<p>
When the tag is assigned to other disk image of the same OSF and so deleting the Image used in the virtual Machine execution.
</p>
</li>
<li>
<p>
When the linked tag is <em>default</em> and a new disk image is established as the OSF default image.
</p>
</li>
<li>
<p>
When the linked tag is <em>head</em> and a new disc Image is created.
</p>
</li>
</ul></div>
<div class="paragraph"><p>When carrying out the action which sets off any of these situations, it can be assigned an expiration date for the virtual Machine or Machines affected. These actions are as follows:</p></div>
<div class="ulist"><ul>
<li>
<p>
Editing an Image by adding a tag which is in another, this being the one assigned to a running virtual Machine.
</p>
</li>
<li>
<p>
Establishing an image as the default one in its OSF, when there is already a virtual Machine assigned to the same OSF which has a <em>default</em> tag assigned
</p>
</li>
<li>
<p>
Creating an Image in a OSF when there is already a virtual machine assigned to the same OSF which has the <em>head</em> tag assigned
</p>
</li>
</ul></div>
<div class="paragraph"><p>After any of these actions, a modal window will appear to warn us about the situation of the virtual Machines affected alongside the checkboxes and a form to assign an expiration date to those Machines in the list we want to.</p></div>
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
<h2 id="_wat_management">5. WAT management</h2>
<div class="sectionbody">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_config_wat.png" alt="menu_config_wat.png" width="600px" />
</span></p></div>
<div class="paragraph"><p>One part of WAT is devoted to its own management. Giving tools for the management of  WAT general configuration, administrators and its permissions.</p></div>
<div class="sect2">
<h3 id="_wat_configuration">5.1. WAT Configuration</h3>
<div class="paragraph"><p>In this section we will define a series of general values that affect all the administrators of WAT. They are values that will be used as default settings, and that every administrator will set up according to his preferences.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_view.png" alt="screenshot_watconfig_view.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Find a table with the current values and on the right part the button of edition..</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Edition
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_edit.png" alt="screenshot_watconfig_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The parameters that can be configured are:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Language</strong>: It will be the WAT interface language which the administrators will have by default.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>For these parameters two types of values can be set up:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Fixed Language</strong>: English, Spanish&#8230;
</p>
</li>
<li>
<p>
<strong>Automatic Language</strong> (auto): It will be used the <strong>browser language</strong> with which the WAT is being used. If the browser language is not available in the WAT, <strong>English by default</strong> will be used.
</p>
</li>
</ul></div>
</div></div>
</li>
<li>
<p>
<strong>Block Size</strong>: It will be the number of items displayed in all the list views.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>If the number of items exceeds the block size, the list will be paginated with the block size as the maximum number of items per page.</p></div>
<div class="paragraph"><p>An exception to the block size is <strong>embedded lists</strong> in detail views, which will be <strong>fixed block size</strong> 5.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Tool of customization of styles</strong>: Activate or deactivate the tool of customization of styles of WAT.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>With this activated tool, a tab will appear on the left side of the screen. When clicking on it, a side menu will come out with the options of customization of styles. To gain a thorough understanding of this tool, review section <em>Tool of customization of styles</em> in the user guide.</p></div>
</div></div>
</li>
</ul></div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_administrators">5.2. Administrators</h3>
<div class="paragraph"><p>In this part the administrators of WAT will be managed as well as its permissions.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
List view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>The main view is a list with the administrators of WAT.
<span class="image">
<img src="images/doc_images/screenshot_administrator_list.png" alt="screenshot_administrator_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Information column
</dt>
<dd>
<p>
The information column will indicate us:
</p>
<div class="ulist"><ul>
<li>
<p>
The <strong>blocking status</strong> of the users:
</p>
<div class="ulist"><ul>
<li>
<p>
<strong>With roles</strong>. Mortarboard icon.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_montarboard.png" alt="icon_montarboard.png" />
</span></p></div>
<div class="paragraph"><p>I we go over with the mouse we can see the roles that the administrator has asociated.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Without roles</strong>: Warning icon.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_warning.png" alt="icon_warning.png" />
</span></p></div>
<div class="paragraph"><p>If the administrator does not have asociated roles, a warning icon will appear since an administrator without roles does not make sense.</p></div>
</div></div>
</li>
<li>
<p>
<strong>Logged administrator</strong>: Archiver icon.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/icon_archiver.png" alt="icon_archiver.png" />
</span></p></div>
<div class="paragraph"><p>If the administrator is the logged administrator, it will have this identifier with the warning <em>This administrator is me</em>.</p></div>
</div></div>
</li>
</ul></div>
</li>
</ul></div>
</dd>
<dt class="hdlist1">
Massive actions
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_administrator_massiveactions.png" alt="screenshot_administrator_massiveactions.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The massive actions give us the following options to do on the selected administrators:</p></div>
<div class="ulist"><ul>
<li>
<p>
Delete administrators
</p>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Creation
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_administrator_create.png" alt="screenshot_administrator_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When creating an administrator we will stablish its name, password and its language. If we leave the default language, the administrator will have the general language of the system although it can be changed.</p></div>
<div class="paragraph"><p>Besides, we can assign roles of privileges, depending on the permits we want that the administrator has. If we assign more than one role, the administrator will have the addition of the privileges of each role. If we do not assign any role, the administrator will not be able to enter in the Administration panel.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Detail view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_administrator_details.png" alt="screenshot_administrator_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>We observe a small <strong>head top</strong> next to the <strong>name of the administrator</strong> where <strong>the buttom to delete it and the action buttoms</strong> are.</p></div>
<div class="paragraph"><p>Below this head top there is a <strong>table with the attributes of the administrator</strong>. Among them we can find the roles asociated to the administrator with a control to delete next to each of them. By clicking in one the names of the roles, we will go to the detail view of each role.</p></div>
<div class="paragraph"><p>Under it, there is a panel with a selector to asigne any of the roles that are configurated in the system. This assignment gives the administrator the ACLs that the assigned roles have, no matter if they have common ACLs. In the ACLs tree we can see the ACLs computed of the assignation.</p></div>
<div class="paragraph"><p>On the right part we find_</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>The administrator&#8217;s ACLs tree</strong>. The branches appear closed at the beginning. By clicking on the icon next to each branch we can open them and see its contents.
</p>
</li>
</ul></div>
<div class="paragraph"><p>The tree has two clasification modes:</p></div>
<div class="ulist"><ul>
<li>
<p>
By <strong>sections</strong> of WAT:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>The ACLs are clasified by the section where they are used or the type of element that they affect to.</p></div>
<div class="paragraph"><p><em>For example, in the Configuration section the configuration part of WAT as well as the configuration of QVD are found.</em></p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_admin_treesections.png" alt="screenshot_admin_treesections.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
By type of <strong>image</strong>:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>In this clasification the same ACLs are found but clasified by the type of action that they let.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_admin_treeactions.png" alt="screenshot_admin_treeactions.png" width="600px" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>In both cases, the <strong>asociated ACLs will the only ones shown</strong> to the administrator through the assigned roles.</p></div>
<div class="paragraph"><p>Each ACL in the tree has a mortarboard icon that if we go over it with the mouse, it will indicate us the role or roles that it comes from. This is useful if we have asociated some roles to the adminitrator and we want to know the origin of the ACLs, since the roles can have ACLs in common.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Edition
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_administrator_edit.png" alt="screenshot_administrator_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When editing an administrator, we can choose if changing the <strong>password</strong> (if we do not click on the check-box, it will remain the same) and the <strong>language</strong>, remembering that they are values that the administrator itself can change.</p></div>
<div class="paragraph"><p>In addition, we can assign/unasign roles of privileges.</p></div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_roles">5.3. Roles</h3>
<div class="paragraph"><p>In this section the roles of WAT will be managed as well as its associated ACLs.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
List view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>The main view is a list with the roles of WAT.
<span class="image">
<img src="images/doc_images/screenshot_role_list.png" alt="screenshot_role_list.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Information column
</dt>
<dd>
<p>
In the roles there is no information column.
</p>
</dd>
<dt class="hdlist1">
Massive actions
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_massiveactions.png" alt="screenshot_role_massiveactions.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>Massive actions will give us the following options to be done on the selected roles:</p></div>
<div class="ulist"><ul>
<li>
<p>
Edit roles
</p>
</li>
<li>
<p>
Remove roles
</p>
</li>
</ul></div>
</div></div>
</dd>
<dt class="hdlist1">
Creation
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_create.png" alt="screenshot_role_create.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When creating a role we will set its name, description and will assign licenses inheriting ACLs.</p></div>
<div class="paragraph"><p>The inheritance of ACLs has got two modes:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Inherit ACLs from other roles</strong>: In this mode, it is chosen the role which you want to inherit with a roles selector. Once the role is inherited, it will disappear from this selector. Likewise if it is removed from the list of inherited roles, it will appear among the available inherited roles.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_inherit_roles.png" alt="screenshot_role_inherit_roles.png" width="600px" />
</span></p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Inherit ACLs from the templates</strong>: In this mode the templates are chosen from which you want to inherit the ACLs. Is possible select the templates from a selector like roles or use a matrix of buttons where the different templates are distributed according to the objects or level of privileges of each one. For example, the template with the update ACLs of a Node will be in the intersection of Nodes rows and the Up-to-date column.
</p>
</li>
</ul></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_inherit_templates.png" alt="screenshot_role_inherit_templates.png" width="600px" />
</span></p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_inherit_templates_matrix.png" alt="screenshot_role_inherit_templates_matrix.png" width="600px" />
</span></p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/tip.png" alt="Tip" />
</td>
<td class="content">If it is inherited from one or more roles/templates, it will be inherited the sum of its ACLs regardless the common ACLs.  After this inheritance, you can remove or add single ACLs manually from the Tree of ACLs to customize the references obtained by them according to the needs of the administrator. In this way, if we are interested in all the ACLs of a role or template except one, it will be as easy as inheriting the role/template and remove manually the remaining ACL.</td>
</tr></table>
</div>
<div class="paragraph"><p>For a more specific customization we will can add or remove ACLs from details view.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Detail view
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_details.png" alt="screenshot_role_details.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>In this view which is very similar to that of administrators, we can see a small <strong>header</strong> where next to the <strong>role name</strong> is <strong>button to delete it, and the button of edition</strong>.</p></div>
<div class="paragraph"><p>Under this header there is a <strong>table with role attributes</strong>. Among the attributes we can find the list of <strong>inheritance roles and templates</strong>.</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>Role</strong>:  It is a role from the ones defined in the system. The name of this role will be the link to its detail view.
</p>
</li>
<li>
<p>
<strong>Template</strong>: It is a set of predefined ACLs to <strong>help build roles</strong>. There are templates for the different levels of access in the QVD elements.
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>For example:</p></div>
<div class="ulist"><ul>
<li>
<p>
Access read-only in Users
</p>
</li>
<li>
<p>
Access operation in Disk Images (operations are the actions such as block/unblock, disconnect users, start a virtual machine&#8230;)
</p>
</li>
<li>
<p>
Access update in Virtual machines
</p>
</li>
<li>
<p>
Access Users removal
</p>
</li>
<li>
<p>
&#8230;
</p>
</li>
</ul></div>
<div class="paragraph"><p>Other templates are the composition of different levels of access:</p></div>
<div class="ulist"><ul>
<li>
<p>
Management: Include Read, Operation, Creation, Update, Deletion
</p>
</li>
<li>
<p>
QVD templates: QVD templates cover the templates of the same level of access of Users, Virtual Machines, OSFs and images. For example: QVD Updater.
</p>
</li>
<li>
<p>
WAT templates: WAT templates cover the templates of the same level of access of Administrators, Roles and Views.
</p>
</li>
<li>
<p>
Master: This template covers the templates of Management of WAT and Management of QVD.
</p>
</li>
<li>
<p>
Total Master: This template covers the Master template, Management of Tenants and Management of Nodes.
</p>
</li>
</ul></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>On the right side we find:</p></div>
<div class="ulist"><ul>
<li>
<p>
<strong>The Tree of ACLs</strong>. The branches are initially closed. By clicking on the icon next to every branch we will be able to open it and to see its content. Unlike ACLs tree of the detail view of administrators, <strong>in the roles the tree contains all the ACLs of the system</strong>, and appear as active the ones which have the role associated.
</p>
</li>
</ul></div>
<div class="paragraph"><p>The tree has, in the same way that in the tree of the detail view of administrators, two modes of classification:</p></div>
<div class="ulist"><ul>
<li>
<p>
By <strong>sections</strong> of WAT:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>The ACLs are classified according to the section where they are applied or the type or element they affect.</p></div>
<div class="paragraph"><p>The main ACL of every section, and necessary to have this section at least available in the menu, next to its main view is "Access to the main view of&#8230;", except in the sections of setting which are ruled by a single ACL "Management of setting WAT/QVD".</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_treesections.png" alt="screenshot_role_treesections.png" width="600px" />
</span></p></div>
</div></div>
</li>
<li>
<p>
By types of <strong>actions</strong>:
</p>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>In this classification there are the same ACLs, but classified according to the type of action they permit.
<em> For example in the branch "See main section " we can set up what sections to see. </em></p></div>
<div class="paragraph"><p>If we want to apply certain permissions of a type (Delete, update, etc.) to several types of elements, this classification simplifies ACLs management.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_treeactions.png" alt="screenshot_role_treeactions.png" width="600px" />
</span></p></div>
</div></div>
</li>
</ul></div>
<div class="paragraph"><p>Each branch has a checkbox. If it is activated, it means that all the ACLs of the branch are assigned, either directly or by inheritance of one o more roles or templates.</p></div>
<div class="paragraph"><p>*If we activate the box of a branch *, we will include in the role all the ACLs of this branch. In the same way, *if we deactivate the box of a branch *, we will be removing its ACLs.</p></div>
<div class="paragraph"><p>The branches, have also attached, between brackets, information of the ACLs included in the role as opposed to the total ACLs in the branch.</p></div>
<div class="paragraph"><p>When opening a branch, we can see that <strong>each ACL has a checkbox</strong> with which it can be associated or disassociated from the role.</p></div>
<div class="paragraph"><p>Some ACLs have an icono birrete, which indicates that this ACL comes from an inherited role. Going over it with the mouse, it will indicate us the role or roles from which it comes.</p></div>
<div class="paragraph"><p>Thus, some ACLs inherited through a role can be deactivated using the checkbox and others that are not inherited can be added to the role.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Edition
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_role_edit.png" alt="screenshot_role_edit.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When editing a role we will be able to change name and description, in addition to configure the roles and ACL templates inheritance.</p></div>
<div class="paragraph"><p>See Roles creation section for more details about roles and templates configuration.</p></div>
</div></div>
</dd>
</dl></div>
</div>
<div class="sect2">
<h3 id="_default_views">5.4. Default views</h3>
<div class="paragraph"><p>As we have seen in the analysis of every section, the list view displays several columns with different data of the existing elements as well as some filter controls.</p></div>
<div class="paragraph"><p>These columns and filters can be set up globally in the system, and then each administrator will be able to customize these values only for himself.</p></div>
<div class="paragraph"><p>With a selection combo we can change between columns and filters.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_defaultviews_columns.png" alt="screenshot_watconfig_defaultviews_columns.png" width="960px" />
</span></p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_defaultviews_filters.png" alt="screenshot_watconfig_defaultviews_filters.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>In this section the general configuration of these parameters will be done by ticking a series of checkboxes. In the first place, the displayed columns are set up and secondly the available filters.</p></div>
<div class="paragraph"><p>With respect to the <strong>columns</strong> it is a valid configuration for the <strong>desktop version</strong>, since in the mobile version will always display a simplified version. On the other hand, the <strong>filters</strong> will be set up regardless if it is for <strong>desktop and mobile</strong>. This distinction is made in order to do the mobile version more or less simple according to our needs.</p></div>
<div class="paragraph"><p>After an information notice we will see a drop-down menu with the section that we want to customize and a button to restore the views by default.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_defaultviews_sections.png" alt="screenshot_watconfig_defaultviews_sections.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>As we select one or another section, the columns and filters of the above mentioned section will be added. Only by clicking on the different checkboxes the change will be saved.</p></div>
<div class="paragraph"><p>If we want to <strong>return to initial configuration</strong> we will use the button of <strong>restore views by default</strong>. This action can be done on the loaded section or on the whole system, choosing one or another option in the dialogue that appears before carrying out the restoration.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_defaultviews_reset.png" alt="screenshot_watconfig_defaultviews_reset.png" width="960px" />
</span></p></div>
</div>
<div class="sect2">
<h3 id="_properties">5.5. Properties</h3>
<div class="literalblock">
<div class="content">
<pre><code>In this section we will manage the custom properties of every QVD element. In this way, we will be able to create extras properties for the elements that support this functionality: Users, Virtual Machines, Nodes, OSFs and Disk Images.</code></pre>
</div></div>
<div class="paragraph"><p>A custom property in the Users, for example, will appear in all the users of the system as one more field. Not only in its detail view, but also in its forms of creation and edition. It might also appear in the list view as a column and/or specific filter if it was set up from the section of <em>Views</em>.</p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Control of ACLs in block
</dt>
<dd>
<p>
Both the management and the visualization on the part of other administrators of the custom properties can be regulated by ACLs, but it will be done ' in block '. This means that the properties of a certain type of element can be displayed or not displayed (for example disk images) but it cannot be displayed some and hidden others.
</p>
</dd>
<dt class="hdlist1">
Contextual Help
</dt>
<dd>
<p>
Every property has an assigned description that will be in used as a contextual help in the places where the property appears, which might clarify possible doubts on its purpose or possible values.
</p>
</dd>
<dt class="hdlist1">
Interface
</dt>
<dd>
<p>
It might be common to establish the same property in different types of QVD elements, that is why the editor is displayed in matrix form, in which, in a single view the different properties of the system can be seen and put them or to remove them of certain QVD elements.
</p>
</dd>
</dl></div>
<div class="paragraph"><p>To facilitate the edition in environments with a lot of custom properties there is an available filter to show only the properties of a certain type of element (For example OSFs). This filter, by default, has the option "All" selected to give a global view of the properties.</p></div>
<div class="paragraph"><p>In order to create a new property we will click on the button "New property" and we will establish the name, the (optional) description and the types of elements where it will appear.</p></div>
<div class="paragraph"><p>In order to edit the name or the description of the properties we will click on the button of edition next to the name of the property. However, in order to manage in which type of elements an already created property will appear, we will do it with the checkboxes of the matrix as it appears in the main interface.</p></div>
<div class="paragraph"><p>Take into account that if we have the properties filtered by a type of element (For example nodes), and we deactivate the checkbox that enables the above mentioned property in the nodes, it will disappear from the view, but changing the filter again to <em>All</em> we will be able to manage it again.</p></div>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_qvd_management">6. QVD Management</h2>
<div class="sectionbody">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_config_qvd.png" alt="menu_config_qvd.png" width="600px" />
</span></p></div>
<div class="sect2">
<h3 id="_qvd_configuration">6.1. QVD configuration</h3>
<div class="paragraph"><p>The parameters of QVD are distributed in several configuration files and the database. From WAT these parameters are shown in a centrally way, where they can be edited easily regardless its backgrounds.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_config.png" alt="screenshot_config.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The parameters are clasified in categories. These categories correspond with the first segment of the name of the parameter, it means inmediately preceding the first stop.</p></div>
<div class="paragraph"><p><em>For example, the parameters that start with "admin" will be included in the "admin" category, as we can see in the snapshot.</em></p></div>
<div class="dlist"><dl>
<dt class="hdlist1">
Navigation and research
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>It is possible to navigate through the different categories to edit its parameters or to use the <strong>search control</strong> to find the parameters that contain a <strong>substring</strong>.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_config_search.png" alt="screenshot_config_search.png" width="960px" />
</span></p></div>
</div></div>
</dd>
<dt class="hdlist1">
Parameters creation
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>It is possible to add <strong>new parameters</strong>, that will be situated in the category that corresponds depending on the beginning of its name.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_config_custom.png" alt="screenshot_config_custom.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>If the category does not exist it will be created in the menu, and if the name of the parameter do not contain stops it will take part of the special category <em>unclassified</em>.</p></div>
</div></div>
</dd>
<dt class="hdlist1">
Deleting and restoring parameters
</dt>
<dd>
<div class="openblock">
<div class="content">
<div class="paragraph"><p>The parameters added after the installation can be deleted.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_config_delete.png" alt="screenshot_config_delete.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>And the ones that were standard will be able to be restored to the default value.</p></div>
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
<h2 id="_user_area">7. User Area</h2>
<div class="sectionbody">
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/menu_userarea.png" alt="menu_userarea.png" width="600px" />
</span></p></div>
<div class="sect2">
<h3 id="_profile">7.1. Profile</h3>
<div class="paragraph"><p>This is the part where we can check and update the set-up of the logged administrator.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_userarea_profile.png" alt="screenshot_userarea_profile.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>The  WAT interface language can be set up as well as the block size, the one which corresponds to the number of elements shown in each page in the list views.
Both parameters can be defined as <em>by default</em> thus adopting the WAT general set-up, or a fix value for the current administrator.</p></div>
<div class="paragraph"><p>In addition, from this section is possible to access to the views configuration of the logged administrator in the section <strong>My views</strong>.</p></div>
<div class="sect3">
<h4 id="_my_views">7.1.1. My views</h4>
<div class="paragraph"><p>As we saw in the part of the management of WAT, we can customize which columns or filters are shown in the different views of WAT. That is a global configuration of the system.</p></div>
<div class="paragraph"><p>On the basis of this configuration, each administrator can customize his or her views in a very similar way, adapting them to his or her preferences.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/important.png" alt="Important" />
</td>
<td class="content">If an administrator does not change the configuration of his or her views, these could vary if the global configuration were modified. On the other hand, if an administrator changes a parameter, it will be fixed in the stablished value, without being altered by the changes in the global configuration.</td>
</tr></table>
</div>
<div class="paragraph"><p>With a selection combo we can change between columns and filters.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_userarea_customize_columns.png" alt="screenshot_userarea_customize_columns.png" width="960px" />
</span></p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_userarea_customize_filters.png" alt="screenshot_userarea_customize_filters.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>In this part it will be done a configuration for the current administrator of these parameters by ticking a series of check-boxes. On the one hand the shown columns are configured and on the other hand the available filters.</p></div>
<div class="paragraph"><p>In the case of the <strong>columns</strong>, it is a valid configuration for the <strong>desktop version</strong> since in the mobile version, the version will always be simplified. On the other hand the <strong>filters</strong> are configured independently for the <strong>desktop and mobile</strong> This difference is made in order to do the mobile version more or less simple according to our neccesities.</p></div>
<div class="paragraph"><p>In the section we will find a drop down menu with the section that we want to customize and a buttom to restore the default views.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_defaultviews_sections.png" alt="screenshot_watconfig_defaultviews_sections.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When we select one or another section, the columns and filters of that section will be charged. Only by clicking on the different check-boxes, the change will be saved.</p></div>
<div class="paragraph"><p>If we want to <strong>revert to the system configuration</strong> we will use the buttom to <strong>restore the default views</strong>. This action can be done over the current loaded section or over all the system, choosing one or the other option in the dialogue that appears before doing the restoration.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/important.png" alt="Important" />
</td>
<td class="content">The views that we reset to the system configuration will be again subject to the changes that the global configuration may suffer.</td>
</tr></table>
</div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_userarea_customize_reset.png" alt="screenshot_userarea_customize_reset.png" width="960px" />
</span>
 d</p></div>
</div>
</div>
<div class="sect2">
<h3 id="_customize_views">7.2. Customize Views</h3>
<div class="paragraph"><p>As we saw in the part of the management of WAT, we can customize which columns or filters are shown in the different views of WAT. That is a global configuration of the system.</p></div>
<div class="paragraph"><p>On the basis of this configuration, each administrator can customize his or her views in a very similar way, adapting them to his or her preferences.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/important.png" alt="Important" />
</td>
<td class="content">If an administrator does not change the configuration of his or her views, these could vary if the global configuration were modified. On the other hand, if an administrator changes a parameter, it will be fixed in the stablished value, without being altered by the changes in the global configuration.</td>
</tr></table>
</div>
<div class="paragraph"><p>With a selection combo we can change between columns and filters.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_userarea_customize_columns.png" alt="screenshot_userarea_customize_columns.png" width="960px" />
</span></p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_userarea_customize_filters.png" alt="screenshot_userarea_customize_filters.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>In this part it will be done a configuration for the current administrator of these parameters by ticking a series of check-boxes. On the one hand the shown columns are configured and on the other hand the available filters.</p></div>
<div class="paragraph"><p>In the case of the <strong>columns</strong>, it is a valid configuration for the <strong>desktop version</strong> since in the mobile version, the version will always be simplified. On the other hand the <strong>filters</strong> are configured independently for the <strong>desktop and mobile</strong> This difference is made in order to do the mobile version more or less simple according to our neccesities.</p></div>
<div class="paragraph"><p>In the section we will find a drop down menu with the section that we want to customize and a buttom to restore the default views.</p></div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_watconfig_defaultviews_sections.png" alt="screenshot_watconfig_defaultviews_sections.png" width="960px" />
</span></p></div>
<div class="paragraph"><p>When we select one or another section, the columns and filters of that section will be charged. Only by clicking on the different check-boxes, the change will be saved.</p></div>
<div class="paragraph"><p>If we want to <strong>revert to the system configuration</strong> we will use the buttom to <strong>restore the default views</strong>. This action can be done over the current loaded section or over all the system, choosing one or the other option in the dialogue that appears before doing the restoration.</p></div>
<div class="admonitionblock">
<table><tr>
<td class="icon">
<img src="images/doc_images/icons/important.png" alt="Important" />
</td>
<td class="content">The views that we reset to the system configuration will be again subject to the changes that the global configuration may suffer.</td>
</tr></table>
</div>
<div class="paragraph"><p><span class="image">
<img src="images/doc_images/screenshot_userarea_customize_reset.png" alt="screenshot_userarea_customize_reset.png" width="960px" />
</span>
 d</p></div>
</div>
<div class="sect2">
<h3 id="_log_out_session">7.3. Log out session</h3>
<div class="paragraph"><p>With this option the current administrator is logged out and it appears the login.</p></div>
</div>
</div>
</div>
</div>
<div id="footnotes"><hr /></div>
<div id="footer">
<div id="footer-text">
Last updated 2016-12-14 08:21:47 CET
</div>
</div>
</body>
</html>
