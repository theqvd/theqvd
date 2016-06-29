<% $.each(properties, function(propertyId, property) { %>
    <tr>
        <td>
            <i class="<%= CLASS_ICON_PROPERTIES %>"></i><%= property.key %>
            
            <% if (property.tenant_id == SUPERTENANT_ID) { %>
                <a class="fright fa fa-eye-slash needsclick" data-i18n="[title]Property only visible from outside of the tenant"></a>
            <% } %>
            
            <% if (property.description) { %>
                <a class="fright fa fa-file-text-o needsclick" data-i18n="[title]<%= property.description %>"></a>
            <% } %>
        </td>
        <td>
            <%= property.value %>
        </td>
    </tr>
<% }); %>