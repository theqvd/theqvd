<fieldset class="vms-spy-settings js-vms-spy-settings">
    <legend data-i18n="Settings"></legend>
    <div>
        <span data-i18n="Resolution"></span>
        <select class="js-vms-spy-setting-resolution" class="chosen-single">
            <option value="adapted" data-i18n="Adapted"></option>
            <option value="original" data-i18n="Original"></option>
        </select>
    </div>
    <% if (Wat.C.checkACL('vm.spy.interactive')) { %>
        <div>
            <span data-i18n="Mode"></span>
            <select class="js-vms-spy-setting-mode" class="chosen-single">
                <option value="view_only" data-i18n="View only"></option>
                <option value="interactive" data-i18n="Interactive"></option>
            </select>
        </div>
    <% } %>
    <div>
        <span data-i18n="Log"></span>
        <select class="js-vms-spy-setting-log" class="chosen-single">
            <option value="disabled" data-i18n="Hidden"></option>
            <option value="error" data-i18n="Error">Error</option>
            <option value="warn" data-i18n="Warning">Warning</option>
            <option value="info" data-i18n="Info">Info</option>
            <option value="debug" data-i18n="Debug">Debug</option>
        </select>
    </div>
</fieldset>