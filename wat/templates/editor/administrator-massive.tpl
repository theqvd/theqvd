<table>
    <% if (Wat.C.checkACL('administrator.update-massive.description')) { %>
    <tr>
        <td data-i18n="Description"></td>
        <td>
            <textarea id="name" type="text" name="description"></textarea>
        </td>
    </tr>
    <% } %>
 </table>