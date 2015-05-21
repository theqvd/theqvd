<table>
    <% $.each(affectedVMs, function (iVM, vm) { %>
    <tr>
        <td>
            <input type="checkbox" class="affectedVMCheck" value="<%= vm.id %>" checked>
        </td>
        <td>
            <%= vm.name %>
        </td>
    </tr>
    <% }); %>
</table>