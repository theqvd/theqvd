<table class="list">
    <tbody>
        <% 
        if (models.length == 0) {
        %>  
            <tr>
                <td colspan="<%= printedColumns %>">
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
                    <%
                    if (model.get('user_state') == 'disconnected') {
                    %>
                        <i class="fa fa-user not-notify" title="<%= i18n.t('User not connected') %>" data-i18n="[title]User not connected" data-wsupdate="user_state" data-id="<%= model.get('id') %>"></i>
                    <%
                    }
                    else {
                    %>
                        <i class="fa fa-play ok" data-i18n="[title]Running" title="<%= i18n.t('Running') %>" data-wsupdate="state" data-id="<%= model.get('id') %>"></i>
                    <%
                    }
                    %>
                    
                    <%
                    if (model.get('expiration_hard')) {
                    %>
                        <i class="fa fa-warning error" title="<%= i18n.t('The VM will expire') %>" data-i18n="[title]The VM will expire" data-wsupdate="warning_icon" data-id="<%= model.get('id') %>"></i>
                    <%
                    }
                    else {
                    %>
                        <i class="fa fa-warning not-notify" title="<%= i18n.t('There are not warnings') %>" data-i18n="[title]There are not warnings" data-wsupdate="warning_icon" data-id="<%= model.get('id') %>"></i>
                    <%
                    }
                    %>
                </td>
                <td class="js-name col-width-100">
                    <span class="bigtext bold"><%= model.get('name') %></span>
                    <div class="liltext">
                    <a href="#/vm/<%= model.get('id') %>" data-i18n="[title]Click for details">
                        <span class="text" data-i18n="Details"></span>
                    </a>
                    |
                    <a href="#/vm/<%= model.get('id') %>" data-i18n="[title]Click for details">
                        <span class="text" data-i18n="Connection settings"></span>
                    </a>
                    </div>
                </td>
                <td>
                    <a class="fa fa-plug button2 js-login-button" data-i18n="Connect"></a>
                </td>
            </tr>
        <%
            });
        }
        %>
    </tbody>
</table>