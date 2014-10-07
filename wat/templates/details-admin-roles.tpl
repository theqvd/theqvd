<table class="list details-list acls-management acls-management-inherit-roles col-width-100">   
    <tr>
        <th colspan="5">
            <span data-i18n>
                Assign roles
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
                <%
                    if (Object.keys(model.get('roles')).length > 0) {
                %>
                <tr>
                    <td>
                        <i class="fa fa-graduation-cap"></i><span data-i18n>Assigned roles</span>
                    </td>
                </tr>
                <%
                    }
                %>
                <tr>
                    <td>
                        <%
                            $.each(model.get('roles'), function (iRole, role) {
                        %>
                            <div>
                                <i class="delete-role-button js-delete-role-button fa fa-trash-o" data-id="<%= iRole %>" data-name="<%= role %>"></i>
                                <span class="text"><%= role %></span> 
                            </div>
                        <%
                            }); 
                        %>  
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>