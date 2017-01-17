<table>
    <tr>
        <td data-i18n="Name"></td>
        <td>
            <input type="text" class="" name="name" value="<%= model.get('name') %>" data-required>
        </td>
    </tr>
    <% if (Wat.C.checkACL('role.update.description')) { %>
    <tr>
        <td data-i18n="Description"></td>
        <td>
            <textarea id="name" type="text" name="description"><%= model.get('description') %></textarea>
        </td>
    </tr>
    <% } %>
    <% if (Wat.C.checkACL('role.update.assign-role') && (!model.get('fixed') || !RESTRICT_TEMPLATES)) { %>
        <tr>
            <td data-i18n="Inherit roles"></td>
            <td>
                <div class="bb-assign-roles assign-roles"></div>
            </td>
        </tr>
        <tr>
            <td>
                <span data-i18n="Inherit templates"></span>
                <div>
                    <a class="button2 fa fa-th js-templates-matrix-mode-btn" data-i18n="Matrix mode"></a>
                </div>
            </td>
            <td>
                <div class="bb-assign-templates assign-templates"></div>
            </td>
        </tr>
    <% } %>
 </table>