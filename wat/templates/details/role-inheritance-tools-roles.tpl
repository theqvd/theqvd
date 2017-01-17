<fieldset class="template-inherited-list">
    <table class="col-width-100">
        <tbody>
            <%
                var inheritedRoles = 0;
                $.each(roles, function (iRole, role) {
                    if (!role.inherited) {
                        return;
                    }
                    
                    inheritedRoles++;
                    %>
                        <tr>
                            <td class="col-width-10">
                                <a class="button2 button-icon js-delete-role-button fa fa-times" data-id="<%= role.id %>" data-name="<%= role.name %>" data-inherit-type="roles" data-i18n="[title]Delete"></a>
                            </td>
                            <td class="left col-width-90">
                                <%= role.name %>
                            </td>
                        </tr>
                    <%
                });
                
                if (inheritedRoles == 0) {
                    %>
                        <tr>
                            <td><span class="second_row" data-i18n="No elements found"></span></td>
                        </tr>
                    <%
                }
            %>
        </tbody>
    </table>
</fieldset>
<table class="col-width-100">
    <tbody class="js-assign-role-control assign-role-control">
        <tr>
            <td class="col-width-10">
                <a class="button button-icon fa fa-plus-circle js-assign-role-button" data-i18n="[title]Assign"></a>
            </td>
            <td class="col-width-90">
                <select name="role_to_be_assigned">
                    <%
                    $.each(roles, function (iRole, role) {
                        if (role.inherited) {
                            return;
                        }
                    %>
                        <option value="<%= role.id %>">
                            <%= role.name %>
                        </option>
                    <%
                    });
                    %>
                </select>
            </td>
        </tr>
    </tbody>
</table>
