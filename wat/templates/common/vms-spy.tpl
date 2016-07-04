<div id="noVNC-control-bar" class="noVNC_status_normal">
    <!--noVNC Mobile Device only Buttons-->

    <div id="noVNC_status" class="noVNC_status"></div>
    
    <!-- Popup Status -->
    <div id="noVNC_popup_status" class="">
    </div>

    <!-- Clipboard Panel -->
    <div id="noVNC_clipboard" class="triangle-right top" style="display: none;">
        <textarea id="noVNC_clipboard_text" rows=5>
        </textarea>
        <br />
        <input id="noVNC_clipboard_clear_button" type="button"
            value="Clear">
    </div>

    <!-- XVP Shutdown/Reboot Panel -->
    <div id="noVNC_xvp" class="noVNC_xvp" class="triangle-right top">
        <span id="noVNC_xvp_menu">
            <input type="button" id="xvpShutdownButton" value="Shutdown" />
            <input type="button" id="xvpRebootButton" value="Reboot" />
            <input type="button" id="xvpResetButton" value="Reset" />
        </span>
    </div>

    <!-- Settings Panel -->
    <div id="noVNC_settings" class="noVNC_settings" class="triangle-right top">
        <span id="noVNC_settings_menu">
            <ul>
                <li><input id="noVNC_encrypt" type="checkbox" checked> Encrypt</li>
                <li><input id="noVNC_true_color" type="checkbox" checked> True Color</li>
                <li><input id="noVNC_cursor" type="checkbox"> Local Cursor</li>
                <li><input id="noVNC_clip" type="checkbox"> Clip to Window</li>
                <li><input id="noVNC_shared" type="checkbox"> Shared Mode</li>
                <li><input id="noVNC_view_only" type="checkbox"> View Only</li>
                <hr>
                <li><input id="noVNC_path" type="input" value="vmproxy"> Path</li>
                <li><label>
                    <select id="noVNC_resize" name="vncResize">
                        <option value="off">None</option>
                        <option value="scale" selected>Local Scaling</option>
                        <option value="downscale">Local Downscaling</option>
                        <option value="remote">Remote Resizing</option>
                    </select> Scaling Mode</label>
                </li>
                <li><input id="noVNC_repeaterID" type="input" value=""> Repeater ID</li>
                <hr>
                <!-- Stylesheet selection dropdown -->
                <li><label><strong>Style: </strong>
                    <select id="noVNC_stylesheet" name="vncStyle">
                        <option value="default">default</option>
                    </select></label>
                </li>

                <!-- Logging selection dropdown -->
                <li><label><strong>Logging: </strong>
                    <select id="noVNC_logging" name="vncLogging">
                    </select></label>
                </li>
                <hr>
                <li><input type="button" id="noVNC_apply" value="Apply"></li>
            </ul>
        </span>
    </div>
</div> <!-- End of noVNC-control-bar -->


<input id="noVNC_vmId" type="hidden" value="<%= vmId %>" />
<input id="noVNC_apiHost" type="hidden" value="<%= apiHost %>" />
<input id="noVNC_apiPort" type="hidden" value="<%= apiPort %>" />
<input id="noVNC_sid" type="hidden" value="<%= sid %>" />
    
<div id="noVNC_screen" class="noVNC_screen">
    <%= HTML_LOADING %>
    
    <!-- HTML5 Canvas -->
    <div id="noVNC_container" class="noVNC_container">
        <canvas id="noVNC_canvas" class="noVNC_canvas noVNC_canvas--viewonly" width="0" height="0">
                    Canvas not supported.
        </canvas>
    </div>
</div>

<!-- Settings panel -->
<div class="js-vm-spy-settings-panel {title:'Settings'}">
    <fieldset class="vms-spy-details js-vms-spy-details">
        <legend data-i18n="Details"></legend>
        <div data-i18n="Virtual machine"></div>
        <p class="details-data"><span data-i18n="Name"></span>: <span class="bold"><%= model.get('name') %></span></p>

        <% if (Wat.C.checkACL('vm.see.user') || Wat.C.checkACL('vm.see.user-state')) { %>
            <div data-i18n="User"></div>
            <% if (Wat.C.checkACL('vm.see.user')) { %>
                <p class="details-data"><span data-i18n="Name"></span>: <span class="bold"><%= model.get('user_name') %></span></p>
            <% } %>
            <% if (Wat.C.checkACL('vm.see.user-state')) { %>
                <p class="details-data"><span data-i18n="State"></span>: <span class="bold"><%= model.get('user_state') %></span></p>
            <% } %>
        <% } %>
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
    
    <fieldset class="vms-spy-log js-vms-spy-log">
        <legend data-i18n="Log"></legend>
        <div class="log-registers js-log-registers"></div>
    </fieldset>
</div>
