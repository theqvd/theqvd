<% $.each(collection.models, function (modId, model) { %>
    <tr>
        <td class="cell-link">
            <a href="javascript:" class="js-button-settings-conf" data-id="<%= model.get('id') %>" data-i18n="[title]Edit">
                <%= model.get('name') %>
                <i class="<%= CLASS_ICON_EDIT %> fleft"></i>
            </a>
        </td>
        <% if (model.get('settings') == null) { %>
            <td colspan="3" class="center">
                <span data-i18n="Not configured"></span>
            </td>
        <% } else { %>
            <td>
                <a class="button2 button-icon button-rounded js-clone-workspace-btn <%= CLASS_ICON_CLONE %>" data-id="<%= model.get('id') %>" data-i18n="[title]Clone"></a>
            </td>
            <td><a class="button-icon button-rounded js-active-workspace-btn <%= model.get('active') ? 'button button-active js-button-active' : 'button2 button-activatable js-button-activable' %> <%= CLASS_ICON_ACTIVE %>" data-id="<%= model.get('id') %>" data-i18n="[title]<%= model.get('active') ? 'Active configuration' : 'Set as current configuration' %>"></a></td>
            <td>
                <% if(!model.get('fixed')) { %>
                    <a class="button2 button-icon button-rounded js-delete-workspace-btn <%= CLASS_ICON_DELETE %>" data-id="<%= model.get('id') %>" data-i18n="[title]Delete"></a>
                <% } %>
            </td>
        <% } %>
    </tr>
<% }); %>