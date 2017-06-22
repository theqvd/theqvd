<% $.each (models, function (i, model) { %>
    <tr 
        data-id="<%= model.get('id') %>" 
        data-type="<%= model.get('type') %>" 
        data-url="<%= model.get('url') %>"
        data-name="<%= model.get('name') %>"
        data-control-id="<%= assetType %>"
        data-plugin-id="<%= pluginId %>"
    >
        <td class="cell-check">
            <input type="radio" name="<%= assetType %>" value="<%= model.get('id') %>">
        </td>
        <td class="col-width-100 js-<%= assetType %>-name">
            <%= model.get('name') %>
        </td>
        <td>
            <a class="button2 button-icon fa fa-trash" data-i18n="[title]Delete"></a>
        </td>
    </tr>
<% }); %>