<option 
    data-asset-type="<%= assetType %>" 
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
        data-asset-type="<%= assetType %>"
        data-plugin-id="<%= pluginId %>"
        <%= assetType == 'icon' ? 'data-img-src="' + model.get('url') + '"' : '' %>
    >
        <%= model.get('name') %>
    </option>
<% }); %>
