<table>
    <tr>
        <td data-i18n>Name</td>
        <td>
            <input type="text" class="" name="name" value="<%= model.get('name') %>">
        </td>
    </tr>
    <tr>
        <td data-i18n>OS Flavour</td>
        <td>
            <%= model.get('osf_name') %>
        </td>
    </tr>
    <tr>
        <td data-i18n>Disk image's tag</td>
        <td>
            <input type="text" class="" name="di_tag" value="<%= model.get('di_tag') %>">
        </td>
    </tr>
    <tr>
        <td data-i18n>Expire</td>
        <td>
            <input type="checkbox" class="js-expire" name="expire" value="1">
        </td>
    </tr>
    <tr class="hidden expiration_row">
        <td data-i18n>Soft expiration</td>
        <td>
            <input type="text" class="datetimepicker" name="expiration_soft" value="">
        </td>
    </tr>
    <tr class="hidden expiration_row">
        <td data-i18n>Hard expiration</td>
        <td>
            <input type="text" class="datetimepicker" name="expiration_hard" value="">
        </td>
    </tr>
 </table>