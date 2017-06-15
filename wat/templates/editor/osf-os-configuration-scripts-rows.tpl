<%  $.each(scripts, function (iScript, script) { %>
    <tr data-form-list="scripts" data-id="<%= script.id %>">
        <td class="col-width-60" style="white-space: normal; font-size: small; text-align: left; vertical-align: middle;">
            <%= script.name %>
            <input type="hidden" data-form-field-name="id" value="<%= script.id %>">
            <input type="hidden" data-form-field-name="name" value="<%= script.name %>">
        </td>
        <td class="col-width-20">
            <select class="js-starting-script-mode" data-filename="<%= script.name %>"  data-id="<%= script.id %>" data-form-field-name="execution_hook">
                <option value="first_connection" <%= script.execution_hook == 'first_connection' ? 'selected="selected"' : '' %>>In any session starting</option>
                <option value="vma.on_state.connected" <%= script.execution_hook == 'vma.on_state.connected' ? 'selected="selected"' : '' %>>Only first session starting</option>
                <option value="vma.on_state.expire" <%= script.execution_hook == 'vma.on_state.expire' ? 'selected="selected"' : '' %>>On expiration</option>
            </select>
        </td>
        <td class="col-width-20">
            <a class="button2 fa fa-trash js-delete-starting-script col-width-100 center" data-id="<%= script.id %>" data-i18n="Delete"></a>
        </td>
    </tr>
<% }) %>