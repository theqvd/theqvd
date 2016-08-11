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
                %>
                    <div class="grid-cell js-grid-cell" data-state="<%= model.get('state') %>" data-id="<%= model.get('id') %>">
                        <div class="grid-cell-area js-grid-cell-area js-desktop-connect-btn" data-id="<%= model.get('id') %>">
                            <i class="<%= CLASS_ICON_DESKTOP_CONNECTED %> grid-cell-icon js-grid-cell-icon js-grid-cell-hiddeable" data-id="<%= model.get('id') %>"></i>
                            <div class="corner-image desktop"><img src="images/ladybird_white.png" data-id="<%= model.get('id') %>"></div>
                            <div class="bigtext bold vm-name" data-id="<%= model.get('id') %>"><%= model.get('alias') ? model.get('alias') : model.get('name') %> <br>id: <%= model.get('id') %></div>                            

                            <div class="<%= Math.floor( Math.random() * 2 ) ? "vm-screenshot" : "vm-screenshot-off" %> js-vm-screenshot" data-id="<%= model.get('id') %>">
                            </div>
                        </div>

                        <div class="grid-cell-buttonset">
                            <a href="javascript:" data-id="<%= model.get('id') %>" class="mobile <%= CLASS_ICON_DESKTOP_CONNECTED %> button2 js-desktop-connect-btn desktop-connect-btn button-icon" data-i18n="[title]Connect" data-id="<%= model.get('id') %>"></a>
                            <a href="javascript:" data-id="<%= model.get('id') %>" class="<%= CLASS_ICON_CONF_SPECIFIC %> <%= model.get('settings') && model.get('settings_enabled') ? 'button' : 'button2' %> js-desktop-settings-btn desktop-settings-btn button-icon" data-i18n="[title]Configure connection settings"></a>
                            <i class="desktop-state js-desktop-state" data-i18n="<%= stateString %>" data-id="<%= model.get('id') %>"></i>
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
