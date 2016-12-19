<table>
    <% if (Wat.C.checkACL('administrator.update-massive.description')) { %>
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
    <% if(Wat.C.checkACL('administrator.update.assign-role')) { %>
        <tr>
            <td data-i18n="Assign roles"></td>
            <td>
                <div class="bb-assign-roles assign-roles"></div>
            </td>
        </tr>
    <% } %>
 </table>
