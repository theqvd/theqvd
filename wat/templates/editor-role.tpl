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
            <table class="manage-roles">
                <tr>
                    <td>
                        <i class="add-acl-button js-add-acl-button fa fa-plus-circle"></i>
                        <select name="role_acls"></select>
                    </td>
                </tr>
        <%
            $.each(model.get('own_acls').positive, function (iAcl, acl) {
        %>
                <tr>
                    <td>            
                        <i class="delete-acl-button js-delete-acl-button fa fa-trash-o" data-id="<%= acl %>" data-name="<%= acl %>"></i>
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
                        <i class="add-inherit-role-button js-add-inherit-role-button fa fa-plus-circle"></i>
                        <select name="inherit_role"></select>
                    </td>
                </tr>
        <%
            $.each(model.get('inherited_roles'), function (iRole, role) {
        %>
                <tr>
                    <td>            
                        <i class="delete-inherit-role-button js-delete-inherit-role-button fa fa-trash-o" data-id="<%= iRole %>" data-name="<%= role.name %>"></i>
                        <%= role.name %>
                    </td>
                </tr>
        <%
            });
        %>
            </table>
        </td>
    </tr>

 </table>