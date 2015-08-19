<div class="editor-container <%= cid %>">
    <table class="editor-table alternate">
         <%
         if (editorMode == "massive_edit") {
         %>
            <tbody>
                <tr>
                    <td colspan=2></td>
                        <div class="info-header nopadding">
                            <span data-i18n class="fa fa-info-circle">Some fields are not available to be edited in massive edition</span><br> 
                        </div>
                    </td>
                </tr>
            </tbody>
         <%
         }
         %>
        <%
            // If the user is superadmin, show tenants select in creation form
            if (classifiedByTenant && editorMode == 'create' && isSuperadmin) {
        %>
                <tbody class="tenant-selector">
                    <tr>
                        <td data-i18n="Tenant"></td>
                        <td>
                            <select class="" name="tenant_id" id="tenant_editor"></select>
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
                    $.each(properties, function(propertyId, property) { 
                %>
                        <tr>
                            <td>
                                <input type="hidden" class="custom-prop-name" value="<%= propertyId %>">
                                <span class="custom-prop-name"><%= property.key %></span>
                            </td>
                            <td>
                                <% 
                                if (enabledUpdateProperties) { 
                                %>
                                    <input type="text" class="custom-prop-value" data-current="<%= property.value %>" value="<%= property.value %>">
                                <% 
                                }
                                else { 
                                %>
                                    <%= property.value %>
                                <% 
                                } 
                                %>
                            </td>
                        </tr>
                <%
                    });
                %>
            </tbody>
        <%
            }
        %>
    </table>
</div>