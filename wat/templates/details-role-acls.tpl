<table class="list details-list acls-management acls-management-acls col-width-100 hidden">
    <tr>
        <th colspan="5">
            <span data-i18n>
                Add/Exclude ACLs
            </span>
            <div class="second_row fa fa-info-circle block" data-i18n>
                Exclusion list will override inherited ACLs
            </div>
        </th>
    </tr>
    <tr>
        <td class="acls acls_negative">
            <span data-i18n>Excluded ACLs</span>
            <select name="acl_negative_on_role" class="side_to_side_select" multiple></select>
            <a class="button fa fa-trash js-delete-negative-acl-button" data-i18n>Delete selected</a>
        </td>
        <td class="vbutton">
            <a class="button button--red button-icon fa fa-arrow-left js-add-negative-acl-button" data-i18n></a>
        </td>
        <td class="acls acls_available">
            <span data-i18n>Available ACLs</span>
            <select name="acl_available" class="side_to_side_select" multiple></select>
        </td>
        <td class="vbutton">
            <a class="button button--green button-icon fa fa-arrow-right js-add-positive-acl-button" data-i18n></a>
        </td>
        <td class="acls acls_positive">
            <span data-i18n>ACLs on role</span>
            <select name="acl_positive_on_role" class="side_to_side_select" multiple></select>
            <a class="button fa fa-trash js-delete-positive-acl-button" data-i18n>Delete selected</a>
        </td>
    </tr>
</table>