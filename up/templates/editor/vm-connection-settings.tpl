<table class="list settings-table">
    <tbody>
        <tr>
            <td>
                <label for="close_session" data-i18n="Close current session in next connection"></label>
            </td>
            <td>
                <input type="checkbox" name="close_session"/>
            </td>
        </tr>
        <tr>
            <td colspan=2>
                <select name="custom_settings" class="js-custom-settings-switch">
                    <option value="global"><%= $.i18n.t("Inherit global profile (__profile__)", {profile: "Office"}) %></option>
                    <option data-i18n="Customize settings for this machine" value="custom"></option>
                </select>
            </td>
        </tr>
    </tbody>
    <tbody class="bb-vm-settings-global vm-settings-global js-vm-settings-global">
    <tbody class="bb-vm-settings-custom vm-settings-custom js-vm-settings-custom" style="display: none;">
</table>