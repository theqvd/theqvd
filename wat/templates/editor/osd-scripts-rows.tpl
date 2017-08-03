<% if (scripts.length == 0) { %>
    <tr class="js-scripts-empty">
        <td class="second_row center" colspan=2 data-i18n="There are no starting scripts">There are no starting scripts</td>
    </tr>
<% } %>
<%  $.each(scripts, function (iScript, script) { %>
    <tr data-form-list="scripts" data-id="<%= script.id %>">
        <td class="col-width-60" style="white-space: normal; font-size: small; text-align: left; vertical-align: middle;">
            <%= script.name %>
        </td>
        <td>
            <input type="hidden" data-form-field-name="id" value="<%= script.id %>">
            <input type="hidden" data-form-field-name="name" value="<%= script.name %>">
            <span class="second_row">
                <%= script.execution_hook %>
            </span>
        </td>
        <td class="col-width-1" style="vertical-align: middle;">
            <a class="button2 button-icon fa fa-trash js-delete-starting-script col-width-100 center" data-id="<%= script.id %>" data-i18n="[title]Delete"></a>
        </td>
    </tr>
<% }) %>
    <tr data-form-list="scripts">
        <td class="col-width-60" style="white-space: normal; font-size: small; text-align: left; vertical-align: middle;">
            <div>
                <select class="js-starting-script bb-os-conf-script-assets" data-form-field-name="execution_hook">
                    <% $.each(availableScripts, function (scriptId, script) { %>
                        <option value="<%= script.get('id') %>"><%= script.get('name') %></option>
                    <% }); %>
                </select>
            </div>
        </td>
        <td>
            <div>
                <select class="js-starting-script-mode bb-os-conf-scripts-type-options" data-form-field-name="execution_hook">
                    <% $.each(hookOptions, function (hookCode, hookName) { %>
                        <option value="<%= hookCode %>"><%= hookName %></option>
                    <% }); %>
                </select>
            </div>
        </td>
        <td class="col-width-1" style="vertical-align: middle;">
            <a class="button2 button-icon fa fa-plus-circle js-add-starting-script col-width-100 center" data-i18n="[title]Add"></a>
        </td>
    </tr>