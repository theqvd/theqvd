<div class="message-container js-message-container">
    <i class="message-close js-message-close fa fa-times-circle"></i>
    <span class="message"></span>
</div>
<input id="noVNC_vmId" type="hidden" value="<%= vmId %>" />
<input id="noVNC_apiHost" type="hidden" value="<%= apiHost %>" />
<input id="noVNC_apiPort" type="hidden" value="<%= apiPort %>" />
<input id="noVNC_token" type="hidden" value="<%= token %>" />
<input id="noVNC_fullScreen" type="hidden" value="<%= fullScreen %>" />
    
<div id="noVNC_screen" class="noVNC_screen">
    <div class="connection-closed"><i class="fa fa-warning" data-i18n="Connection closed"></i></div>
    
    <!-- HTML5 Canvas -->
    <div id="noVNC_container" class="noVNC_container">
        <canvas id="noVNC_canvas" class="noVNC_canvas noVNC_canvas--interactive" width="0" height="0">
                    Canvas not supported.
        </canvas>
    </div>
</div>

<!-- Settings panel -->
<div class="js-vm-spy-settings-panel hidden {title:'Settings'}">
    <fieldset class="vms-spy-details js-vms-spy-details">
        <legend data-i18n="Details"></legend>
        <div data-i18n="Virtual machine"></div>
        <p class="details-data"><span data-i18n="Name"></span>: <span class="bold"><%= model.get('name') %></span></p>

        <% //if (Wat.C.checkACL('vm.see.user') || Wat.C.checkACL('vm.see.user-state')) { %>
            <div data-i18n="User"></div>
            <% //if (Wat.C.checkACL('vm.see.user')) { %>
                <p class="details-data"><span data-i18n="Name"></span>: <span class="bold"><%= model.get('user_name') %></span></p>
            <% //} %>
            <% //if (Wat.C.checkACL('vm.see.user-state')) { %>
                <p class="details-data"><span data-i18n="State"></span>: <span class="bold"><%= model.get('user_state') %></span></p>
            <% //} %>
        <% //} %>
    </fieldset>

    <fieldset class="vms-spy-settings js-vms-spy-settings">
        <legend data-i18n="Settings"></legend>
        <div>
            <span data-i18n="Resolution"></span>
            <select class="js-vms-spy-setting-resolution" class="chosen-single">
                <option value="adapted" data-i18n="Adapted"></option>
                <option value="original" data-i18n="Original"></option>
            </select>
        </div>
        <% //if (Wat.C.checkACL('vm.spy.interactive')) { %>
            <div>
                <span data-i18n="Mode"></span>
                <select class="js-vms-spy-setting-mode" class="chosen-single">
                    <option value="view_only" data-i18n="View only"></option>
                    <option value="interactive" data-i18n="Interactive"></option>
                </select>
            </div>
        <% //} %>
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
        <div class="mobile">
            <span data-i18n="Keyboard"></span>
            <a class="button fa fa-keyboard-o js-vnc-keyboard col-width-100" data-i18n="Show"></a>
        </div>
    </fieldset>
    
    <fieldset class="vms-spy-log js-vms-spy-log">
        <legend data-i18n="Log"></legend>
        <div class="log-registers js-log-registers"></div>
    </fieldset>
</div>

<!-- Invisible input to show keyboard on mobile devices using focus trick -->
<input type="text" id="kbi" class="out-of-borders invisible-box hidden"></input>
