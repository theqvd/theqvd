<table>
    <% if (Wat.C.checkACL('role.update-massive.description')) { %>
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
    <% if(Wat.C.checkACL('role.update.assign-role')) { %>
        <tr>
            <td data-i18n="Assign roles"></td>
            <td>
                <div class="bb-assign-roles assign-roles"></div>
            </td>
        </tr>
        <tr>
            <td data-i18n="Inherit templates"></td>
            <td>
                <div class="bb-assign-templates assign-templates"></div>
            </td>
        </tr>
    <% } %>
 </table>