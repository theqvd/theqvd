<tr class="<%= cid %>" data-id="<%= hook.id %>">
    <td class="col-width-50" colspan="2">
        <div data-i18n="Name" class="left">Name</div>
        <input type="text" data-id="<%= hook.id %>" name="hook_name" placeholder="Name" data-i18n="[placeholder]Name" value="<%= hook.name %>">
    </td>
</tr>
<tr class="<%= cid %>" data-id="<%= hook.id %>">
    <td class="col-width-50">
        <div data-i18n="Script" class="left">Script</div>
        <select name="asset_selector_script" data-id="<%= hook.id %>" class="js-hook bb-os-conf-hook js-os-conf-hook" data-asset-type="script">
            <option data-i18n="Loading scripts">Loading scripts</option>
        </select>
        <div>
            <a href="javascript:" class="fa fa-file-o js-go-to-assets-management fright" data-asset-type="script" data-i18n="Manage scripts"></a>
        </div>
    </td>
    <td class="col-width-50">
        <div data-i18n="Hook type" class="left">Hook type</div>
        <select name="hook_type" data-id="<%= hook.id %>" class="js-hook-type" data-asset-type="icon">
            <% $.each(hookTypes, function (iHT, ht) { %>
                <option data-i18n="<%= ht %>" <%= ht == hook.hookType ? 'selected="selected"' : '' %>><%= ht %></option>
            <% }); %>
        </select>
    </td>
</tr>
<tr class="<%= cid %>" data-id="<%= hook.id %>">
    <td colspan="2">
        <button class="button2 fright js-save-hook fa fa-save" href="javascript:" data-i18n="Save" data-id="<%= hook.id %>">Save</button>
        <button class="button2 fright fa fa-ban js-button-close-hook-configuration center" data-i18n="Cancel">Cancel</button>
    </td>
</tr>