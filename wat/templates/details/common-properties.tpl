<% $.each(properties, function(propertyId, property) { %>
    <tr>
        <td><i class="<%= CLASS_ICON_PROPERTIES %>"></i><%= property.key %></td>
        <td>
            <%= property.value %>
        </td>
    </tr>
<% }); %>