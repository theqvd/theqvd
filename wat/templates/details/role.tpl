<div class="details-header">
    <span class="<%= CLASS_ICON_ROLES %> h1"><%= model.get('name') %></span>
    <div class="clear mobile"></div>
    <a class="button2 fright fa fa-eye js-show-details-actions show-details-actions" data-options-state="hidden" data-i18n="Actions"></a>
    
    <% if(Wat.C.checkACL('role.delete.') && (!model.get('fixed') || !RESTRICT_TEMPLATES)) { %>
    <a class="button fleft button-icon--desktop js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"><span data-i18n="Delete" class="mobile"></span></a>
    <% } %>
    <% if(Wat.C.checkGroupACL('roleEdit') && (!model.get('fixed') || !RESTRICT_TEMPLATES)) { %>
    <a class="button fright button-icon--desktop js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"><span data-i18n="Edit" class="mobile"></span></a>
    <% } %>
    
    <div class="clear mobile"></div>
</div>

<table class="details details-list col-width-100">
    <%   
    if (Wat.C.isSuperadmin()) { 
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_TENANTS %>"></i><span data-i18n="Tenant"></span></td>
            <td>
                <%= Wat.C.ifACL('<a href="#/tenant/' + model.get('tenant_id') + '">', 'tenant.see-details.') %>
                <%= model.get('tenant_name') %>
                <%= Wat.C.ifACL('</a>', 'tenant.see-details.') %>
            </td>
        </tr>
    <%   
    }
    if (Wat.C.checkACL('role.see.id')) { 
    %>
    <tr>
        <td><i class="fa fa-asterisk"></i><span data-i18n="Id"></span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <% 
    }
    if (Wat.C.checkACL('role.see.description')) { 
    %>
        <tr>
            <td><i class="fa fa-align-justify"></i><span data-i18n="Description"></span></td>
            <td>
                <% 
                if (model.get('description')) { 
                %>
                    <%= model.get('description').replace(/\n/g, '<br>') %>
                <%
                }
                else {
                %>
                    <span class="second_row">-</span>
                <%
                }
                %>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('role.see.inherited-roles')) {
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_ROLES %>"></i><span data-i18n="Inherited roles"></span></td>
            <td>
                <div class="bb-role-inherited-list"></div>
            </td>
        </tr>
        <tr>
            <td colspan=2  class="tools-roles js-tools-roles">
                <div class="bb-role-inherited-tools-roles role-inherited-tools-roles"></div>
            </td>
        </tr>
        <tr>
            <td><i class="<%= CLASS_ICON_TEMPLATES %>"></i><span data-i18n="Inherited templates"></span></td>
            <td>
                <div class="bb-template-inherited-list template-inherited-list"></div>
            </td>
        </tr>
        <tr>
            <td colspan=2 class="tools-templates js-tools-templates">
                <div class="bb-role-inherited-tools-templates role-inherited-tools-templates"></div>
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

<div class="bb-role-inherited-roles role-inherited-roles"></div>

<% 
if (Wat.C.checkACL('role.see.acl-list')) { 
%>
    <div class="bb-role-acls-tree role-acls-tree"></div>
<% 
} 
%>