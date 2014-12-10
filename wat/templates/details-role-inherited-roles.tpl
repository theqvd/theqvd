<table class="list details-list acls-management acls-management-inherit-roles col-width-100">   
    <tr>
        <th colspan="5">
            <span data-i18n>
                Inherited roles
            </span>
        </th>
    </tr>
    <tr>
        <td colspan="2">
            <table class="roles-inherit-table">
                <tr>
                    <td>
                        <%
                            var classFixed = '';
                            if (model.get('fixed')) {
                                classFixed = 'invisible';
                            }
                            $.each(model.get('roles'), function (iRole, role) {
                        %>
                            <div>
                                <%
                                    if (Wat.C.checkACL('role.update.assign-role')) {
                                %>
                                        <i class="delete-role-button js-delete-role-button fa fa-trash-o <%= classFixed %>" data-id="<%= iRole %>" data-name="<%= role %>"></i>
                                <%
                                    }
                                
                                if (role.internal) {
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
                                <span data-i18n>No elements found</span>
                        <%
                            }
                        %>
                    </td>
                </tr>
                
                <% if(Wat.C.checkACL('role.update.assign-role') && !model.get('fixed')) { %>
                <tr>
                    <td>
                        <select name="role"></select>
                    </td>                    
                    <td class="col-width-1">
                        <a class="button add-role-button js-add-role-button fa fa-sitemap" href="javascript:" data-i18n>Inherit</a>
                    </td>
                </tr>
                <% } %>
            </table>
        </td>
    </tr>
</table>