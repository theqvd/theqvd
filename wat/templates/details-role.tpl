<div class="details-header">
    <span class="<%= CLASS_ICON_ROLES %> h1"><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('role.delete.') && !model.get('fixed2')) { %>
    <a class="button fleft button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"></a>
    <% } %>
    <% if(Wat.C.checkGroupACL('roleEdit') && !model.get('fixed2')) { %>
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