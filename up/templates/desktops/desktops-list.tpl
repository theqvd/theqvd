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
                var stateString = Up.I.getStateString(model.get('state'));
        %>
                <tr class="row-<%= model.get('id') %> row-desktop js-row-desktop row-<%= model.get('state') %> js-row-<%= model.get('state') %> <%= model.get('blocked') ? 'blocked js-blocked' : 'unblocked js-unblocked' %>" data-id="<%= model.get('id') %>" data-state="<%= model.get('state') %>">
                    <td class="js-name col-width-100">
                        <span class="bigtext bold vm-name"><%= model.get('alias') ? model.get('alias') : model.get('name') %></span>
                        <div class="liltext">
                            <i class="desktop-state js-desktop-state" data-i18n="<%= stateString %>" data-id="<%= model.get('id') %>"></i>
                        </div>
                    </td>
                    <td>
                        <a class="<%= CLASS_ICON_CONF_SPECIFIC %> <%= model.get('settings') && model.get('settings_enabled') ? 'button' : 'button2' %> js-desktop-settings-btn desktop-settings-btn" data-id="<%= model.get('id') %>" data-i18n="Configure"></a>
                    </td>
                    <td class="js-list-<%= model.get('state') %> center">
                        <% if (model.get('blocked')) { %>
                            <i data-i18n="[title]Blocked" class="<%= CLASS_ICON_DESKTOP_BLOCKED %> second_row"></i>
                        <% } else { %>
                            <a class="<%= CLASS_ICON_DESKTOP_CONNECTED %> button2 js-desktop-connect-btn desktop-connect-btn" data-id="<%= model.get('id') %>" data-i18n="Connect"></a>
                        <% } %>
                    </td>
                </tr>
        <%
            });
        }
        %>
    </tbody>
</table>