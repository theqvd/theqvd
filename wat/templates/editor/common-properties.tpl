<% 
    $.each(properties, function(propertyId, property) { 
%>
        <tr style="display: none;" class="js-editor-property-row" data-tenant-id="<%= property.tenant_id %>">
            <td>
                <input type="hidden" class="custom-prop-id" value="<%= property.property_id %>">
                <span class="custom-prop-name"><%= property.key %></span>
                <% if (property.tenant_id == SUPERTENANT_ID) { %>
                    <a class="fright fa fa-eye-slash needsclick" data-i18n="[title]Property only visible from outside of the tenant"></a>
                <% } %>
                <% if (property.description) { %>
                    <a class="fright fa fa-question-circle needsclick" data-i18n="[title]<%= property.description %>" style="margin-left: 6px;"></a>
                <% } %>
                <% if (editorMode == 'massive-edit') { %>
                    <a class="button fa fa-rotate-left js-no-change-reset no-change-reset invisible js-no-change-prop" data-i18n="Reset" data-field="<%= property.property_id %>"></a>
                <% } %>
            </td>
            <td>
                <input type="text" class="custom-prop-value" data-current="<%= property.value %>" value="<%= property.value %>" name="<%= property.property_id %>" <%= editorMode == 'massive-edit' ? 'data-i18n="[placeholder]No changes"' : '' %>>
            </td>
        </tr>
<%
    });
%>
