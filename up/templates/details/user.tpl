<div class="details-list-wrapper details-block">
    <div class="h1" data-i18n="Profile"></div>
    <table class="details details-list">
        <tbody>
            <tr>
                <td>
                    <span data-i18n="Name"></span>
                </td>
                <td>
                    <%= model.get('name') %>
                </td>
            </tr>
            <tr>
                <td>
                    <span data-i18n="Connected VMs"></span>
                </td>
                <td>
                    <span data-wsupdate="number_of_vms_connected" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms_connected') %></span>
                    <span>/</span>
                    <span data-wsupdate="number_of_vms" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms') %></span>
                </td>
            </tr>
            <tr>
                <td>
                    <span data-i18n="Blocking"></span>
                </td>
                <td>
                    <%= model.get('blocked') ? $.i18n.t('Blocked') : $.i18n.t('Unblocked') %>
                </td>
            </tr>
            <%
                $.each(model.get('properties'), function (propName, propValue) {
            %>
                <tr>
                    <td>
                        <%= propName %>
                    </td>
                    <td>
                        <%= propValue %>
                    </td>
                </tr>
            <%
                });
            %>
            <tr>
                <td colspan="2">
                        <a class="js-traductable_button actions_button button fa fa-pencil fright" name="selected_actions_button" data-i18n="Change password"></a>
                </td>
            </tr>
        </tbody>
    </table>

</div>