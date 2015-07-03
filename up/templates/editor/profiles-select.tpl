<%
    var profiles = {
        1: {
            name: 'Office',
            },
        2: {
            name: 'Home',
            },
        3: {
            name: 'Outdoor (Public network)',
            },
    };
%>




<table class="col-width-100">
    <tr>
        <td>
            <fieldset class="dialog-form">
                <div class="h2" data-i18n="Global connection profile"></div>
                <select name="connection_profile">
                    <% $.each(profiles, function (iProfile, profile) { %>
                        <option><%= profile.name %></option>
                    <% }); %>
                </select>
            </fieldset>
        </td>
    </tr>
    <tr>
        <td>
            <fieldset class="dialog-form">
                <div class="h2" data-i18n="Remembered connection profile on this device"></div>
                <select name="connection_profile_remember">
                        <option data-i18n>None</option>
                    <% $.each(profiles, function (iProfile, profile) { %>
                        <option><%= profile.name %></option>
                    <% }); %>
                </select>
            </fieldset>
        </td>
    </tr>
    <tr>
        <td>
            <div class="info-header">
                <i class="fa fa-info-circle"></i><span class="second_row" data-i18n="Remembered profile overrides the global profile"></span>
            </div>
        </td>
    </tr>
</table>
