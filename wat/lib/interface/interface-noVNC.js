/*
 * noVNC: HTML5 VNC client
 * Copyright (C) 2012 Joel Martin
 * Copyright (C) 2015 Samuel Mannehed for Cendio AB
 * Licensed under MPL 2.0 (see LICENSE.txt)
 *
 * See README.md for usage and integration instructions.
 */

/* jslint white: false, browser: true */
/* global window, $D, Util, WebUtil, RFB, Display */

var UI;

(function () {
    "use strict";

    // Load supporting scripts
    window.onscriptsload = function () { UI.load(); };
    Util.load_scripts(["webutil.js", "base64.js", "websock.js", "des.js",
                       "keysymdef.js", "keyboard.js", "input.js", "display.js",
                       "rfb.js", "keysym.js", "inflator.js"]);

    UI = {

        rfb_state: 'loaded',

        resizeTimeout: null,
        popupStatusTimeout: null,
        hideKeyboardTimeout: null,

        settingsOpen: false,
        connSettingsOpen: false,
        clipboardOpen: false,
        keyboardVisible: false,

        isTouchDevice: false,
        isSafari: false,
        rememberedClipSetting: null,
        lastKeyboardinput: null,
        defaultKeyboardinputLen: 100,

        shiftDown: false,
        ctrlDown: false,
        altDown: false,
        altGrDown: false,

        // Setup rfb object, load settings from browser storage, then call
        // UI.init to setup the UI/menus
        load: function (callback) {
            WebUtil.initSettings(UI.start, callback);
        },

        // Render default UI and initialize settings menu
        start: function(callback) {
            return;
            UI.isTouchDevice = 'ontouchstart' in document.documentElement;

            // Stylesheet selection dropdown
            var sheet = WebUtil.selectStylesheet();
            var sheets = WebUtil.getStylesheets();
            var i;
            for (i = 0; i < sheets.length; i += 1) {
                UI.addOption($D('noVNC_stylesheet'),sheets[i].title, sheets[i].title);
            }

            // Logging selection dropdown
            var llevels = ['error', 'warn', 'info', 'debug'];
            for (i = 0; i < llevels.length; i += 1) {
                UI.addOption($D('noVNC_logging'),llevels[i], llevels[i]);
            }

            // Settings with immediate effects
            UI.initSetting('logging', 'warn');
            WebUtil.init_logging(UI.getSetting('logging'));

            UI.initSetting('stylesheet', 'default');
            WebUtil.selectStylesheet(null);
            // call twice to get around webkit bug
            WebUtil.selectStylesheet(UI.getSetting('stylesheet'));

            // if port == 80 (or 443) then it won't be present and should be
            // set manually
            var port = window.location.port;
            if (!port) {
                if (window.location.protocol.substring(0,5) == 'https') {
                    port = 443;
                }
                else if (window.location.protocol.substring(0,4) == 'http') {
                    port = 80;
                }
            }

            /* Populate the controls if defaults are provided in the URL */
            UI.initSetting('host', window.location.hostname);
            UI.initSetting('port', port);
            UI.initSetting('password', '');
            UI.initSetting('encrypt', (window.location.protocol === "https:"));
            UI.initSetting('true_color', true);
            UI.initSetting('cursor', !UI.isTouchDevice);
            UI.initSetting('resize', 'off');
            UI.initSetting('shared', true);
            UI.initSetting('view_only', false);
            UI.initSetting('path', 'websockify');
            UI.initSetting('repeaterID', '');
            UI.initSetting('token', '');

            var autoconnect = WebUtil.getConfigVar('autoconnect', false);
            if (autoconnect === 'true' || autoconnect == '1') {
                autoconnect = true;
                UI.connect();
            } else {
                autoconnect = false;
            }

            UI.updateVisualState();

            $D('noVNC_host').focus();

            // Show mouse selector buttons on touch screen devices
            if (UI.isTouchDevice) {
                UI.setMouseButton();
                // Remove the address bar
                setTimeout(function() { window.scrollTo(0, 1); }, 100);
                UI.forceSetting('clip', true);
            } else {
                UI.initSetting('clip', false);
            }

            UI.setViewClip();
            UI.setBarPosition();

            Util.addEvent(window, 'resize', function () {
                UI.onresize();
                UI.setViewClip();
                UI.updateViewDrag();
                UI.setBarPosition();
            } );

            UI.isSafari = (navigator.userAgent.indexOf('Safari') != -1 &&
                           navigator.userAgent.indexOf('Chrome') == -1);

            // Only show the button if fullscreen is properly supported
            // * Safari doesn't support alphanumerical input while in fullscreen
            if (!UI.isSafari &&
                (document.documentElement.requestFullscreen ||
                 document.documentElement.mozRequestFullScreen ||
                 document.documentElement.webkitRequestFullscreen ||
                 document.body.msRequestFullscreen)) {

                Util.addEvent(window, 'fullscreenchange', UI.updateFullscreenButton);
                Util.addEvent(window, 'mozfullscreenchange', UI.updateFullscreenButton);
                Util.addEvent(window, 'webkitfullscreenchange', UI.updateFullscreenButton);
                Util.addEvent(window, 'msfullscreenchange', UI.updateFullscreenButton);
            }

            Util.addEvent(window, 'load', UI.keyboardinputReset);

            Util.addEvent(window, 'beforeunload', function () {
                if (UI.rfb && UI.rfb_state === 'normal') {
                    return "You are currently connected.";
                }
            } );

            // Show description by default when hosted at for kanaka.github.com
            if (location.host === "kanaka.github.io") {
                // Open the description dialog
            } else {
                // Show the connect panel on first load unless autoconnecting
                if (autoconnect === UI.connSettingsOpen) {
                    UI.toggleConnectPanel();
                }
            }

            // Add mouse event click/focus/blur event handlers to the UI
            UI.addMouseHandlers();

            if (typeof callback === "function") {
                callback(UI.rfb);
            }
        },

        initRFB: function () {
            try {
                UI.rfb = new RFB({'target': $D('noVNC_canvas'),
                                  'onUpdateState': UI.updateState,
                                  'onXvpInit': UI.updateXvpVisualState,
                                  'onClipboard': UI.clipReceive,
                                  'onFBUComplete': UI.FBUComplete,
                                  'onFBResize': UI.updateViewDragClient,
                                  'onDesktopName': UI.updateDocumentTitle});
                return true;
            } catch (exc) {
                UI.updateState(null, 'fatal', null, 'Unable to create RFB client -- ' + exc);
                return false;
            }
        },

        addMouseHandlers: function() {
        },

        onresize: function (callback) {
            setTimeout(function () {
                var w = window.innerWidth;
                var h = window.innerHeight*0.99;
                w = h * 1.5;
                                
                var display = UI.rfb.get_display();
                
                var scaleRatio = display.autoscale(w,h,false);
                UI.rfb.get_mouse().set_scale(scaleRatio);
            }, 100);

        },
        
        setClientResolution: function () {
            var clientResolution = UI.getClientResolution();
            
            var w = clientResolution.width;
            var h = clientResolution.height;
            
            var display = UI.rfb.get_display();
            var scaleRatio = display.autoscale(w,h,false);
            UI.rfb.get_mouse().set_scale(scaleRatio);
        },

        getCanvasLimit: function () {
            var container = $D('noVNC_container');

            // Hide the scrollbars until the size is calculated
            container.style.overflow = "hidden";

            var pos = Util.getPosition(container);
            var w = pos.width;
            var h = pos.height;
            
            container.style.overflow = "visible";

            if (isNaN(w) || isNaN(h)) {
                return false;
            } else {
                return {w: w, h: h};
            }
        },

        // Read form control compatible setting from cookie
        getSetting: function(name) {
            var ctrl = $D('noVNC_' + name);
            var val = WebUtil.readSetting(name);
            if (typeof val !== 'undefined' && val !== null && ctrl.type === 'checkbox') {
                if (val.toString().toLowerCase() in {'0':1, 'no':1, 'false':1}) {
                    val = false;
                } else {
                    val = true;
                }
            }
            return val;
        },

        // Update cookie and form control setting. If value is not set, then
        // updates from control to current cookie setting.
        updateSetting: function(name, value) {

            // Save the cookie for this session
            if (typeof value !== 'undefined') {
                WebUtil.writeSetting(name, value);
            }

            // Update the settings control
            value = UI.getSetting(name);

            var ctrl = $D('noVNC_' + name);
            if (ctrl.type === 'checkbox') {
                ctrl.checked = value;

            } else if (typeof ctrl.options !== 'undefined') {
                for (var i = 0; i < ctrl.options.length; i += 1) {
                    if (ctrl.options[i].value === value) {
                        ctrl.selectedIndex = i;
                        break;
                    }
                }
            } else {
                /*Weird IE9 error leads to 'null' appearring
                in textboxes instead of ''.*/
                if (value === null) {
                    value = "";
                }
                ctrl.value = value;
            }
        },

        // Save control setting to cookie
        saveSetting: function(name) {
            var val, ctrl = $D('noVNC_' + name);
            if (ctrl.type === 'checkbox') {
                val = ctrl.checked;
            } else if (typeof ctrl.options !== 'undefined') {
                val = ctrl.options[ctrl.selectedIndex].value;
            } else {
                val = ctrl.value;
            }
            WebUtil.writeSetting(name, val);
            //Util.Debug("Setting saved '" + name + "=" + val + "'");
            return val;
        },

        // Initial page load read/initialization of settings
        initSetting: function(name, defVal) {
            // Check Query string followed by cookie
            var val = WebUtil.getConfigVar(name);
            if (val === null) {
                val = WebUtil.readSetting(name, defVal);
            }
            UI.updateSetting(name, val);
            return val;
        },

        // Force a setting to be a certain value
        forceSetting: function(name, val) {
            UI.updateSetting(name, val);
            return val;
        },


        // Show the popup status
        togglePopupStatus: function(text) {
            var psp = $D('noVNC_popup_status');

            var closePopup = function() { psp.style.display = "none"; };

            if (window.getComputedStyle(psp).display === 'none') {
                if (typeof text === 'string') {
                    psp.innerHTML = text;
                } else {
                    psp.innerHTML = $D('noVNC_status').innerHTML;
                }
                psp.style.display = "block";
                psp.style.left = window.innerWidth/2 -
                    parseInt(window.getComputedStyle(psp).width)/2 -30 + "px";

                // Show the popup for a maximum of 1.5 seconds
                UI.popupStatusTimeout = setTimeout(function() { closePopup(); }, 1500);
            } else {
                clearTimeout(UI.popupStatusTimeout);
                closePopup();
            }
        },

        // Show the XVP panel
        toggleXvpPanel: function() {
            // Close the description panel
            // Close settings if open
            if (UI.settingsOpen === true) {
                UI.settingsApply();
                UI.closeSettingsMenu();
            }
            // Close connection settings if open
            if (UI.connSettingsOpen === true) {
                UI.toggleConnectPanel();
            }
            // Close clipboard panel if open
            if (UI.clipboardOpen === true) {
                UI.toggleClipboardPanel();
            }
            // Toggle XVP panel
            if (UI.xvpOpen === true) {
                UI.xvpOpen = false;
            } else {
                UI.xvpOpen = true;
            }
        },

        // Show the clipboard panel
        toggleClipboardPanel: function() {
            // Close the description panel
            // Close settings if open
            if (UI.settingsOpen === true) {
                UI.settingsApply();
                UI.closeSettingsMenu();
            }
            // Close connection settings if open
            if (UI.connSettingsOpen === true) {
                UI.toggleConnectPanel();
            }
            // Close XVP panel if open
            if (UI.xvpOpen === true) {
                UI.toggleXvpPanel();
            }
            // Toggle Clipboard Panel
            if (UI.clipboardOpen === true) {
                UI.clipboardOpen = false;
            } else {
                UI.clipboardOpen = true;
            }
        },

        // Toggle fullscreen mode
        toggleFullscreen: function() {
            if (document.fullscreenElement || // alternative standard method
                document.mozFullScreenElement || // currently working methods
                document.webkitFullscreenElement ||
                document.msFullscreenElement) {
                if (document.exitFullscreen) {
                    document.exitFullscreen();
                } else if (document.mozCancelFullScreen) {
                    document.mozCancelFullScreen();
                } else if (document.webkitExitFullscreen) {
                    document.webkitExitFullscreen();
                } else if (document.msExitFullscreen) {
                    document.msExitFullscreen();
                }
            } else {
                if (document.documentElement.requestFullscreen) {
                    document.documentElement.requestFullscreen();
                } else if (document.documentElement.mozRequestFullScreen) {
                    document.documentElement.mozRequestFullScreen();
                } else if (document.documentElement.webkitRequestFullscreen) {
                    document.documentElement.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
                } else if (document.body.msRequestFullscreen) {
                    document.body.msRequestFullscreen();
                }
            }
            UI.enableDisableViewClip();
            UI.updateFullscreenButton();
        },

        updateFullscreenButton: function() {
            if (document.fullscreenElement || // alternative standard method
                document.mozFullScreenElement || // currently working methods
                document.webkitFullscreenElement ||
                document.msFullscreenElement ) {
                //$D('fullscreenButton').className = "noVNC_status_button_selected";
            } else {
                //$D('fullscreenButton').className = "noVNC_status_button";
            }
        },

        // Show the connection settings panel/menu
        toggleConnectPanel: function() {
            // Close the description panel
            // Close connection settings if open
            if (UI.settingsOpen === true) {
                UI.settingsApply();
                UI.closeSettingsMenu();
            }
            // Close clipboard panel if open
            if (UI.clipboardOpen === true) {
                UI.toggleClipboardPanel();
            }
            // Close XVP panel if open
            if (UI.xvpOpen === true) {
                UI.toggleXvpPanel();
            }

            // Toggle Connection Panel
            if (UI.connSettingsOpen === true) {
                UI.connSettingsOpen = false;
                UI.saveSetting('host');
                UI.saveSetting('port');
                UI.saveSetting('token');
                //UI.saveSetting('password');
            } else {
                UI.connSettingsOpen = true;
            }
        },

        // Toggle the settings menu:
        //   On open, settings are refreshed from saved cookies.
        //   On close, settings are applied
        toggleSettingsPanel: function() {
            // Close the description panel
            if (UI.settingsOpen) {
                UI.settingsApply();
                UI.closeSettingsMenu();
            } else {
                UI.updateSetting('encrypt');
                UI.updateSetting('true_color');
                if (Util.browserSupportsCursorURIs()) {
                    UI.updateSetting('cursor');
                } else {
                    UI.updateSetting('cursor', !UI.isTouchDevice);
                }
                UI.updateSetting('clip');
                UI.updateSetting('resize');
                UI.updateSetting('shared');
                UI.updateSetting('view_only');
                UI.updateSetting('path');
                UI.updateSetting('repeaterID');
                UI.updateSetting('stylesheet');
                UI.updateSetting('logging');

                UI.openSettingsMenu();
            }
        },

        // Open menu
        openSettingsMenu: function() {
            // Close the description panel
            // Close clipboard panel if open
            if (UI.clipboardOpen === true) {
                UI.toggleClipboardPanel();
            }
            // Close connection settings if open
            if (UI.connSettingsOpen === true) {
                UI.toggleConnectPanel();
            }
            // Close XVP panel if open
            if (UI.xvpOpen === true) {
                UI.toggleXvpPanel();
            }
            UI.settingsOpen = true;
        },

        // Close menu (without applying settings)
        closeSettingsMenu: function() {
            $D('noVNC_settings').style.display = "none";
            $D('settingsButton').className = "noVNC_status_button";
            UI.settingsOpen = false;
        },

        // Save/apply settings when 'Apply' button is pressed
        settingsApply: function() {
            //Util.Debug(">> settingsApply");
            UI.saveSetting('encrypt');
            UI.saveSetting('true_color');
            if (Util.browserSupportsCursorURIs()) {
                UI.saveSetting('cursor');
            }

            UI.saveSetting('resize');

            if (UI.getSetting('resize') === 'downscale' || UI.getSetting('resize') === 'scale') {
                UI.forceSetting('clip', false);
            }

            UI.saveSetting('clip');
            UI.saveSetting('shared');
            UI.saveSetting('view_only');
            UI.saveSetting('path');
            UI.saveSetting('repeaterID');
            UI.saveSetting('stylesheet');
            UI.saveSetting('logging');

            // Settings with immediate (non-connected related) effect
            WebUtil.selectStylesheet(UI.getSetting('stylesheet'));
            WebUtil.init_logging(UI.getSetting('logging'));
            UI.setViewClip();
            UI.updateViewDrag();
            //Util.Debug("<< settingsApply");
        },



        setPassword: function() {
            UI.rfb.sendPassword($D('noVNC_password').value);
            //Reset connect button.
            $D('noVNC_connect_button').value = "Connect";
            $D('noVNC_connect_button').onclick = UI.connect;
            //Hide connection panel.
            UI.toggleConnectPanel();
            return false;
        },

        sendCtrlAltDel: function() {
            UI.rfb.sendCtrlAltDel();
        },

        xvpShutdown: function() {
            UI.rfb.xvpShutdown();
        },

        xvpReboot: function() {
            UI.rfb.xvpReboot();
        },

        xvpReset: function() {
            UI.rfb.xvpReset();
        },

        setMouseButton: function(num) {
            if (typeof num === 'undefined') {
                // Disable mouse buttons
                num = -1;
            }
            if (UI.rfb) {
                UI.rfb.get_mouse().set_touchButton(num);
            }
        },

        updateState: function(rfb, state, oldstate, msg) {
            if (state == 'normal') {
                $('.noVNC_screen .loading').hide();
            }
            
            UI.log("INFO", "STATE: " + state + " - " + msg);

            UI.updateVisualState();
        },
        
        log: function (state, msg) {
            var now = new Date();
            
            var logMsg = now.toLocaleString() + " - [" + state + "]";
            if (msg != undefined) {
                logMsg += " - " + msg;
            }
            
            var lineClass = '';
            
            switch (state) {
                case 'DEBUG':
                case 'INFO':
                case 'WARN':
                case 'ERROR':
                    lineClass = "js-log-line-" + state.toLowerCase() + " log-line-" + state.toLowerCase();
            }
            
            $('.vms-spy-log .log-registers').prepend('<p class="' + lineClass + '">' + logMsg + '</p>');
        },

        // Disable/enable controls depending on connection state
        updateVisualState: function() {
        },

        // Disable/enable XVP button
        updateXvpVisualState: function(ver) {
            if (ver >= 1) {
            } else {
                // Close XVP panel if open
                if (UI.xvpOpen === true) {
                    UI.toggleXvpPanel();
                }
            }
        },

        // This resize can not be done until we know from the first Frame Buffer Update
        // if it is supported or not.
        // The resize is needed to make sure the server desktop size is updated to the
        // corresponding size of the current local window when reconnecting to an
        // existing session.
        FBUComplete: function(rfb, fbu) {
            UI.onresize();
            UI.rfb.set_onFBUComplete(function() { });
        },

        // Display the desktop name in the document title
        updateDocumentTitle: function(rfb, name) {
            $('.ui-dialog-titlebar').html($('.ui-dialog-titlebar').html() + ' - ' + name);
        },

        clipReceive: function(rfb, text) {
            Util.Debug(">> UI.clipReceive: " + text.substr(0,40) + "...");
            $D('noVNC_clipboard_text').value = text;
            Util.Debug("<< UI.clipReceive");
        },

        connect: function() {
            var password = '';
            var vmId = $('#noVNC_vmId').val();
            var apiHost = $('#noVNC_apiHost').val();
            var apiPort = $('#noVNC_apiPort').val();
            var sid = $('#noVNC_sid').val();

            var path = 'vmproxy?sid=' + sid + '&arguments={"vm_id":"' + vmId + '"}';

            if (!UI.initRFB()) return;

            UI.rfb.set_encrypt(true);
            UI.rfb.set_true_color(true);
            UI.rfb.set_local_cursor(UI.getSetting('cursor'));
            UI.rfb.set_shared(UI.getSetting('shared'));
            UI.rfb.set_view_only(true);
            UI.rfb.set_repeaterID(UI.getSetting('repeaterID'));

            UI.rfb.connect(apiHost, apiPort, password, path);
        },

        disconnect: function() {
            UI.closeSettingsMenu();
            UI.rfb.disconnect();

            // Restore the callback used for initial resize
            UI.rfb.set_onFBUComplete(UI.FBUComplete);
        },

        displayBlur: function() {
            if (!UI.rfb) return;

            UI.rfb.get_keyboard().set_focused(false);
            UI.rfb.get_mouse().set_focused(false);
        },

        displayFocus: function() {
            if (!UI.rfb) return;

            UI.rfb.get_keyboard().set_focused(true);
            UI.rfb.get_mouse().set_focused(true);
        },

        clipClear: function() {
            $D('noVNC_clipboard_text').value = "";
            UI.rfb.clipboardPasteFrom("");
        },

        clipSend: function() {
            var text = $D('noVNC_clipboard_text').value;
            Util.Debug(">> UI.clipSend: " + text.substr(0,40) + "...");
            UI.rfb.clipboardPasteFrom(text);
            Util.Debug("<< UI.clipSend");
        },

        // Set and configure viewport clipping
        setViewClip: function(clip) {
            var display;
            if (UI.rfb) {
                display = UI.rfb.get_display();
            } else {
                UI.forceSetting('clip', clip);
                return;
            }

            var cur_clip = display.get_viewport();

            if (typeof(clip) !== 'boolean') {
                // Use current setting
                clip = UI.getSetting('clip');
            }

            if (clip && !cur_clip) {
                // Turn clipping on
                UI.updateSetting('clip', true);
            } else if (!clip && cur_clip) {
                // Turn clipping off
                UI.updateSetting('clip', false);
                display.set_viewport(false);
                // Disable max dimensions
                display.set_maxWidth(0);
                display.set_maxHeight(0);
                display.viewportChangeSize();
            }
            if (UI.getSetting('clip')) {
                // If clipping, update clipping settings
                display.set_viewport(true);

                var size = UI.getCanvasLimit();
                if (size) {
                    display.set_maxWidth(size.w);
                    display.set_maxHeight(size.h);

                    // Hide potential scrollbars that can skew the position
                    $D('noVNC_container').style.overflow = "hidden";

                    // The x position marks the left margin of the canvas,
                    // remove the margin from both sides to keep it centered
                    var new_w = size.w - (2 * Util.getPosition($D('noVNC_canvas')).x);

                    $D('noVNC_container').style.overflow = "visible";

                    display.viewportChangeSize(new_w, size.h);
                }
            }
        },

        // Handle special cases where clipping is forced on/off or locked
        enableDisableViewClip: function () {
            var resizeElem = $D('noVNC_resize');
            var connected = UI.rfb && UI.rfb_state === 'normal';

            if (UI.isSafari) {
                // Safari auto-hides the scrollbars which makes them
                // impossible to use in most cases
                UI.setViewClip(true);
                $D('noVNC_clip').disabled = true;
            } else if (resizeElem.value === 'downscale' || resizeElem.value === 'scale') {
                // Disable clipping if we are scaling
                UI.setViewClip(false);
                $D('noVNC_clip').disabled = true;
            } else if (document.msFullscreenElement) {
                // The browser is IE and we are in fullscreen mode.
                // - We need to force clipping while in fullscreen since
                //   scrollbars doesn't work.
                UI.togglePopupStatus("Forcing clipping mode since scrollbars aren't supported by IE in fullscreen");
                UI.rememberedClipSetting = UI.getSetting('clip');
                UI.setViewClip(true);
                $D('noVNC_clip').disabled = true;
            } else if (document.body.msRequestFullscreen && UI.rememberedClip !== null) {
                // Restore view clip to what it was before fullscreen on IE
                UI.setViewClip(UI.rememberedClipSetting);
                $D('noVNC_clip').disabled = connected || UI.isTouchDevice;
            } else {
                $D('noVNC_clip').disabled = connected || UI.isTouchDevice;
                if (UI.isTouchDevice) {
                    UI.setViewClip(true);
                }
            }
        },
        
        updateViewDragClient: function (drag) {
            switch ($('.js-vms-spy-setting-resolution').val()) {
                case 'adapted':
                    $('.js-vms-spy-setting-resolution').trigger('change');
                    break;
                case 'original':                
                    UI.updateViewDrag(drag);
                    break;
            }
        },

        // Update the viewport drag/move button
        updateViewDrag: function(drag) {   
            if (!UI.rfb) return;

            // Check if viewport drag is possible
            if (UI.rfb_state === 'normal' &&
                UI.rfb.get_display().get_viewport() &&
                UI.rfb.get_display().clippingDisplay()) {

            } else {
                // The VNC content is the same size as
                // or smaller than the display

                if (UI.rfb.get_viewportDrag) {
                    // Turn off viewport drag when it's
                    // active since it can't be used here
                    UI.rfb.set_viewportDrag(false);
                }
                return;
            }

            if (typeof(drag) !== "undefined" &&
                typeof(drag) !== "object") {
                if (drag) {
                    UI.rfb.set_viewportDrag(true);
                } else {
                    UI.rfb.set_viewportDrag(false);
                }
            }
        },
        
        getClientResolution: function () {
            return {
                width: UI.rfb.get_display()._fb_width,
                height: UI.rfb.get_display()._fb_height
            };
        },

        toggleViewDrag: function() {            alert(11);

            if (!UI.rfb) return;

            if (UI.rfb.get_viewportDrag()) {
                UI.rfb.set_viewportDrag(false);
            } else {
                UI.rfb.set_viewportDrag(true);
            }
        },

        // On touch devices, show the OS keyboard
        showKeyboard: function() {
            var kbi = $D('keyboardinput');
            var skb = $D('showKeyboard');
            var l = kbi.value.length;
            if(UI.keyboardVisible === false) {
                kbi.focus();
                try { kbi.setSelectionRange(l, l); } // Move the caret to the end
                catch (err) {} // setSelectionRange is undefined in Google Chrome
                UI.keyboardVisible = true;
                skb.className = "noVNC_status_button_selected";
            } else if(UI.keyboardVisible === true) {
                kbi.blur();
                skb.className = "noVNC_status_button";
                UI.keyboardVisible = false;
            }
        },

        keepKeyboard: function() {
            clearTimeout(UI.hideKeyboardTimeout);
            if(UI.keyboardVisible === true) {
                $D('keyboardinput').focus();
                $D('showKeyboard').className = "noVNC_status_button_selected";
            } else if(UI.keyboardVisible === false) {
                $D('keyboardinput').blur();
                $D('showKeyboard').className = "noVNC_status_button";
            }
        },

        keyboardinputReset: function() {
            var kbi = $D('keyboardinput');
            kbi.value = new Array(UI.defaultKeyboardinputLen).join("_");
            UI.lastKeyboardinput = kbi.value;
        },

        // When normal keyboard events are left uncought, use the input events from
        // the keyboardinput element instead and generate the corresponding key events.
        // This code is required since some browsers on Android are inconsistent in
        // sending keyCodes in the normal keyboard events when using on screen keyboards.
        keyInput: function(event) {

            if (!UI.rfb) return;

            var newValue = event.target.value;

            if (!UI.lastKeyboardinput) {
                UI.keyboardinputReset();
            }
            var oldValue = UI.lastKeyboardinput;

            var newLen;
            try {
                // Try to check caret position since whitespace at the end
                // will not be considered by value.length in some browsers
                newLen = Math.max(event.target.selectionStart, newValue.length);
            } catch (err) {
                // selectionStart is undefined in Google Chrome
                newLen = newValue.length;
            }
            var oldLen = oldValue.length;

            var backspaces;
            var inputs = newLen - oldLen;
            if (inputs < 0) {
                backspaces = -inputs;
            } else {
                backspaces = 0;
            }

            // Compare the old string with the new to account for
            // text-corrections or other input that modify existing text
            var i;
            for (i = 0; i < Math.min(oldLen, newLen); i++) {
                if (newValue.charAt(i) != oldValue.charAt(i)) {
                    inputs = newLen - i;
                    backspaces = oldLen - i;
                    break;
                }
            }

            // Send the key events
            for (i = 0; i < backspaces; i++) {
                UI.rfb.sendKey(XK_BackSpace);
            }
            for (i = newLen - inputs; i < newLen; i++) {
                UI.rfb.sendKey(newValue.charCodeAt(i));
            }

            // Control the text content length in the keyboardinput element
            if (newLen > 2 * UI.defaultKeyboardinputLen) {
                UI.keyboardinputReset();
            } else if (newLen < 1) {
                // There always have to be some text in the keyboardinput
                // element with which backspace can interact.
                UI.keyboardinputReset();
                // This sometimes causes the keyboard to disappear for a second
                // but it is required for the android keyboard to recognize that
                // text has been added to the field
                event.target.blur();
                // This has to be ran outside of the input handler in order to work
                setTimeout(function() { UI.keepKeyboard(); }, 0);
            } else {
                UI.lastKeyboardinput = newValue;
            }
        },

        //Helper to add options to dropdown.
        addOption: function(selectbox, text, value) {
            var optn = document.createElement("OPTION");
            optn.text = text;
            optn.value = value;
            selectbox.options.add(optn);
        },

        setBarPosition: function() {
        }

    };
})();
