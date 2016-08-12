<div class="<%= cid %> section-container">
    <table class="list">
        <tbody>
            <tr>
                <th colspan=2 data-i18n="Connection information"></th>
            </tr>
            <% if (message) { %>
                <tr>
                    <td colspan=2 data-i18n="<%= message %>"></td>
                </tr>
            <% } else { %>
                <% 
                if (location) { 
                    var coordinates = location.split(',');
                    var latitude = coordinates[0];
                    var longitude = coordinates[1];
                %>
                    <tr>
                        <td data-i18n="Geolocation" rowspan=4></td>
                        <td class="center" data-i18n="Coordinates"></td>
                    </tr><tr>
                        <td class="center"><%= location %></td>
                    </tr><tr>
                        <td class="center" data-i18n="Map"></td>
                    </tr><tr>
                        <td class="center">
                            <iframe width="420" height="350" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://www.openlinkmap.org/small.php?lat=<%= latitude %>&lon=<%= longitude %>&zoom=18" style="border: 1px solid black"></iframe>
                        </td>
                    </tr>
                <% } else { %>
                <tr>
                    <td data-i18n="Geolocation"></td>
                    <td>-</td>
                </tr>
                <% } %>
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
</div>