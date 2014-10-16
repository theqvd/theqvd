<table class="list details-list acls-management acls-management-inherit-roles col-width-100">   
    <tr>
        <th colspan="5">
            <span data-i18n>
                Assigned roles
            </span>
        </th>
    </tr>
    <tr>
        <td colspan="2">
            <table class="roles-inherit-table">
                <tr>
                    <td>
                        <span data-i18n>Select a role to be assigned</span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <select name="role"></select>
                        <a class="button add-role-button js-add-role-button fa fa-graduation-cap" href="javascript:" data-i18n>Assign</a>
                    </td>
                </tr>
                <tr>
                    <td>
                        <%
                            $.each(model.get('roles'), function (iRole, role) {
                        %>
                            <div>
                                <%
                                    if (Wat.C.checkACL('role.update.assign-role')) {
                                %>
                                        <i class="delete-role-button js-delete-role-button fa fa-trash-o" data-id="<%= iRole %>" data-name="<%= role %>"></i>
                                <%
                                    }
                                %>
                                
                                <%= Wat.C.ifACL('<a href="#/setup/role/' + iRole + '">', 'role.see-details.') %>
                                <span class="text"><%= role %></span>
                                <%= Wat.C.ifACL('</a>', 'role.see-details.') %>
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
            </table>
        </td>
    </tr>
</table>