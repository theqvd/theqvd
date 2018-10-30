Up.Views.DesktopConnectView = Up.Views.MainView.extend({  
    qvdObj: 'desktop',
    liveFields: [],

    connectionLevel: CL_NOT_READY,

    relatedDoc: {
    },
    
    initialize: function (params) {
        var that = this;
        
        // Store temporal token
        that.token = params.token;
        that.id = params.id;
        
        $('.bb-super-wrapper').html(HTML_LOADING);
        this.model = new Up.Models.Desktop(params);
        Up.Views.MainView.prototype.initialize.apply(this, [params]);
        $('.loading').hide();

        // Fetch model data, then get desktop setup and connection template
        this.model.fetch({ 
            complete: function () {
                Up.WS.openWebsocket('desktops', that.changeUserState);

                var connectInterval = setInterval(function () {
                    switch (that.model.get('vm_state')) {
                        case 'stopped':
                        case 'running':
                            clearInterval(connectInterval);
                            that.connectionLevel = CL_READY;
                            
                            that.getSetupTemplatesAndRender();
                            break;
                        default:
                            Up.I.loadingBlock($.i18n.t('progress:Loading your Desktop'));
                            Up.I.updateProgressMessage('Waiting for stable desktop state', 'hourglass-half');
                    }
                }, 1000);
            }
        });

        // Create a cookie to communicate to desktop list view that the desktop is being connecting
        $.cookie('connectingDesktop-' + that.id, true, {expires: 1, path: '/'});

        // If window is closed, delete the connecting cookie
        $(window).on("beforeunload", function() {
            $.removeCookie('connectingDesktop-' + that.id, {path: '/'});
        });
    },
    
    changeUserState: function (data) {
        if (data.id != Up.CurrentView.id) {
            return;
        }

        Up.CurrentView.model.set('vm_state', data.vm_state);
        
        if (Up.CurrentView.connectionLevel == CL_READY) {
            switch (data.user_state) {
                case 'connecting':
                    Up.I.updateProgressMessage('Waking up virtual machine', 'sun-o');
                    break;
                case 'connected':
                    // When desktop is finally connected, connecting cookie is deleted
                    $.removeCookie('connectingDesktop-' + data.id, {path: '/'});
                    Up.I.loadingUnblock();
                    Up.I.stopProgress();
                    $('.noVNC_canvas').show();

                    Up.WS.closeAllWebsockets();
                    break;
            }
        }
    },
    
    // Get combined setup from specific settings and current workspace
    getSetupTemplatesAndRender: function () {
        var that = this;
        
        Up.A.performAction('desktops/' + this.model.get('id') + '/setup', {}, function (e) {
            if (e.retrievedData.status && e.retrievedData.status != STATUS_SUCCESS_HTTP) {
                return;
            }

            that.desktopSetup = e.retrievedData;
            that.getTemplatesAndRender();
        });
    },
    
    getTemplatesAndRender: function () {
        var templates = Up.I.T.getTemplateList('spyDesktop');
        
        Up.A.getTemplates(templates, Up.CurrentView.render); 
    },
    
    render: function () {
        var that = this;
        
        var kbLayout = Up.U.getKeyboardLayoutCode(this.desktopSetup.settings.kb_layout.value);

        $('.bb-super-wrapper').css('padding', '0px');
        var template = _.template(
            Up.TPL.spy_desktops, {
                vmId:  this.model.get('id'),
                apiHost: Up.C.apiUrl.split("/")[2].split(':')[0],
                apiPort: Up.C.apiUrl.split("/")[2].split(':')[1],
                sid: Up.C.sid,
                model: this.model,
                token: this.token,
                fullScreen: this.desktopSetup.settings.fullscreen.value,
                kbLayout: kbLayout
            }
        );
        
        var noVNCIncludes = '<script src="lib/thirds/noVNC/include/util.js"></script><script src="lib/interface/interface-noVNC.js"></script>';
              
        $('.bb-super-wrapper').html(template + noVNCIncludes);
        
        UI.afterLoadingScripts = function () {
            Util.Debug = Util.Info = Util.Warn = Util.Error = function () {};

            var level = 'debug';
            switch (level) {
                case 'debug':
                    Util.Debug = function (msg) { UI.log('DEBUG', msg); };
                case 'info':
                    Util.Info  = function (msg) { UI.log('INFO', msg); };
                case 'warn':
                    Util.Warn  = function (msg) { UI.log('WARN', msg); };
                case 'error':
                    Util.Error = function (msg) { UI.log('ERROR', msg); };
                case 'none':
                    break;
            }
            
            UI.connect();
        }
        
        $( window ).resize(function() {
            UI.onresize();
        });
        
        $('.error-loading').hide();
        Up.I.loadingBlock($.i18n.t('progress:Loading your Desktop'));
        Up.I.updateProgressMessage('Connecting with server', 'plug');
        
        Up.T.translate();
    },
    
    
    changeSettingLog: function (e) {
        var level = $(e.target).val();
        
        switch (level) {
            case "disabled":
                $('.js-vms-spy-log').hide();
                break;
            default:
                $('.js-vms-spy-log').show();
                $('.log-line-debug, .log-line-info, .log-line-warn, .log-line-error').hide();
                $('.log-line-' + level).show();
                switch (level) {
                    case 'debug':
                        $('.log-line-debug').show();
                    case 'info':
                        $('.log-line-info').show();
                    case 'warn':
                        $('.log-line-warn').show();
                    case 'error':
                        $('.log-line-error').show();
                    default:
                        break;
                }
                break;
        }
    },
    
    changeSettingResolution: function (e) {
        switch ($(e.target).val()) {
            case "adapted":
                UI.onresize();
                break;
            case "original":
                UI.setClientResolution();
                break;
        }
    },
    
    clickKeyboard: function (e) {
        // focus on a visible input may work
        $('#kbi').focus();
    }
});
