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

<fieldset class="dialog-form">
    <legend data-i18n="Default profile" class="left"></legend>
    <select name="connection_profile">
        <% $.each(profiles, function (iProfile, profile) { %>
            <option><%= profile.name %></option>
        <% }); %>
    </select>
</fieldset>
<fieldset class="dialog-form">
    <legend data-i18n="Remembered profile on this device" class="left"></legend>
    <select name="connection_profile_remember">
            <option data-i18n>None</option>
        <% $.each(profiles, function (iProfile, profile) { %>
            <option><%= profile.name %></option>
        <% }); %>
    </select>
    <br>
    <br>
    <i class="fa fa-info-circle info-header"></i><span class="second_row" data-i18n="Remembered profile overrides the default profile"></span>
</fieldset>

<fieldset class="dialog-form">
    <legend data-i18n="Profiles management" class="left"></legend>
    <table class="profile-options">
        <tr>
            <td>
                <table class="list">
                    <tr>
                        <th><span data-i18n="Profile"></th>
                        <th colspan=2><span data-i18n="Actions"></th>
                    </tr>
                <% $.each(profiles, function (profileId, profile) { %>
                    <tr>
                        <td class="col-width-100"><%= profile.name %></td>
                        <td><a class="fa fa-edit button button-icon js-edit-profile" data-i18n="[title]Edit profile" data-profile-id="<%= profileId %>"></a></td>
                        <td><a class="fa fa-trash button button-icon js-delete-profile" data-i18n="[title]Delete profile" data-profile-id="<%= profileId %>"></a></td>
                    </tr>
                <% }); %>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <a class="fa fa-plus-circle button js-new-profile fright" data-i18n="New profile"></a>
            </td>
        </tr>
    </table>
</fieldset>