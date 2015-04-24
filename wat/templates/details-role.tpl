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
        if (Wat.C.checkACL('role.see.inherited-roles')) {
        %>
            <tr>
                <td><i class="<%= CLASS_ICON_ROLES %>"></i><span data-i18n="Inherited roles"></span></td>
                <td>
                    <table class="roles-inherit-table">
                        <tr>
                            <td>
                                <%
                                    var classFixed = '';
                                    if (model.get('fixed') && RESTRICT_INTERNAL_ROLES) {
                                        classFixed = 'invisible';
                                    }

                                    $.each(model.get('roles'), function (iRole, role) {
                                %>
                                    <div>
                                        <%
                                            if (Wat.C.checkACL('role.update.assign-role')) {
                                        %>
                                                <i class="delete-role-button js-delete-role-button fa fa-trash-o <%= classFixed %>" data-id="<%= iRole %>" data-name="<%= role.name %>"></i>
                                        <%
                                            }

                                        if (role.internal && RESTRICT_INTERNAL_ROLES) {
                                        %>
                                            <span class="text"><%= role.name %></span>
                                        <%
                                        }
                                        else {
                                        %>
                                            <%= Wat.C.ifACL('<a href="#/role/' + iRole + '">', 'role.see-details.') %>
                                            <span class="text"><%= role.name %></span>
                                            <%= Wat.C.ifACL('</a>', 'role.see-details.') %>
                                        <%
                                        }
                                        %>
                                    </div>
                                <%
                                    }); 
                                %>  
                                <%
                                    if (Object.keys(model.get('roles')).length == 0) {
                                %>
                                        <span data-i18n="No elements found"></span>
                                <%
                                    }
                                %>
                            </td>
                        </tr>
                    </table>
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