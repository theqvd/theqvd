<table>
    <% if (Wat.C.checkACL('osf.update-massive.description')) { %>
    <tr>
        <td data-i18n="Description"></td>
        <td>
            <textarea id="name" type="text" name="description"></textarea>
        </td>
    </tr>
    <% } %>
    <tr>
        <td data-i18n="Memory"></td>
        <td>
            <input type="text" class="half100" name="memory" value=""> MB
        </td>
    </tr>
    <tr>
        <td data-i18n="User storage"></td>
        <td>
            <input type="text" class="half100" name="user_storage" value=""> MB
            <div class="second_row">
                (<span data-i18n="Set 0 for not use User storage"></span>)
            </div>
        </td>
    </tr>
 </table>