<table>
    <tr>
        <td data-i18n="Name" class="mandatory-label"></td>
        <td>
            <input id="name" type="text" name="name" value="" data-required>
        </td>
    </tr>
    <tr>
        <td data-i18n="Description"></td>
        <td>
            <textarea id="description" type="text" name="description"></textarea>
        </td>
    </tr>
    <% if(Wat.C.checkACL('role.update.assign-role')) { %>
        <tr>
            <td data-i18n="Inherit roles"></td>
            <td>
                <div class="bb-assign-roles assign-roles"></div>
            </td>
        </tr>
        <tr>
            <td data-i18n="Inherited templates"></td>
            <td>
                <div class="bb-assign-templates assign-templates"></div>
            </td>
        </tr>
    <% } %>
 </table>
