<table>
    <% if (Wat.C.checkACL('user.update-massive.description')) { %>
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
 </table>