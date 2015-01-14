<% _.each(properties, function(val, key) { %>
    <tr>
        <td><i class="fa fa-asterisk"></i><%= key %></td>
        <td>
            <%= val %>
        </td>
    </tr>
<% }); %>