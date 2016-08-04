<table class="list settings-editor-table js-settings-editor-table">
    <tbody>
        <% if (nameEditable) { %>
            <tr>
                <td><i data-i18n="Name"></i></td>
                <td><input type="text" name="name" value="<%= name %>" class="js-form-field"></td>
            </tr>
        <% } %>
        <tr>
            <td data-i18n="Connection type"></td>
            <td>
                <select name="connection_type" class="js-form-field" data-sub-field="settings">
                    <option value="adsl" <%= settings && settings.connection_type == 'adsl' ? 'selected' : '' %>>ADSL</option>
                    <option value="modem" <%= settings && settings.connection_type == 'modem' ? 'selected' : '' %>>Modem</option>
                    <option value="local" <%= settings && settings.connection_type == 'local' ? 'selected' : '' %>>Local</option>
            </td>
        </tr>
        <tr>
            <td data-i18n="Enable audio"></td>
            <td><input type="checkbox" name="audio" <%= settings && settings.audio ? 'checked' : '' %> class="js-form-field" data-sub-field="settings"></td>
        </tr>
        <tr>
            <td data-i18n="Enable printing"></td>
            <td><input type="checkbox" name="printing" <%= settings && settings.printing ? 'checked' : '' %> class="js-form-field" data-sub-field="settings"></td>
        </tr>
        <tr>
            <td data-i18n="Full screen visualization"></td>
            <td><input type="checkbox" name="full_screen" <%= settings && settings.full_screen ? 'checked' : '' %> class="js-form-field" data-sub-field="settings"></td>
        </tr>
        <tr>
            <td data-i18n="Share folders"></td>
            <td><input type="checkbox" name="share_folders" <%= settings && settings.share_folders ? 'checked' : '' %> class="js-form-field" data-sub-field="settings"></td>
        </tr>
        <tr>
            <td data-i18n="USB"></td>
            <td><input type="checkbox" name="share_usb" <%= settings && settings.share_usb ? 'checked' : '' %> class="js-form-field" data-sub-field="settings"></td>
        </tr>
    </tbody>
</table>