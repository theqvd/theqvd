<table class="list col-width-50">
    <tbody>
        <tr>
            <th colspan=2 data-i18n="Connection information"></th>
        </tr>
        <% if (message) { %>
            <tr>
                <td colspan=2 data-i18n="<%= message %>"></td>
            </tr>
        <% } else { %>
            <tr>
                <td data-i18n="Geolocation"></td>
                <td><%= location ? location : '-' %></td>
            </tr>
            <tr>
                <td data-i18n="Browser"></td>
                <td><%= browser ? browser : '-' %></td>
            </tr>
            <tr>
                <td data-i18n="Operative system"></td>
                <td><%= os ? os : '-' %></td>
            </tr>
            <tr>
                <td data-i18n="Connection device"></td>
                <td><%= device ? device : '-' %></td>
            </tr>
        <% } %>
    </tbody>
</table>