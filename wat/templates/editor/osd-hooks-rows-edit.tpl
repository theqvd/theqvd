<tr class="<%= cid %>" data-id="<%= hook.id %>">
    <td class="col-width-50" colspan="2">
        <div data-i18n="Name" class="left">Name</div>
        <input type="text" data-id="<%= hook.id %>" name="hook_name" placeholder="Name" data-i18n="[placeholder]Name" value="<%= hook.name %>">
    </td>
</tr>
<tr class="<%= cid %>" data-id="<%= hook.id %>">
    <td class="col-width-50">
        <div data-i18n="Script" class="left">Script</div>
        <select data-id="<%= hook.id %>" class="js-hook bb-os-conf-hook js-os-conf-hook" data-control-id="icon">
            <option data-i18n="Loading scripts">Loading scripts</option>
        </select>
    </td>
    <td class="col-width-50">
        <div data-i18n="Hook type" class="left">Hook type</div>
        <select data-id="<%= hook.id %>" class="js-hook-type" data-control-id="icon">
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