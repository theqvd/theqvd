<table class="list details-list acls-management acls-management-acls col-width-100">
    <tr>
        <th colspan="2">
            <span data-i18n>ACLs added to the role besides the inheritance</span>
        </th>
    </tr>
    <tr> 
        <td>
            <span data-i18n>Available ACLs</span>
            <select name="acl_positive" class="side_to_side_select" multiple></select>
            <a class="button fa fa-plus-circle js-add-positive-acl-button" data-i18n>Add ACLs</a>
        </td>
        <td class="acls">
            <span data-i18n>Added ACLs</span>
            <select name="acl_positive_on_role" class="side_to_side_select" multiple></select>
            <a class="button fa fa-trash js-delete-positive-acl-button" data-i18n>Delete selected</a>
        </td>
    </tr>
</table>

<table class="list details-list acls-management acls-management-acls col-width-100">
    <tr>
        <th colspan="2">
            <span data-i18n>ACLs excluding list</span>
        </th>
    </tr>
    <tr> 
        <td>
            <span data-i18n>Available ACLs</span>
            <select name="acl_negative" class="side_to_side_select" multiple></select>
            <a class="button fa fa-filter js-add-negative-acl-button" data-i18n>Add ACLs to excluding list</a>
        </td>
        <td class="acls">
            <span data-i18n>Excluded ACLs</span>
            <select name="acl_negative_on_role" class="side_to_side_select" multiple></select>
            <a class="button fa fa-trash js-delete-negative-acl-button" data-i18n>Delete selected</a>
        </td>
    </tr>
</table>