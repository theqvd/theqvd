<table>
    <tr>
        <td data-i18n="Change password"></td>
        <td>
            <input type="checkbox" class="js-change-password" name="change_password" value="1">
        </td>
    </tr>
    <tr class="hidden new_password_row">
        <td data-i18n="New password"></td>
        <td>
            <input type="password" name="password" value="" data-required data-equal="password">
        </td>
    </tr>
    <tr class="hidden new_password_row">
        <td data-i18n="Re-type new password"></td>
        <td>
            <input type="password" name="password2" value="" data-required data-equal="password">
        </td>
    </tr>
    <tr>
        <td data-i18n>Assigned roles</td>
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