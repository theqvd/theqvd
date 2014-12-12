<table>
    <tr>
        <td data-i18n="Name"></td>
        <td>
            <input type="text" name="name" value="" data-required>
        </td>
    </tr>
    <% 
    if (Wat.C.checkACL('osf.create.memory')) { 
    %>
    <tr>
        <td data-i18n="Memory"></td>
        <td>
            <input type="text" class="half100" name="memory" value=""> MB
            <div class="second_row" data-i18n>
                <%=
                    '(' + i18n.t('Leave it blank for default: __default_megabytes__ MB', {'default_megabytes': '256'}) + ')'
                %>
            </div>
        </td>
    </tr>
    <% 
    }
    if (Wat.C.checkACL('osf.create.user-storage')) { 
    %>
    <tr>
        <td data-i18n="User storage"></td>
        <td>
            <input type="text" class="half100" name="user_storage" value="0" data-required> MB
            <div class="second_row">
                (<span data-i18n="Set 0 for not use User storage"></span>)
            </div>
        </td>
    </tr>
    <% } %>
 </table>