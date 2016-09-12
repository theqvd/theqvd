<table>
    <% if (Wat.C.checkACL('vm.update-massive.description')) { %>
    <tr>
        <td>
            <span data-i18n="Description"></span>
            <div class="second_row"><span data-i18n="No changes"></span><input type="checkbox" class="js-no-change" data-field="description" checked="checked"></div>
        </td>
        <td>
            <textarea id="name" type="text" name="description"></textarea>
        </td>
    </tr>
    <% } %>
    <tr>
        <td>
            <span data-i18n="Image tag"></span>
        </td>
        <td>
            <select class="" name="di_tag"></select>
            <div class="second_row js-advice-various-osfs hidden">
                <i class="fa fa-warning"></i>
                <span data-i18n="The operation will be performed over Virtual machines with different associated OSFs"></span>
            </div>
        </td>
    </tr>
    <tr class="expiration_row">
        <td>
            <span data-i18n="Soft expiration"></span>
            <div class="second_row"><span data-i18n="No changes"></span><input type="checkbox" class="js-no-change" data-field="expiration_soft" checked="checked"></div>
        </td>
        <td>
            <input type="text" class="datetimepicker" name="expiration_soft" value="">
        </td>
    </tr>
    <tr class="expiration_row">
        <td>
            <span data-i18n="Hard expiration"></span>
            <div class="second_row"><span data-i18n="No changes"></span><input type="checkbox" class="js-no-change" data-field="expiration_hard" checked="checked"></div>
        </td>
        <td>
            <input type="text" class="datetimepicker" name="expiration_hard" value="">
        </td>
    </tr>
</table>