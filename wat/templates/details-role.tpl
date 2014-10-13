<div class="details-header">
    <span class="fa fa-graduation-cap h1" data-i18n><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('role_delete')) { %>
    <a class="button fleft button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"></a>
    <% } %>
    <% if(Wat.C.checkACL('role_update')) { %>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"></a>
    <% } %>
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

<div class="bb-role-inherited-roles role-inherited-roles"></div>
<div class="bb-role-acls role-acls"></div>
