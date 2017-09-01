<option 
    data-control-id="<%= assetType %>" 
    data-plugin-id="<%= pluginId %>" 
    data-none="true"
    data-i18n="None"
    value="0" 
    >
        None
    </option>
<% $.each (models, function (i, model) { %>
    <option 
        value="<%= model.get('id') %>" 
        data-id="<%= model.get('id') %>" 
        data-type="<%= model.get('assetType') %>" 
        data-url="<%= model.get('url') %>"
        data-name="<%= model.get('name') %>"
        data-control-id="<%= assetType %>"
        data-plugin-id="<%= pluginId %>"
    >
        <%= model.get('name') %>
    </option>
<% }); %>
