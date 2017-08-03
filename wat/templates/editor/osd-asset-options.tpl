<% $.each (models, function (i, model) { %>
    <option 
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
