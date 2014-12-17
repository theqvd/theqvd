<table>
    <% if (Wat.C.checkACL('tenant.update.language')) { %>
    <tr>
        <td data-i18n="Language"></td>
        <td>
            <select class="" name="language">
                <%
                    $.each(WAT_LANGUAGE_TENANT_OPTIONS, function (lanCode, lanText) {
                        var selected = '';
                        if (lanCode == model.get('language')) {
                            selected = 'selected="selected"';
                        }
                %>
                        <option <%= selected %> value="<%= lanCode %>" data-i18n="<%= lanText %>"></option>
                <%
                    });
                %>
            </select>
        </td>
    </tr>
    <% } %>
</table>