<div class="editor-container">
    <table class="editor-table">
        <tbody class="bb-editor"></tbody>
        <tbody class="custom-properties">
            <% 
                _.each(model.get('customProps'), function(propValue, propName) { 
            %>
                    <tr>
                        <td>
                            <i class="delete-property-button fa fa-trash-o"></i>
                            <input type="text" class="custom_prop_name" value="<%= propName %>">
                        </td>
                        <td>
                            <input type="text" class="custom_prop_value" value="<%= propValue %>">
                        </td>
                    </tr>
            <%
                });
            %>
            <tr class="template-property hidden">
                <td>
                        <i class="delete-property-button fa fa-trash-o"></i>
                        <span class="property-help" data-i18n="property_name"></span>
                        <input type="text" class="custom_prop_name">
                </td>
                <td>
                        <span class="property-help" data-i18n="property_value">ss</span>
                        <input type="text" class="custom_prop_value">
                </td>
            </tr>
            <tr>
                <td>
                    <a class="button2 add-property-button fa fa-plus-circle" data-i18n="add_property"></a>
                </td>
                <td></td>
            </tr>
        </tbody>
    </table>
</div>