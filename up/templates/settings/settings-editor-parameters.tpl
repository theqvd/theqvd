<tr class="js-form-field--settingrow <%= !settingsEnabled ? 'disabled-row' : '' %>" data-field-name="client" data-client-mode="both">
    <td data-i18n="Client"></td>
    <td>
        <select name="client" class="js-form-field js-form-field--setting js-client-selector" <%= !settingsEnabled ? 'disabled="disabled"' : '' %> data-subfield="settings">
            <option value="classic" <%= settings.client.value == 'classic' ? 'selected' : '' %> data-i18n="Classic client">Classic client</option>
            <option value="html5" <%= settings.client.value == 'html5' ? 'selected' : '' %>>HTML5</option>
        </select>
    </td>
</tr>
<tr class="js-form-field--settingrow <%= !settingsEnabled ? 'disabled-row' : '' %>" data-field-name="connection" data-client-mode="classic">
    <td data-i18n="Connection type"></td>
    <td>
        <select name="connection" class="js-form-field js-form-field--setting" <%= !settingsEnabled ? 'disabled="disabled"' : '' %> data-subfield="settings">
            <option value="adsl" <%= settings.connection.value == 'adsl' ? 'selected' : '' %>>ADSL</option>
            <option value="modem" <%= settings.connection.value == 'modem' ? 'selected' : '' %>>Modem</option>
            <option value="local" <%= settings.connection.value == 'local' ? 'selected' : '' %>>Local</option>
        </select>
    </td>
</tr>
<tr class="js-form-field--settingrow <%= !settingsEnabled ? 'disabled-row' : '' %>" data-field-name="audio" data-client-mode="classic">
    <td>
        <label data-i18n="Enable audio" for="audio"></label>
    </td>
    <td class="cell-link">
        <input 
            type="checkbox" 
            name="audio" 
            id="audio" 
            <%= parseInt(settings.audio.value) ? 'checked' : '' %> 
            class="js-form-field js-form-field--setting" 
            <%= !settingsEnabled ? 'disabled="disabled"' : '' %> 
            data-subfield="settings">
    </td>
</tr>
<tr class="js-form-field--settingrow <%= !settingsEnabled ? 'disabled-row' : '' %>" data-field-name="printers" data-client-mode="classic">
    <td>
        <label data-i18n="Enable printing" for="printers"></label>
    </td>
    <td class="cell-link">
        <input 
            type="checkbox" 
            name="printers" 
            id="printers" 
            <%= parseInt(settings.printers.value) ? 'checked' : '' %> 
            class="js-form-field js-form-field--setting" 
            <%= !settingsEnabled ? 'disabled="disabled"' : '' %> 
            data-subfield="settings">
    </td>
</tr>
<tr class="js-form-field--settingrow <%= !settingsEnabled ? 'disabled-row' : '' %>" data-field-name="fullscreen" data-client-mode="both">
    <td>
        <label data-i18n="Full screen visualization" for="fullscreen"></label>
    </td>
    <td class="cell-link">
        <input 
            type="checkbox" 
            name="fullscreen" 
            id="fullscreen" 
            <%= parseInt(settings.fullscreen.value) ? 'checked' : '' %> 
            class="js-form-field js-form-field--setting" 
            <%= !settingsEnabled ? 'disabled="disabled"' : '' %> 
            data-subfield="settings">
    </td>
</tr>
<tr class="js-form-field--settingrow <%= !settingsEnabled ? 'disabled-row' : '' %>" data-field-name="kb_layout" data-client-mode="html5">
    <td>
        <label data-i18n="Keyboard layout" for="kb_layout"></label>
    </td>
    <td>
        <select name="kb_layout" class="js-form-field js-form-field--setting" <%= !settingsEnabled ? 'disabled="disabled"' : '' %> data-subfield="settings">
            <%
                $.each(UP_KB_LAYOUT__OPTIONS, function (code, name) {
                    %>
                    <option data-i18n="<%= name %>" value="<%= code %>" <%= settings.kb_layout.value == code ? 'selected' : '' %>><%= name %></option>
                    <%
                });
            %>
        </select>
    </td>
</tr>
<tr class="js-form-field--settingrow <%= !settingsEnabled ? 'disabled-row' : '' %>" data-field-name="share_folders" data-client-mode="classic">
    <td>
        <label data-i18n="Share folders" for="share_folders"></label>
    </td>
    <td class="cell-link">
        <input 
            type="checkbox" 
            name="share_folders" 
            id="share_folders" 
            <%= parseInt(settings.share_folders.value) ? 'checked' : '' %> 
            class="js-form-field js-form-field--setting js-share-folders-check" 
            <%= !settingsEnabled ? 'disabled="disabled"' : '' %> 
            data-subfield="settings">
    </td>
</tr>
<tr class="js-form-field--settingrow js-form-field--foldersrow <%= !settingsEnabled || !parseInt(settings.share_folders.value) ? 'disabled-row' : '' %>" data-field-name="share_folders_list" data-client-mode="classic">
    <td colspan=2>
        <div class="second_row right">
            <i class="fa fa-lightbulb-o"></i>
            <span data-i18n="One path per line"></span>
        </div>
        <textarea 
            class="js-form-field js-form-field--folders js-form-field--setting" 
            name="share_folders_list" 
            style="height: 80px;" 
            data-subfield="settings" 
            data-listof="share_folders" 
            <%= !settingsEnabled || !parseInt(settings.share_folders.value) ? 'disabled="disabled"' : '' %>><%= settings.share_folders.list ? settings.share_folders.list.join("\n") : '' %></textarea>
    </td>
</tr>

<tr class="js-form-field--settingrow <%= !settingsEnabled ? 'disabled-row' : '' %>" data-field-name="share_usb" data-client-mode="classic">
    <td>
        <label data-i18n="Share USB" for="share_usb"></label>
    </td>
    <td class="cell-link">
        <input 
            type="checkbox" 
            name="share_usb" 
            id="share_usb" 
            <%= parseInt(settings.share_usb.value) ? 'checked' : '' %> 
            class="js-form-field js-form-field--setting js-share-usb-check" 
            <%= !settingsEnabled ? 'disabled="disabled"' : '' %> 
            data-subfield="settings">
    </td>
</tr>
<tr class="js-form-field--settingrow js-form-field--usbrow <%= !settingsEnabled || !parseInt(settings.share_usb.value) ? 'disabled-row' : '' %>" data-field-name="share_usb_list" data-client-mode="classic">
    <td colspan=2>
        <div class="second_row right">
            <i class="fa fa-lightbulb-o"></i>
            <span data-i18n="One USB ID per line"></span>
        </div>
        <textarea 
            class="js-form-field js-form-field--usb js-form-field--setting" 
            name="share_usb_list" 
            style="height: 80px;" 
            data-subfield="settings" 
            data-listof="share_usb" 
            <%= !settingsEnabled  || !parseInt(settings.share_usb.value) ? 'disabled="disabled"' : '' %>><%= settings.share_usb.list ? settings.share_usb.list.join("\n") : '' %></textarea>
    </td>
</tr>