<% if (models.length == 0) { %>
    <tr>
        <td class="second_row" data-i18n="No elements found"></td>
    </tr>
<% } %>

<% $.each (models, function (i, model) { %>
      <tr 
          data-id="<%= model.get('id') %>" 
          data-type="<%= model.get('assetType') %>" 
          data-url="<%= model.get('url') %>"
          data-name="<%= model.get('name') %>"
          data-control-id="<%= model.get('assetType') %>"
          data-plugin-id="<%= pluginId %>"
      >
          <td class="cell-check">
              <input type="radio" name="<%= assetType %>" value="<%= model.get('id') %>" class="js-asset-check" data-plugin-id="<%= pluginId %>">
          </td>
          <% if (assetType == 'icon') { %>
              <td class="col-width-10 js-<%= assetType %> asset-image">
                  <img src="<%= model.get('url') %>" style="width: 32px;">
              </td>
          <% } %>
          <td class="col-width-100 js-<%= assetType %>-name asset-name">
              <%= model.get('name') %>
          </td>
      </tr>
<% }); %>