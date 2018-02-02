<table>
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
                        var stateString = Up.I.getStateString(model.get('state'));
                        var titleString = Up.I.getDesktopTitleString(model.get('state'), model.get('blocked'));
                %>
                    <div class="grid-cell js-grid-cell <%= model.get('blocked') ? 'blocked js-blocked' : 'unblocked js-unblocked' %>" data-state="<%= model.get('state') %>" data-id="<%= model.get('id') %>">
                        <div class="grid-cell-area js-grid-cell-area js-desktop-connect-btn" data-id="<%= model.get('id') %>" data-i18n="[title]<%= titleString %>">
                            <div class="corner-image desktop"><img src="images/ladybird_white.png" data-id="<%= model.get('id') %>"></div>
                            <div class="bigtext bold vm-name" data-id="<%= model.get('id') %>"><%= model.get('alias') ? model.get('alias') : model.get('name') %> <br>id: <%= model.get('id') %></div>
                            
                            <div class="js-vm-screenshot vm-screenshot <%= model.get('state') == 'connected' ? "" : "hidden" %> desktop" data-id="<%= model.get('id') %>" data-state="connected"></div>
                            <div class="js-vm-screenshot vm-screenshot-off <%= model.get('state') == 'connected' ? "hidden" : "" %> desktop" data-id="<%= model.get('id') %>" data-state="disconnected"></div>
                            <% if (!Up.I.isMobile()) { %>
                                <i class="<%= CLASS_ICON_DESKTOP_CONNECT %> grid-cell-icon js-grid-cell-icon js-grid-cell-hiddeable desktop" data-action="connect" data-id="<%= model.get('id') %>"></i>
                                <i class="<%= CLASS_ICON_DESKTOP_RECONNECT %> grid-cell-icon js-grid-cell-icon js-grid-cell-hiddeable desktop" data-action="reconnect" data-id="<%= model.get('id') %>"></i>
                            <% } %>
                            <% if (model.get('blocked')) { %>
                                <i class="<%= CLASS_ICON_DESKTOP_BLOCKED %> grid-cell-blocked-icon desktop" data-id="<%= model.get('id') %>"></i>
                            <% } %>
                        </div>

                        <div class="grid-cell-buttonset">
                            <% if (model.get('blocked')) { %>
                                <i class="<%= CLASS_ICON_DESKTOP_BLOCKED %> grid-cell-blocked-icon mobile" data-id="<%= model.get('id') %>"></i>
                            <% } else { %>
                                <a href="javascript:" data-id="<%= model.get('id') %>" class="mobile <%= CLASS_ICON_DESKTOP_CONNECT %> button2 js-desktop-connect-btn desktop-connect-btn button-icon" data-i18n="[title]Connect" data-id="<%= model.get('id') %>"></a>
                            <% } %>
                            <a href="javascript:" data-id="<%= model.get('id') %>" class="<%= CLASS_ICON_CONF_SPECIFIC %> button2 js-desktop-settings-btn desktop-settings-btn button-icon" data-i18n="[title]Configure connection settings"></a>
                            <i class="desktop-state js-desktop-state" data-i18n="<%= stateString %>" data-id="<%= model.get('id') %>"></i>
                            <i class="desktop-settings-state js-desktop-settings-state <%= model.get('settings') && model.get('settings_enabled') ? '' : 'hidden' %>" data-i18n="Own settings" data-id="<%= model.get('id') %>"></i>
                        </div>
                    </div>
                <%
                    });
                }
                %>
            </td>
        </tr>
    </tbody>
</table>
