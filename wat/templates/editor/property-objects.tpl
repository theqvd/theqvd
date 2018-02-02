<tr>
    <td data-i18n="Users"></td>
    <td class="cell-check">
        <input type="checkbox" name="in_user" value="1" <%= checkedObjs.user ? 'checked' : '' %>>
    </td>
</tr>
<tr>
    <td data-i18n="Virtual machines"></td>
    <td class="cell-check">
        <input type="checkbox" name="in_vm" value="1" <%= checkedObjs.vm ? 'checked' : '' %>>
    </td>
</tr>
<% if (hostPropertiesEnabled) { %>
    <tr>
        <td data-i18n="Nodes"></td>
        <td class="cell-check">
            <input type="checkbox" name="in_host" value="1" <%= checkedObjs.host ? 'checked' : '' %>>
        </td>
    </tr>
<% } %>
<tr>
    <td data-i18n="OS Flavours"></td>
    <td class="cell-check">
        <input type="checkbox" name="in_osf" value="1" <%= checkedObjs.osf ? 'checked' : '' %>>
    </td>
</tr>
<tr>
    <td data-i18n="Disk images"></td>
    <td class="cell-check">
        <input type="checkbox" name="in_di" value="1" <%= checkedObjs.di ? 'checked' : '' %>>
    </td>
</tr>