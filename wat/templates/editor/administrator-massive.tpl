<table>
    <% if (Wat.C.checkACL('administrator.update-massive.description')) { %>
        <tr>
            <td data-i18n="Description"></td>
            <td>
                <textarea id="name" type="text" name="description"></textarea>
            </td>
        </tr>
    <% } %>
    <% if(Wat.C.checkACL('administrator.update.assign-role')) { %>
        <tr>
            <td data-i18n="Assign roles"></td>
            <td>
                <div class="bb-assign-roles assign-roles"></div>
            </td>
        </tr>
    <% } %>
 </table>