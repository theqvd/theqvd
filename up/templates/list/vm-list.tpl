<table class="list">
    <tbody>
        <% 
        if (models.length == 0) {
        %>  
            <tr>
                <td colspan="3">
                    <span class="no-elements" data-i18n="There are not elements">
                        <%= i18n.t('There are not elements') %>
                    </span>
                </td>
            </tr>
        <%
        }
        else {
            $.each(models, function (iModel, model) {
                var checkedAttr = false;
        %>
            <tr class="row-<%= model.get('id') %>">
                <%
                if (checkBox) {
                %>
                    <td>
                        <input type="checkbox" class="check-it js-check-it" data-id="<%= model.get('id') %>" <%= checkedAttr %>>
                    </td>
                <%
                }
                %>
                <td>
                    <%= Wat.CurrentView.getUserStateIcon(model.get('user_state'), model.get('id')) %>
                    <%= Wat.CurrentView.getWarningIcon(model.get('expiration_hard'), model.get('id')) %>
                </td>
                <td class="js-name col-width-100">
                    <span class="bigtext bold vm-name">GRID <%= model.get('name') %></span>
                    <div class="liltext">
                    <a href="javascript:" class="js-vm-details" data-model-id="<%= model.get('id') %>" data-i18n="[title]Click for details">
                        <span class="text" data-model-id="<%= model.get('id') %>" data-i18n="Details"></span>
                    </a>
                    |
                    <a href="javascript:" class="js-vm-settings" data-model-id="<%= model.get('id') %>" data-i18n="[title]Click to configure the connection parameters">
                        <span class="text" data-model-id="<%= model.get('id') %>" data-i18n="Connection settings"></span>
                    </a>
                    </div>
                </td>
                <td>
                    <a class="fa fa-plug button js-login-button" data-i18n="Connect"></a>
                </td>
            </tr>
        <%
            });
        }
        %>
    </tbody>
</table>