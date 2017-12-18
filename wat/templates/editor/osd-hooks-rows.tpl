<% if (Object.keys(hooks).length == 0) { %>
    <tr>
        <td class="second_row" data-i18n="No elements found"></td>
    </tr>
<% } %>

<%  $.each(hooks, function (iHook, hook) { %>
    <tr data-form-list="hooks" data-id="<%= hook.id %>" data-hook-name="<%= hook.name %>">
        <td class="col-width-10 center" style="vertical-align: middle;">
            <button class="button2 button-icon--desktop js-button-open-hook-configuration fa fa-pencil" href="javascript:" data-i18n="[title]Edit" data-id="<%= hook.id %>" style="margin: 10px auto;">
            </button>
        </td>
        <td class="col-width-80" style="white-space: normal; font-size: small; text-align: left; vertical-align: middle;">
            <div>
                <%= hook.name %>
            </div>
            <div>
                <span class="second_row" data-i18n="Script">Script</span>: <span><%= scripts[hook.idAsset].get('name') %></span>
            </div>
            <div>
                <span class="second_row" data-i18n="Hook type">Hook type</span>: <span><%= hook.hookType %></span>
            </div>
            <input type="hidden" data-form-field-name="id" value="<%= hook.id %>">
            <input type="hidden" data-form-field-name="name" value="<%= hook.name %>">
        </td>
        <td class="col-width-10" style="vertical-align: middle;">
            <a class="button2 button-icon fa fa-trash js-delete-hook col-width-100 center" data-id="<%= hook.id %>" data-i18n="[title]Delete"></a>
        </td>
    </tr>
<% }) %>