<tr class="<%= cid %>" data-id="<%= shortcut.id %>">
    <td class="col-width-50">
        <div data-i18n="Icon" class="left">Icon</div>
        <select name="asset_selector_icon" data-id="<%= shortcut.id %>" class="bb-os-conf-icon-assets bb-os-conf-icon-type-options js-asset-selector asset-selector list" data-asset-type="icon">
            <option data-i18n="Loading icons">Loading icons</option>
        </select>
        <div>
            <a href="javascript:" class="fa fa-file-o js-go-to-assets-management fright" data-asset-type="icon" data-i18n="Manage icons"></a>
        </div>
    </td>
    <td class="col-width-50">
        <div data-i18n="Name" class="left">Name</div>
        <input type="text" data-id="<%= shortcut.id %>" name="shortcut_name" placeholder="Name" data-i18n="[placeholder]Name" value="<%= shortcut.name %>">
    </td>
</tr>
<tr>
    <td colspan="2">
        <div data-i18n="Command">Command</div>
        <input type="text" data-id="<%= shortcut.id %>" name="shortcut_command" placeholder="Command" data-i18n="[placeholder]Command" value="<%= shortcut.code %>">
    </td>
</tr>
<tr class="<%= cid %>" data-id="<%= shortcut.id %>">
    <td colspan="2">
        <button class="button2 fright js-save-shortcut fa fa-save" href="javascript:" data-i18n="Save" data-id="<%= shortcut.id %>">Save</button>
        <button class="button2 fright fa fa-ban js-button-close-shortcut-configuration center" data-i18n="Cancel">Cancel</button>
    </td>
</tr>