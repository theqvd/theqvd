<table>
    <% 
    if (Wat.C.checkACL('osf.update.name')) { 
    %>
        <tr>
            <td data-i18n>Name</td>
            <td>
                <input type="text" class="" name="name" value="<%= model.get('name') %>" data-required>
            </td>
        </tr>
    <%
    }
    if (Wat.C.checkACL('osf.update.memory')) { 
    %>
        <tr>
            <td data-i18n>Memory</td>
            <td>
                <input type="text" class="half100" name="memory" value="<%= model.get('memory') %>"> MB
                <div class="second_row" data-i18n>
                    <%=
                        '(' + i18n.t('Leave it blank for default: __default_megabytes__ MB', {'default_megabytes': '256'}) + ')'
                    %>
                </div>
            </td>
        </tr>
    <%
    }
    if (Wat.C.checkACL('osf.update.user-storage')) { 
    %>
        <tr>
            <td data-i18n>User storage</td>
            <td>
                <input type="text" class="half100" name="user_storage" value="<%= model.get('user_storage') %>"> MB
                <div class="second_row" data-i18n>
                    <%=
                        '(' + i18n.t('Set 0 for not use User storage') + ')'
                    %>
                </div>
            </td>
        </tr>
    <% 
    }
    %>
</table>