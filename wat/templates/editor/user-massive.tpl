<table>
    <% if (Wat.C.checkACL('user.update-massive.description')) { %>
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
 </table>