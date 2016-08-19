<table class="list settings-list-table col-width-99">
    <tbody>
        <% if(!model.get('active')) { %>
            <tr>
                <td class="cell-link">
                        <a href="javascript:" class="js-active-workspace-btn js-button-activable <%= CLASS_ICON_ACTIVE %>" data-id="<%= model.get('id') %>" data-i18n="Activate"></a>
                </td>
            </tr>
        <% } %>
        <tr>
            <td class="cell-link">
                    <a href="javascript:" class="js-button-settings-conf <%= CLASS_ICON_EDIT %>" data-id="<%= model.get('id') %>" data-i18n="Edit"></a>
            </td>
        </tr>
        <tr>
            <td class="cell-link">
                    <a href="javascript:" class="js-clone-workspace-btn <%= CLASS_ICON_CLONE %>" data-id="<%= model.get('id') %>" data-i18n="Clone"></a>
            </td>
        </tr>
        <% if(!model.get('fixed')) { %>
            <tr>
                <td class="cell-link">
                        <a href="javascript:" class="js-delete-workspace-btn <%= CLASS_ICON_DELETE %>" data-id="<%= model.get('id') %>" data-i18n="Delete"></a>
                </td>
            </tr>
        <% } %>
    </tbody>
</table>

<a class="button2 <%= CLASS_ICON_BACK %> mobile mobile-action-button js-back-settings-button" data-i18n="Back">