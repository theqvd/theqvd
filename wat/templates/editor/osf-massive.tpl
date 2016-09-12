<table>
    <% if (Wat.C.checkACL('osf.update-massive.description')) { %>
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
            <span data-i18n="Memory"></span>
            <div class="second_row"><span data-i18n="No changes"></span><input type="checkbox" class="js-no-change" data-field="memory" checked="checked"></div>
        </td>
        <td>
            <input type="text" class="half100" name="memory" value=""> MB
        </td>
    </tr>
    <tr>
        <td>
            <span data-i18n="User storage"></span>
            <div class="second_row"><span data-i18n="No changes"></span><input type="checkbox" class="js-no-change" data-field="user_storage" checked="checked"></div>
        </td>
        <td>
            <input type="text" class="half100" name="user_storage" value=""> MB
            <div class="second_row">
                (<span data-i18n="Set to 0 for not using User storage"></span>)
            </div>
        </td>
    </tr>
 </table>