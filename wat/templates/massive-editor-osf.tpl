<table>
    <tr>
        <td data-i18n>Memory</td>
        <td>
            <input type="text" class="half100" name="memory" value=""> MB
        </td>
    </tr>
    <tr>
        <td data-i18n>User storage</td>
        <td>
            <input type="text" class="half100" name="user_storage" value=""> MB
            <div class="second_row" data-i18n>
                <%=
                    '(' + i18n.t('Set 0 for not use User storage') + ')'
                %>
            </div>
        </td>
    </tr>
 </table>