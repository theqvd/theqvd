<% $.each(properties, function(propertyId, property) { %>
    <tr>
        <td>
            <i class="<%= CLASS_ICON_PROPERTIES %>"></i><%= property.key %>
            <% if (property.description) { %>
                <a class="fright fa fa-question-circle needsclick" data-i18n="[title]<%= property.description %>"></a>
            <% } %>
        </td>
        <td>
            <%= property.value %>
        </td>
    </tr>
<% }); %>