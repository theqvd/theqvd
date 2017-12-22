<table class="editor-container <%= cid %> settings-editor-table js-settings-editor-table">
    <tbody>
        <% if (!model.get('fixed')) { %>
            <tr>
                <td><label data-i18n="Name" for="name" class="mandatory-label"></label></td>
                <td><input type="text" name="name" id="name" value="<%= model.get('alias') ? model.get('alias') : model.get('name') %>" data-original-value="<%= model.get('alias') ? model.get('alias') : model.get('name') %>" class="js-form-field" data-required></td>
            </tr>
        <% } %>
        <% if (canBeDisabled) { %>
            <tr>
                <td><label data-i18n="Enable own settings" for="settings_enabled"></label></td>
                <td class="cell-link">
                    <input 
                        type="checkbox" 
                        name="settings_enabled" 
                        id="settings_enabled" 
                        <%= model.get('settings_enabled') ? 'checked' : '' %> 
                        data-original-checked="<%= model.get('settings_enabled') %>" 
                        class="js-form-field js-disable-settings-check"
                    >
                </td>
            </tr>
        <% } %>
    </tbody>
    <tbody class="bb-editor-parameters"></tbody>
</table>