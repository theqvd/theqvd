<table>
    <tr>
        <td colspan=2 class="colspanned">
            <span data-i18n="Because of the last change, the following Virtual Machines are running with a different Disk Image than the assigned one"></span>
        </td>
    </tr>
    <tr>
        <td colspan=2 class="colspanned bb-affected-vms-list">
            <!-- TODO: VM list with checkbox to select those that want to be edited -->
        </td>
    </tr>
    <tr>
        <td colspan=2 class="colspanned">
            <span data-i18n="Select an expiration date for the selected Virtual Machines to normalize this situation"></span>
        </td>
    </tr>
    <tr class="expiration_row">
        <td data-i18n="Soft expiration"></td>
        <td>
            <input type="text" class="datetimepicker" name="expiration_soft" value="">
        </td>
    </tr>
    <tr class="expiration_row">
        <td data-i18n="Hard expiration"></td>
        <td>
            <input type="text" class="datetimepicker" name="expiration_hard" value="">
        </td>
    </tr>
</table>