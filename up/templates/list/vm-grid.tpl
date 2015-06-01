<table class="list">
    <tbody>
        <tr>
            <td colspan="3">
                <% 
                if (models.length == 0) {
                %>  
                    <span class="no-elements" data-i18n="There are not elements">
                        <%= i18n.t('There are not elements') %>
                    </span>
                <%
                }
                else {
                    $.each(models, function (iModel, model) {
                        var checkedAttr = false;
                %>
                    <div class="row-<%= model.get('id') %> grid-cell js-grid-cell">
                        <%
                        if (checkBox) {
                        %>
                            <span>
                                <input type="checkbox" class="check-it js-check-it" data-id="<%= model.get('id') %>" <%= checkedAttr %>>
                            </span>
                        <%
                        }
                        %>
                        <span class="js-name col-width-100">
                            <span class="bigtext bold"><%= model.get('name') %></span>
                            <div class="vm-screenshot js-vm-screenshot"> 
                                <%= Wat.CurrentView.getUserStateIcon(model.get('user_state'), model.get('id')) %>
                                <%= Wat.CurrentView.getWarningIcon(model.get('expiration_hard'), model.get('id')) %>

                                <a class="fa fa-plug button js-login-button connect-btn js-connect-btn" data-i18n="Connect"></a>
                            </div>
                            <div class="liltext">
                            <a href="javascript:" data-model-id="<%= model.get('id') %>" class="js-vm-details" data-i18n="[title]Click for details">
                                <i class="fa fa-search"></i>
                                <span class="text" data-model-id="<%= model.get('id') %>" data-i18n="Details"></span>
                            </a>
                            </div>
                            <div class="liltext">
                            <a href="javascript:" data-model-id="<%= model.get('id') %>" data-i18n="[title]Click to configure the connection parameters">
                                <i class="fa fa-wrench" data-model-id="<%= model.get('id') %>"></i>
                                <span class="text" data-model-id="<%= model.get('id') %>" data-i18n="Connection settings"></span>
                            </a>
                            </div>
                        </span>
                    </div>
                <%
                    });
                }
                %>
            </td>
        </tr>
    </tbody>
</table>