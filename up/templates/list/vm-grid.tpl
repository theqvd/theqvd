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
                                <%
                                if (model.get('user_state') == 'disconnected') {
                                %>
                                    <i class="fa fa-user not-notify state-icon js-state-icon" title="<%= i18n.t('User not connected') %>" data-i18n="[title]User not connected" data-wsupdate="user_state" data-id="<%= model.get('id') %>"></i>
                                <%
                                }
                                else {
                                %>
                                    <i class="fa fa-play ok state-icon js-state-icon" data-i18n="[title]Running" title="<%= i18n.t('Running') %>" data-wsupdate="state" data-id="<%= model.get('id') %>"></i>
                                <%
                                }
                                %>

                                <%
                                if (model.get('expiration_hard')) {
                                %>
                                    <i class="fa fa-warning error warning-icon js-warning-icon" title="<%= i18n.t('The VM will expire') %>" data-i18n="[title]The VM will expire" data-wsupdate="warning_icon" data-id="<%= model.get('id') %>"></i>
                                <%
                                }
                                else {
                                %>
                                    <i class="fa fa-warning not-notify warning-icon js-warning-icon" title="<%= i18n.t('There are not warnings') %>" data-i18n="[title]There are not warnings" data-wsupdate="warning_icon" data-id="<%= model.get('id') %>"></i>
                                <%
                                }
                                %>
                                <a class="fa fa-plug button js-login-button connect-btn js-connect-btn" data-i18n="Connect"></a>
                            </div>
                            <div class="liltext">
                            <a href="#/vm/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                <i class="fa fa-search"></i>
                                <span class="text" data-i18n="Details"></span>
                            </a>
                            </div>
                            <div class="liltext">
                            <a href="#/vm/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                <i class="fa fa-wrench"></i>
                                <span class="text" data-i18n="Connection settings"></span>
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