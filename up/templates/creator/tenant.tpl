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
            <textarea id="name" type="text" name="description"></textarea>
        </td>
    </tr>
    <tr>
        <td data-i18n="Language"></td>
        <td>
            <select class="" name="language">
                <%
                    $.each(WAT_LANGUAGE_TENANT_OPTIONS, function (lanCode, lanText) {
                %>
                        <option value="<%= lanCode %>" data-i18n="<%= lanText %>"></option>
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
                        if (blockSize == 10) {
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
 </table>
