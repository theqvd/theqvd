<table>
    <% if (Wat.C.checkACL('osf.update-massive.description')) { %>
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
            <span data-i18n="Memory"></span>
            <a class="button fa fa-rotate-left js-no-change-reset no-change-reset invisible" data-i18n="Reset" data-field="memory"></a>
        </td>
        <td>
            <input type="text" class="half100" name="memory" value="" data-i18n="[placeholder]No changes"> MB
        </td>
    </tr>
    <tr>
        <td>
            <span data-i18n="User storage"></span>
            <a class="button fa fa-rotate-left js-no-change-reset no-change-reset invisible" data-i18n="Reset" data-field="user_storage"></a>
        </td>
        <td>
            <input type="text" class="half100" name="user_storage" value="" data-i18n="[placeholder]No changes"> MB
            <div class="second_row">
                (<span data-i18n="Set to 0 for not using User storage"></span>)
            </div>
        </td>
    </tr>
 </table>