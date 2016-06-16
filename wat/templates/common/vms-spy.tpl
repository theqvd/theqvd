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
    <!-- Connection Panel -->
    <div id="noVNC_controls" class="noVNC_controls" class="triangle-right top">
        <ul>
            <li><label><strong>Host: </strong><input id="noVNC_host" value="gotham.qindel.com" /></label></li>
            <li><label><strong>Port: </strong><input id="noVNC_port" value="443" /></label></li>
            <li><label><strong>Password: </strong><input id="noVNC_password" type="password" /></label></li>
            <li><label><strong>Token: </strong><input id="noVNC_token" value="<%= vmId %>" /></label></li>
            <li><label><strong>VM Id: </strong><input id="noVNC_vmId" value="<%= vmId %>" /></label></li>
            <li><label><strong>API Host: </strong><input id="noVNC_apiHost" value="<%= apiHost %>" /></label></li>
            <li><label><strong>API Port: </strong><input id="noVNC_apiPort" value="<%= apiPort %>" /></label></li>
            <li><label><strong>SID: </strong><input id="noVNC_sid" value="<%= sid %>" /></label></li>
            <li><input id="noVNC_connect_button" type="button" value="Connect"></li>
        </ul>
    </div>

</div> <!-- End of noVNC-control-bar -->


<div id="noVNC_screen" class="noVNC_screen">
    <h1 id="noVNC_logo" style="display: none;"><span>no</span><br />VNC</h1>
        
    <!-- HTML5 Canvas -->
    <div id="noVNC_container" class="noVNC_container">
        <canvas id="noVNC_canvas" class="noVNC_canvas" width="0" height="0">
                    Canvas not supported.
        </canvas>
    </div>
</div>
