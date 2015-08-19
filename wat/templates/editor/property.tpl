<table>
    <tr>
        <td data-i18n="Name" class="mandatory-label"></td>
        <td>
            <input id="key" type="text" name="key" value="<%= model.get('key') %>" data-required>
        </td>
    </tr>
    <tr>
        <td data-i18n="Description"></td>
        <td>
            <textarea id="description" type="text" name="description"><%= model.get('description') %></textarea>
        </td>
    </tr>
 </table>
