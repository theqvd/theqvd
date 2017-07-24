<%
$.each(shortcuts, function (iSc, sc) {
    sc.id = btoa(sc.command); // Just mock
%>
    <tr data-form-list="shortcuts" class="js-shortcut-row <%= cid %>" data-id="<%= sc.id %>">
        <td class="col-width-5">
            <button class="button2 fright button-icon--desktop js-button-show-shortcut-details fa fa-chevron-down" href="javascript:" data-i18n="[title]Edit" data-id="<%= sc.id %>">
            </button>
            <input type="hidden" data-form-field-name="id" value="<%= sc.id %>">
            <input type="hidden" data-form-field-name="name" value="<%= sc.name %>">
            <input type="hidden" data-form-field-name="command" value="<%= sc.command %>">
            <input type="hidden" data-form-field-name="icon_id" value="<%= sc.icon_id %>">
            <input type="hidden" data-form-field-name="icon_url" value="<%= sc.icon_url %>">
        </td>
        <td class="col-width-5">
            <div class="icon-bg" data-id="<%= sc.id %>" style="background-image: url(<%= sc.icon_url %>)">
                <i class="fa fa-share shortcut"></i>
            </div>
        </td>
        <td class="col-width-80" colspan=2>
            <div><span class="js-shortcut-name"><%= sc.name %></div>
            <div class="second_row">Command: <span class="js-shortcut-command"><%= sc.command %></span></div>
        </td>
        <td class="col-width-5">
            <button class="button2 fright button-icon--desktop js-delete-shortcut fa fa-trash" href="javascript:" data-i18n="[title]Delete" data-id="<%= sc.id %>" title="Delete">
            </button>
        </td>
    </tr>
    <tr class="hidden js-editor-row <%= cid %>" data-id="<%= sc.id %>">
        <td colspan="4">
            <table class="col-width-100">
                <tr>
                    <td>
                        Name
                    </td>
                    <td>
                        <input type="text" name="shortcut_name" value="<%= sc.name %>" data-id="<%= sc.id %>"></input>
                    </td>
                </tr>
                <tr>
                    <td>
                        Command
                    </td>
                    <td>
                        <input type="text" name="shortcut_command" value="<%= sc.command %>" data-id="<%= sc.id %>"></input>
                    </td>
                </tr>
                <tr>
                    <td>
                        Icon
                    </td>
                    <td>
                        <input type="text" name="shortcut_icon" value="<%= sc.icon_url %>" data-id="<%= sc.id %>"></input>
                    </td>
                </tr>
                <tr>
                    <td colspan=2 class="right">
                        <button class="button2 fa fa-save js-update-shortcut" data-id="<%= sc.id %>" data-i18n="Update"></button>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
<%
    delete sc.id; // Just mock
});
%>