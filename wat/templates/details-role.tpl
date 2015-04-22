<div class="details-header">
    <span class="<%= CLASS_ICON_ROLES %> h1"><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('role.delete.') && (!model.get('fixed') || !RESTRICT_INTERNAL_ROLES)) { %>
    <a class="button fleft button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"></a>
    <% } %>
    <% if(Wat.C.checkGroupACL('roleEdit') && (!model.get('fixed') || !RESTRICT_INTERNAL_ROLES)) { %>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"></a>
    <% } %>
</div>

<% 
if (Wat.C.checkACL('role.see.id')) { 
%>
    <table class="details details-list col-width-100">
        <% 
        if (Wat.C.checkACL('role.see.id')) { 
        %>
        <tr>
            <td><i class="fa fa-male"></i><span data-i18n="Id"></span></td>
            <td>
                <%= model.get('id') %>
            </td>
        </tr>
        <% 
        }
        if (Wat.C.checkACL('role.see.created-by')) {
        %>
            <tr>
                <td><i class="<%= CLASS_ICON_ADMINS %>"></i><span data-i18n="Created by"></span></td>
                <td>
                    <span><%= model.get('creation_admin_name') %></span>
                </td>
            </tr>
        <% 
        }
        if (Wat.C.checkACL('role.see.creation-date')) {
        %>
            <tr>
                <td><i class="fa fa-clock-o"></i><span data-i18n="Creation date"></span></td>
                <td>
                    <span><%= model.get('creation_date') %></span>
                </td>
            </tr>
        <% 
        }
        %>
    </table>
<% 
} 
%>


<div class="bb-role-inherited-roles role-inherited-roles"></div>

<% 
if (Wat.C.checkACL('role.see.acl-list')) { 
%>
    <div class="bb-role-acls-tree role-acls-tree"></div>
<% 
} 
%>