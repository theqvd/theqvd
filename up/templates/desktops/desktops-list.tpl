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
                var connected = model.get('state') == 'connected';
        %>
            <tr class="row-<%= model.get('id') %>">
                <td class="js-name col-width-100">
                    <span class="bigtext bold vm-name"><%= model.get('alias') ? model.get('alias') : model.get('name') %></span>
                    <div class="liltext">
                        <i class="desktop-state js-desktop-state" data-i18n="<%= connected ? 'Connected' : 'Disconnected' %>" data-id="<%= model.get('id') %>"></i>
                    </div>
                </td>
                <td>
                    <a class="<%= CLASS_ICON_CONF_SPECIFIC %> <%= model.get('settings') && model.get('settings_enabled') ? 'button' : 'button2' %> js-vm-settings connect-btn js-connect-btn" data-id="<%= model.get('id') %>" data-i18n="Configure"></a>
                </td>
                <td class="<%= connected ? '' : 'js-list-disconnected' %>">
                    <a class="<%= CLASS_ICON_DESKTOP_CONNECTED %> button2 js-connect-btn connect-btn js-connect-btn <%= connected ? 'disabled' : '' %>" data-id="<%= model.get('id') %>" data-i18n="Connect"></a>
                </td>
            </tr>
        <%
            });
        }
        %>
    </tbody>
</table>