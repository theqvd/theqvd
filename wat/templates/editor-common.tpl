<div class="editor-container">
    <table class="editor-table alternate">
        <tbody class="bb-editor"></tbody>
        <%
            // If the model has the blocked attr, will appear on editor
            if (model.get('blocked') !== undefined) {
        %>
                <tbody class="blocked-śelector">
                    <tr>
                        <td data-i18n="Blocked"></td>
                        <td>
                            <%
                                var blockedChecked = '';
                                var unblockedChecked = 'checked';

                                if (model.get('blocked')) {
                                    blockedChecked = 'checked';
                                    unblockedChecked = '';
                                }
                            %>
                            <input type="radio" name="blocked" <%= unblockedChecked %> value="0">
                            <i class="fa fa-unlock"></i>
                            <input type="radio" name="blocked" <%= blockedChecked %> value="1">
                            <i class="fa fa-lock"></i>
                        </td>
                    </tr>
                </tbody>
        <%
            }
        %>
        <tbody class="custom-properties">
            <% 
                _.each(model.get('properties'), function(propValue, propName) { 
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
                        <span class="property-help" data-i18n="Property name"></span>
                        <input type="text" class="custom_prop_name">
                </td>
                <td>
                        <span class="property-help" data-i18n="Property value">ss</span>
                        <input type="text" class="custom_prop_value">
                </td>
            </tr>
            <tr>
                <td>
                    <a class="button2 add-property-button fa fa-plus-circle" data-i18n="Add property"></a>
                </td>
                <td></td>
            </tr>
        </tbody>
    </table>
</div>