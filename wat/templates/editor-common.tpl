<div class="editor-container <%= cid %>">
    <table class="editor-table alternate">
        <%
            // If the user is superadmin, show tenants select in creation form
            if (classifiedByTenant && editorMode == 'create' && isSuperadmin) {
        %>
                <tbody class="tenant-selector">
                    <tr>
                        <td data-i18n>Tenant</td>
                        <td>
                            <select class="" name="tenant_id"></select>
                        </td>
                    </tr>
                </tbody>
        <%
            }
        %>
        
        <tbody class="bb-editor"></tbody>
        
        <%
            if (enabledProperties) {
        %>
            <tbody class="custom-properties">
                <input type="hidden" class="deleted-properties" value=""/>

                <% 
                    _.each(properties, function(propValue, propName) { 
                %>
                        <tr>
                            <td>
                                <i class="delete-property-button fa fa-trash-o"></i>
                                <input type="hidden" class="custom-prop-name" value="<%= propName %>">
                                <span class="custom-prop-name"><%= propName %></span>
                            </td>
                            <td>
                                <input type="text" class="custom-prop-value" data-current="<%= propValue %>" value="<%= propValue %>">
                            </td>
                        </tr>
                <%
                    });
                %>
                <tr class="template-property hidden">
                    <td>
                            <i class="delete-property-button fa fa-trash-o"></i>
                            <span class="property-help" data-i18n="Property name"></span>
                            <input type="text" class="custom-prop-name">
                    </td>
                    <td>
                            <span class="property-help" data-i18n="Property value">ss</span>
                            <input type="text" class="custom-prop-value">
                    </td>
                </tr>
                <tr>
                    <td>
                        <a class="button2 add-property-button fa fa-plus-circle" data-i18n="Add property"></a>
                    </td>
                    <td></td>
                </tr>
            </tbody>
        <%
            }
        %>
    </table>
</div>