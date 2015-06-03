<% if (model.get('expiration_hard')) { %>
    <fieldset class="dialog-form">
        <legend data-i18n="Expiration" class="left"></legend>
        <table class="col-width-100 form-table">
            <tr>
                <td>
                    <i class="fa fa-warning error"></i>
                    <span data-i18n="Virtual machine is going to expire at the following date"></span>:
                </td>
            </tr>
            <tr>
                <td class="center">
                    <%= model.get('expiration_hard').replace('T',' ') %>
                </td>
            </tr>
            <tr>
                <td class="right">
                    <a class="js-traductable_button actions_button button fa fa-refresh fright js-reboot-vm" name="reboot-vm-btn" data-i18n="Reboot VM"></a>
                </td>
            </tr>
        </table>
    </fieldset>
<% } %>

<% if (model.get('user_state') == 'hanged') { %>
    <fieldset class="dialog-form">
        <legend data-i18n="Session" class="left"></legend>
        <table class="col-width-100 form-table">
            <tr>
                <td>
                    <i class="fa fa-user error"></i>
                    <span data-i18n="Session is opened but user is disconnected"></span>
                </td>
            </tr>
            <tr>
                <td class="right">
                    <a class="js-traductable_button actions_button button fa fa-sign-out fright js-force-disconnection" name="force-disconnection-btn" data-i18n="Force disconnection"></a>
                </td>
            </tr>
        </table>
    </fieldset>
<% } %>