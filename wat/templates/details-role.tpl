<%
    var totalAddedACLs = Object.keys(model.get('acls').positive).length;
    var totalFilteredACLs = Object.keys(model.get('acls').negative).length;
    var totalInheritedACLs = model.get('number_of_acls');
%>

<div class="details-header">
    <span class="fa fa-graduation-cap h1" data-i18n><%= model.get('name') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
</div>

<table class="details details-list col-width-100">
    <tr>
        <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
</table>

<div class="menu submenu desktop" style="visibility: visible;">
    <ul>
        <li class="menu-option js-submenu-option" data-show-submenu="acls-management-acls">
            <i class="fa fa-key"></i>
            <span data-i18n="">ACLs</span>
        </li>
        <li class="menu-option js-submenu-option" data-show-submenu="acls-management-inherit-roles">
            <i class="fa fa-sitemap"></i>
            <span class="selected-option" data-i18n="">Inherited roles</span>
        </li>
        <!--
        <li class="menu-option js-submenu-option" data-show-submenu="acls-management-acls">
            <i class="fa fa-ban"></i>
            <span data-i18n="">Excluded ACLs</span>
        </li>
        -->
    </ul>
</div>

<div class="bb-role-inherited-roles"></div>
<div class="bb-role-acls"></div>
<div class="bb-role-excluded-acls"></div>