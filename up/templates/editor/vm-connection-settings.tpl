<table class="col-width-100 form-table">
    <tr>
        <td>
            <table class="col-width-100 form-table profile-settings-table">
                <tr>
                    <td>
                        <input class="fleft js-custom-settings-switch" type="radio" name="custom_settings" id="custom_settings_0" value="0" checked>
                        <label for="custom_settings_0" class="select-label fleft"><%= $.i18n.t("Use global profile: __profile__", {profile: "Office"}) %></label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input class="fleft js-custom-settings-switch" type="radio" name="custom_settings" id="custom_settings_1" value="1">
                        <label for="custom_settings_1" class="select-label fleft" data-i18n="Customize settings for this machine"></label>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td class="bb-vm-settings-global vm-settings-global js-vm-settings-global">
        </td>
    </tr>
    <tr>
        <td class="bb-vm-settings-custom vm-settings-custom js-vm-settings-custom" style="display: none;">
        </td>
    </tr>
</table>