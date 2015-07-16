<table>
    <% if (Wat.C.checkACL('vm.update-massive.description')) { %>
    <tr>
        <td data-i18n="Description"></td>
        <td>
            <textarea id="name" type="text" name="description"></textarea>
        </td>
    </tr>
    <% } %>
    <tr>
        <td data-i18n="Image tag"></td>
        <td>
            <select class="" name="di_tag"></select>
            <div class="second_row js-advice-various-osfs hidden">
                <i class="fa fa-warning"></i>
                <span data-i18n="The operation will be performed over Virtual machines with different associated OSFs"></span>
            </div>
        </td>
    </tr>
    <tr>
        <td data-i18n="Expire"></td>
        <td>
            <input type="checkbox" class="js-expire" name="expire" value="1">
        </td>
    </tr>
    <tr class="hidden expiration_row">
        <td data-i18n="Soft expiration"></td>
        <td>
            <input type="text" class="datetimepicker" name="expiration_soft" value="">
        </td>
    </tr>
    <tr class="hidden expiration_row">
        <td data-i18n="Hard expiration"></td>
        <td>
            <input type="text" class="datetimepicker" name="expiration_hard" value="">
        </td>
    </tr>
</table>