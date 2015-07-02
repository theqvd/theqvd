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
    </table>
</fieldset>