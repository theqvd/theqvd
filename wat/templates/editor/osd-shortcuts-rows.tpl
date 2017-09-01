<% if (Object.keys(shortcuts).length == 0) { %>
    <tr>
        <td class="second_row" data-i18n="No elements found"></td>
    </tr>
<% } %>

<%
$.each(shortcuts, function (iSc, sc) {
%>
    <tr data-form-list="shortcuts" class="<%= cid %>" data-id="<%= sc.id %>">
        <td class="col-width-10 center">
            <button class="button2 button-icon--desktop js-button-open-shortcut-configuration fa fa-pencil" href="javascript:" data-i18n="[title]Edit" data-id="<%= sc.id %>" style="margin: 10px auto;">
            </button>
            <input type="hidden" data-form-field-name="id" value="<%= sc.id %>">
            <input type="hidden" data-form-field-name="name" value="<%= sc.name %>">
            <input type="hidden" data-form-field-name="command" value="<%= sc.command %>">
            <input type="hidden" data-form-field-name="icon_id" value="<%= sc.icon_id %>">
            <input type="hidden" data-form-field-name="icon_url" value="<%= sc.icon_url %>">
        </td>
        <td class="col-width-10">
            <div class="js-icon-bg icon-bg" data-id="<%= sc.id %>" data-id-asset="<%= sc.idAsset %>" style="background-image: url(<%= sc.icon_url %>); margin: 10px auto;">
                <i class="fa fa-share shortcut"></i>
            </div>
        </td>
        <td class="col-width-70" colspan=2>
            <div><span class="js-shortcut-name" data-id="<%= sc.id %>"><%= sc.name %></div>
            <div class="second_row" data-id="<%= sc.id %>">Command: <span class="js-shortcut-command"><%= sc.code %></span></div>
        </td>
        <td class="col-width-10 center">
            <button class="button2 button-icon--desktop js-delete-shortcut fa fa-trash" href="javascript:" data-i18n="[title]Delete" data-id="<%= sc.id %>" title="Delete"  style="margin: 10px auto;">
            </button>
        </td>
    </tr>
<%
});
%>
