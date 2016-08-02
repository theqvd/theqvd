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
                        var connected = model.get('state') == 'running';
                %>
                    <div class="grid-cell js-grid-cell <%= connected ? 'grid-connected js-grid-connected' : 'grid-disconnected js-grid-disconnected' %>" data-state="<%= connected ? 'connected' : 'disconnected' %>"" data-id="<%= model.get('id') %>">
                        <div class="grid-cell-area js-grid-cell-area js-connect-btn" data-id="<%= model.get('id') %>" <%= connected ? '' : 'data-i18n="[title]Connect"' %>>
                            <i class="<%= CLASS_ICON_DESKTOP_CONNECTED %> grid-cell-icon js-grid-cell-icon js-grid-cell-hiddeable" data-id="<%= model.get('id') %>"></i>
                            <div class="corner-image"><img src="images/ladybird_white.png" data-id="<%= model.get('id') %>"></div>
                            <div class="bigtext bold vm-name" data-id="<%= model.get('id') %>"><%= model.get('name') %> <br>id: <%= model.get('id') %></div>                            

                            <div class="<%= Math.floor( Math.random() * 2 ) ? "vm-screenshot" : "vm-screenshot-off" %> js-vm-screenshot" data-id="<%= model.get('id') %>">
                            </div>
                        </div>

                        <div class="grid-cell-buttonset">
                            <a href="javascript:" data-id="<%= model.get('id') %>" class="<%= CLASS_ICON_CONF_SPECIFIC %> js-vm-settings vm-link-button button2 button-icon" data-i18n="[title]Configure connection settings"></a>
                            <i class="desktop-state js-desktop-state" data-i18n="<%= connected ? 'Connected' : 'Disconnected' %>" data-id="<%= model.get('id') %>" style="position: absolute; bottom: 10px; right: 10px;"></i>
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
