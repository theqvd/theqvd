<table>
    <% if (Wat.C.checkACL('config.wat.')) { %>
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
        <tr>
            <td data-i18n="Block size"></td>
            <td>
                <select class="" name="block">
                    <%
                        $.each(WAT_BLOCK_SIZES, function (blockSize, blockSizeText) {
                            var selected = '';
                            if (blockSize == model.get('block')) {
                                selected = 'selected="selected"';
                            }

                    %>
                            <option <%= selected %> value="<%= blockSize %>"><%= blockSizeText %></option>
                    <%
                        });
                    %>
                </select>
            </td>
        </tr>
        <% if (Wat.C.isSuperadmin() || !Wat.C.isMultitenant()) { %>
            <tr class="desktop-row">
            <td data-i18n="Style customizer tool"></td>
            <td>
                <input type="checkbox" name="style-customizer" <%= $.cookie('styleCustomizer') ? 'checked' : '' %>/>
            </td>
            </tr>
        <% } %>
    <% } %>
</table>