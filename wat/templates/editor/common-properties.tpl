<% 
    $.each(properties, function(propertyId, property) { 
%>
        <tr style="display: none;" class="js-editor-property-row" data-tenant-id="<%= property.tenant_id %>">
            <td>
                <input type="hidden" class="custom-prop-name" value="<%= propertyId %>">
                <span class="custom-prop-name"><%= property.key %></span>
                <% if (property.description) { %>
                    <a class="fright fa fa-question-circle needsclick" data-i18n="[title]<%= property.description %>" style="margin-left: 6px;"></a>
                <% } %>
            </td>
            <td>
                <input type="text" class="custom-prop-value" data-current="<%= property.value %>" value="<%= property.value %>">
            </td>
        </tr>
<%
    });
%>
