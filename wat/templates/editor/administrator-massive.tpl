<table>
    <% if (Wat.C.checkACL('administrator.update-massive.description')) { %>
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
    <% if(Wat.C.checkACL('administrator.update.assign-role')) { %>
        <tr>
            <td data-i18n="Assign roles"></td>
            <td>
                <div class="bb-assign-roles assign-roles"></div>
            </td>
        </tr>
    <% } %>
    <% 
    if (Wat.C.checkACL('administrator.update.language')) { 
    %>
        <tr>
            <td>
                <span data-i18n="Language"></span>
            </td>
            <td>
                <select class="" name="language">
                    <option selected="selected" value="" data-i18n="No changes"></option>
                    <%
                        $.each(WAT_LANGUAGE_ADMIN_OPTIONS, function (lanCode, lanText) {
                    %>
                            <option value="<%= lanCode %>" data-i18n="<%= lanText %>"></option>
                    <%
                        });
                    %>
                </select>
            </td>
        </tr>
    <% 
    }
    %>
 </table>
