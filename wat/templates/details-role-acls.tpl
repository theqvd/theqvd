<table class="list acls-management acls-management-acls col-width-100 hidden">
    <tr>
        <th colspan="5">
            <span data-i18n>
                Role ACLs
            </span>
            <div class="second_row fa fa-info-circle block" data-i18n>
                Exclusion list will override inherited ACLs
            </div>
        </th>
    </tr>
    <tr>
        <td colspan="5">
            <span data-i18n>Section</span>
            <select name="section"></select>
            <span data-i18n>Action</span>
            <select name="action"></select>
        </td>
    </tr>
    <tr>
        <% if(Wat.C.checkACL('role.update.assign-acl')) { %>
        <td class="acls acls_available">
            <span data-i18n>Available ACLs</span>
            <select name="acl_available" class="side_to_side_select" multiple></select>
        </td>
        <% } %>
        <% if(Wat.C.checkACL('role.update.assign-acl')) { %>
        <td class="vbutton">
            <a class="button button-icon fa fa-arrow-right js-add-positive-acl-button" data-i18n></a>
        </td>
        <% } %>
        <td class="acls acls_positive">
            <span data-i18n>ACLs on role</span>
            <select name="acl_positive_on_role" class="side_to_side_select" multiple></select>
            <% if(Wat.C.checkACL('role.update.assign-acl')) { %>
            <a class="button fa fa-trash js-delete-positive-acl-button disabled" data-i18n>Delete selected</a>
            <% } %>
        </td>
    </tr>
</table>