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