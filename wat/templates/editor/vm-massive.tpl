<table>
    <% if (Wat.C.checkACL('vm.update-massive.description')) { %>
    <tr>
        <td>
            <span data-i18n="Description"></span>
            <a class="button fa fa-rotate-left js-no-change-reset no-change-reset invisible" data-i18n="Reset" data-field="description"></a>
        </td>
        <td>
            <textarea id="name" type="text" name="description" data-i18n="[placeholder]No changes"></textarea>
        </td>
    </tr>
    <% } %>
    <tr>
        <td>
            <span data-i18n="Image tag"></span>
            <a class="button fa fa-rotate-left js-no-change-reset no-change-reset invisible" data-i18n="Reset" data-field="di_tag"></a>
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
            <a class="button fa fa-rotate-left js-no-change-reset no-change-reset invisible" data-i18n="Reset" data-field="expiration_soft"></a>
        </td>
        <td>
            <input type="text" class="datetimepicker" name="expiration_soft" value="" data-i18n="[placeholder]No changes">
        </td>
    </tr>
    <tr class="expiration_row">
        <td>
            <span data-i18n="Hard expiration"></span>
            <a class="button fa fa-rotate-left js-no-change-reset no-change-reset invisible" data-i18n="Reset" data-field="expiration_hard"></a>
        </td>
        <td>
            <input type="text" class="datetimepicker" name="expiration_hard" value="" data-i18n="[placeholder]No changes">
        </td>
    </tr>
</table>