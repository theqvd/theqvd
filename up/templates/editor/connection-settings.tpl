<fieldset class="dialog-form">
    <legend data-i18n="VM options" class="left"></legend>
    <table class="col-width-100 form-table">
        <tr>
            <td>
                <input type="checkbox" name="close_session"/>
                <label for="close_session" data-i18n="Close current session"></label>
            </td>
        </tr>
    </table>
</fieldset>

<fieldset class="dialog-form">
    <legend data-i18n="Connection" class="left"></legend>
    <table class="col-width-100 form-table">
        <tr>
            <td colspan="2">
                <label for="type" class="select-label" data-i18n="Type"></label>
                <select name="type">
                    <option value="local">Local</option>
                    <option value="adsl">ADSL</option>
                    <option value="modem">Modem</option>
                </select>
            </td>
        </tr>
        <tr>
            <td>
                <input type="checkbox" name="audio"/>
                <label for="audio" data-i18n="Enable audio"></label>
            </td>
            <td>
                <input type="checkbox" name="printing"/>
                <label for="printing" data-i18n="Enable printing"></label>
            </td>
        </tr>
        <tr>
            <td>
                <input type="checkbox" name="port_forwarding"/>
                <label for="port_forwarding" data-i18n="Enable port forwarding"></label>
            </td>
            <td>
            </td>
        </tr>
    </table>
</fieldset>

<fieldset class="dialog-form">
    <legend data-i18n="Screen" class="left"></legend>
    <table class="col-width-100 form-table">
        <tr>
            <td>
                <input type="checkbox" name="full_screen"/>
                <label for="full_screen" data-i18n="Full screen"></label>
            </td>
        </tr>
    </table>
</fieldset>