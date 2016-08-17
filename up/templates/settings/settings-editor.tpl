<%
    var settingsDisabled = canBeDisabled && !model.get('settings_enabled');
%>

<table class="settings-editor-table js-settings-editor-table">
    <tbody>
        <% if (!model.get('fixed')) { %>
            <tr>
                <td><label data-i18n="Name" for="name"></label></td>
                <td><input type="text" name="name" id="name" value="<%= model.get('alias') ? model.get('alias') : model.get('name') %>" class="js-form-field"></td>
            </tr>
        <% } %>
        <% if (canBeDisabled) { %>
            <tr>
                <td><label data-i18n="Enable settings" for="settings_enabled"></label></td>
                <td class="cell-link"><input type="checkbox" name="settings_enabled" id="settings_enabled" <%= model.get('settings_enabled') ? 'checked' : '' %> class="js-form-field js-disable-settings-check"></td>
            </tr>
        <% } %>
        <tr class="js-form-field--settingrow <%= settingsDisabled ? 'disabled-row' : '' %>">
            <td data-i18n="Connection type"></td>
            <td>
                <select name="connection" class="js-form-field js-form-field--setting" <%= settingsDisabled ? 'disabled="disabled"' : '' %> data-subfield="settings">
                    <option value="adsl" <%= model.get('settings') && model.get('settings').connection.value == 'adsl' ? 'selected' : '' %>>ADSL</option>
                    <option value="modem" <%= model.get('settings') && model.get('settings').connection.value == 'modem' ? 'selected' : '' %>>Modem</option>
                    <option value="local" <%= model.get('settings') && model.get('settings').connection.value == 'local' ? 'selected' : '' %>>Local</option>
            </td>
        </tr>
        <tr class="js-form-field--settingrow <%= settingsDisabled ? 'disabled-row' : '' %>">
            <td><label data-i18n="Enable audio" for="audio"></label></td>
            <td class="cell-link"><input type="checkbox" name="audio" id="audio" <%= model.get('settings') && parseInt(model.get('settings').audio.value) ? 'checked' : '' %> class="js-form-field js-form-field--setting" <%= settingsDisabled ? 'disabled="disabled"' : '' %> data-subfield="settings"></td>
        </tr>
        <tr class="js-form-field--settingrow <%= settingsDisabled ? 'disabled-row' : '' %>">
            <td><label data-i18n="Enable printing" for="printers"></label></td>
            <td class="cell-link"><input type="checkbox" name="printers" id="printers" <%= model.get('settings') && parseInt(model.get('settings').printers.value) ? 'checked' : '' %> class="js-form-field js-form-field--setting" <%= settingsDisabled ? 'disabled="disabled"' : '' %> data-subfield="settings"></td>
        </tr>
        <tr class="js-form-field--settingrow <%= settingsDisabled ? 'disabled-row' : '' %>">
            <td><label data-i18n="Full screen visualization" for="fullscreen"></label></td>
            <td class="cell-link"><input type="checkbox" name="fullscreen" id="fullscreen" <%= model.get('settings') && parseInt(model.get('settings').fullscreen.value) ? 'checked' : '' %> class="js-form-field js-form-field--setting" <%= settingsDisabled ? 'disabled="disabled"' : '' %> data-subfield="settings"></td>
        </tr>
        
        <tr class="js-form-field--settingrow <%= settingsDisabled ? 'disabled-row' : '' %>">
            <td><label data-i18n="Share folders" for="share_folders"></label></td>
            <td class="cell-link"><input type="checkbox" name="share_folders" id="share_folders" <%= model.get('settings') && parseInt(model.get('settings').share_folders.value) ? 'checked' : '' %> class="js-form-field js-form-field--setting js-share-folders-check" <%= settingsDisabled ? 'disabled="disabled"' : '' %> data-subfield="settings"></td>
        </tr>
        <tr class="js-form-field--settingrow js-form-field--foldersrow <%= settingsDisabled ? 'disabled-row' : '' %> <%= model.get('settings') && parseInt(model.get('settings').share_folders.value) ? '' : 'disabled-row' %>">
            <td colspan=2>                
                <div class="second_row right"><i class="fa fa-lightbulb-o"></i><span data-i18n="One path per line"></span></div>
                <textarea class="js-form-field js-form-field--folders js-form-field--setting" name="share_folders_list" style="height: 80px;" data-subfield="settings" data-listof="share_folders" <%= model.get('settings') && parseInt(model.get('settings').share_folders.value) ? '' : 'disabled="disabled"' %>><%= model.get('settings') && model.get('settings').share_folders.list ? model.get('settings').share_folders.list.join("\n") : '' %></textarea>
            </td>
        </tr>
        
        <tr class="js-form-field--settingrow <%= settingsDisabled ? 'disabled-row' : '' %>">
            <td><label data-i18n="Share USB" for="share_usb"></label></td>
            <td class="cell-link"><input type="checkbox" name="share_usb" id="share_usb" <%= model.get('settings') && parseInt(model.get('settings').share_usb.value) ? 'checked' : '' %> class="js-form-field js-form-field--setting js-share-usb-check" <%= settingsDisabled ? 'disabled="disabled"' : '' %> data-subfield="settings"></td>
        </tr>
        <tr class="js-form-field--settingrow js-form-field--usbrow <%= settingsDisabled ? 'disabled-row' : '' %> <%= model.get('settings') && parseInt(model.get('settings').share_usb.value) ? '' : 'disabled-row' %>">
            <td colspan=2>                
                <div class="second_row right"><i class="fa fa-lightbulb-o"></i><span data-i18n="One USB ID per line"></span></div>
                <textarea class="js-form-field js-form-field--usb js-form-field--setting" name="share_usb_list" style="height: 80px;" data-subfield="settings" data-listof="share_usb" <%= model.get('settings') && parseInt(model.get('settings').share_usb.value) ? '' : 'disabled="disabled"' %>><%= model.get('settings') && model.get('settings').share_usb.list ? model.get('settings').share_usb.list.join("\n") : '' %></textarea>
            </td>
        </tr>
    </tbody>
</table>