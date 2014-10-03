<table>
    <tr>
        <td data-i18n>Name</td>
        <td>
            <input type="text" class="" name="name" value="<%= model.get('name') %>" data-required>
        </td>
    </tr>
    <tr>
        <td data-i18n>ACLs</td>
        <td>
            <table class="manage-acls">
                <tr>
                    <td>
                        <i class="add-acl-button js-add-acl-button fa fa-plus-circle"></i>
                        <select name="role_acls"></select>
                    </td>
                </tr>
        <%
            $.each(model.get('acls'), function (iAcl, acl) {
        %>
                <tr>
                    <td>            
                        <i class="delete-acl-button js-delete-acl-button fa fa-trash-o" data-id="<%= iAcl %>" data-name="<%= acl %>"></i>
                        <%= acl %>
                    </td>
                </tr>
        <%
            });
        %>
            </table>
        </td>
    </tr>
    <tr>
        <td data-i18n>Inherited roles</td>
        <td>
            <table class="manage-roles">
                <tr>
                    <td>
                        <i class="add-role-button js-add-role-button fa fa-plus-circle"></i>
                        <select name="role"></select>
                    </td>
                </tr>
        <%
            $.each(model.get('roles'), function (iRole, role) {
        %>
                <tr>
                    <td>            
                        <i class="delete-role-button js-delete-role-button fa fa-trash-o" data-id="<%= iRole %>" data-name="<%= role %>"></i>
                        <%= role %>
                    </td>
                </tr>
        <%
            });
        %>
            </table>
        </td>
    </tr>

 </table>