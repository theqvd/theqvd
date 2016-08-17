<div class="<%= cid %> section-container">
    <table class="list">
        <tbody>
            <tr>
                <th colspan=2 data-i18n="Connection information"></th>
            </tr>
            <% if (model.get('message')) { %>
                <tr>
                    <td colspan=2 data-i18n="<%= model.get('message') %>"></td>
                </tr>
            <% } else { %>
                <% 
                if (model.get('location')) {
                %>
                    <tr>
                        <td data-i18n="Geolocation" rowspan=<%= Up.I.isMobile() ? '2' : '4' %>></td>
                        <td><i class="fa fa-compass"></i><span data-i18n="Coordinates"></span></td>
                    </tr>
                    <tr>
                        <td>
                            <div>
                                <span class="geolocation-title"><i data-i18n="Latitude"></i>: </span><%= model.get('latitude') %>
                            </div>
                            <br>
                            <div>
                                <span class="geolocation-title"><i data-i18n="Longitude"></i>: </span><%= model.get('longitude') %>
                            </div>
                        </td>
                    </tr>
                    <tr class="desktop-row">
                        <td><i class="fa fa-map"></i><span data-i18n="Map"></span></td>
                    </tr>
                    <tr class="desktop-row">
                        <td>
                            <iframe width="420" height="350" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://www.openlinkmap.org/small.php?lat=<%= model.get('latitude') %>&lon=<%= model.get('longitude') %>&zoom=16" style="border: 1px solid black"></iframe>
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
                    <td><i class="<%= model.get('browserIcon') %>"></i><%= model.get('browser') ? model.get('browser') : '-' %></td>
                </tr>
                <tr>
                    <td data-i18n="Operative system"></td>
                    <td><i class="<%= model.get('osIcon') %>"></i><%= model.get('os') ? model.get('os') : '-' %></td>
                </tr>
                <tr>
                    <td data-i18n="Device"></td>
                    <td><i class="<%= model.get('deviceIcon') %>"></i><span data-i18n="<%= model.get('device') %>"><%= model.get('device') ? model.get('device') : '-' %></span></td>
                </tr>
            <% } %>
        </tbody>
    </table>
</div>