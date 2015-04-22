<table>
    <tr>
        <td data-i18n="Change password"></td>
        <td>
            <input type="checkbox" class="js-change-password" name="change_password" value="1">
        </td>
    </tr>
    <tr class="hidden new_password_row">
        <td data-i18n="New password"></td>
        <td>
            <input type="password" name="password" value="" data-required data-equal="password">
        </td>
    </tr>
    <tr class="hidden new_password_row">
        <td data-i18n="Re-type new password"></td>
        <td>
            <input type="password" name="password2" value="" data-required data-equal="password">
        </td>
    </tr>
    <tr>
        <td data-i18n="Language"></td>
        <td>
            <select class="" name="language">
                <%
                    $.each(WAT_LANGUAGE_ADMIN_OPTIONS, function (lanCode, lanText) {
                        var selected = '';
                        if (lanCode == Wat.C.language) {
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
                    $.each(WAT_BLOCK_SIZES_ADMIN, function (blockSize, blockSizeText) {
                        var selected = '';
                        if (blockSize == Wat.C.block) {
                            selected = 'selected="selected"';
                        }
                        
                        if (blockSize == 0) {
                %>
                        <option <%= selected %> value="<%= blockSize %>" data-i18n="<%= blockSizeText %>"></option>
                <%
                        }
                        else {
                %>
                        <option <%= selected %> value="<%= blockSize %>"><%= blockSizeText %></option>
                <%
                        }
                    });
                %>
            </select>
        </td>
    </tr>
 </table>