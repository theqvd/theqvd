Up.Views.DesktopConnectView = Up.Views.MainView.extend({  
    qvdObj: 'desktop',
    liveFields: [],

    relatedDoc: {
    },
    
    initialize: function (params) {
        var that = this;
        
        Up.B.bindCommonEvents();
        
        // Store temporal token
        that.token = params.token;
        
        $('.bb-super-wrapper').html(HTML_LOADING);
        this.model = new Up.Models.Desktop(params);
        Up.Views.MainView.prototype.initialize.apply(this, [params]);
        $('.loading').hide();
        
        // Fetch model data, then get desktop setup and connection template
        this.model.fetch({ 
            complete: function () {
                that.getSetup();
            }
        });
    },
    
    // Get combined setup from specific settings and current workspace
    getSetup: function () {
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
        
        $('.bb-super-wrapper').css('padding', '0px');
        var template = _.template(
            Up.TPL.spy_desktops, {
                vmId:  this.model.get('id'),
                apiHost: Up.C.apiUrl.split("/")[2].split(':')[0],
                apiPort: Up.C.apiUrl.split("/")[2].split(':')[1],
                sid: Up.C.sid,
                model: this.model,
                token: this.token,
                fullScreen: this.desktopSetup.settings.fullscreen.value
            }
        );
        
        var noVNCIncludes = '<script src="lib/thirds/noVNC/include/util.js"></script><script src="lib/interface/interface-noVNC.js"></script>';
              
        $('.bb-super-wrapper').html(template + noVNCIncludes);
        
        $('.error-loading').hide();
        Up.I.loadingBlock($.i18n.t('progress:Loading your Desktop'));
        Up.I.startProgress(12);
        
        Up.T.translate();
        
        $('.js-vm-spy-settings-panel').buildMbExtruder({
            position:"left",
            width:270,
            extruderOpacity:.9,
            hidePanelsOnClose:true,
            accordionPanels:true,
            onExtOpen:function(){
                $(".js-vms-spy-setting-resolution").on('change', that.changeSettingResolution);
                $(".js-vms-spy-setting-log").on('change', that.changeSettingLog);
                $(".js-vnc-keyboard").on('click', that.clickKeyboard);
                
                Up.T.translate();
                Up.I.Chosen.configuration();
                Up.I.Chosen.element('.vms-spy-settings select', 'single100');
            },
            onExtContentLoad:function(){},
            onExtClose:function(){}
        });
        
        var loopCheck = setInterval(function () {
            if(typeof $D == "function") {
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

                $( window ).resize(function() {
                    UI.onresize();
                });
                
                clearInterval(loopCheck);
                
                that.isAliveRecorder();
            }
        }, 400);
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
        $('.js-vm-spy-settings-panel').closeMbExtruder();
        $('#kbi').focus();
    },
    
    // Recursive function to record timestamp when it was alive
    isAliveRecorder: function (that) {
        // Register timestamp as lastAlive
        var now = Math.round(new Date().getTime() / 1000);
        Up.C.lastAlive = now;
        
        // First execution, start is alive listener
        if (!that) {
            this.isAlive = this.isAliveListener();
        }
        
        var that = that || this;
        
        setTimeout(function () {
            Up.A.apiInfo(that.isAliveRecorder, that);
        }, 3000);
    },
    
    // Listener to check if is alive
    isAliveListener: function () {
        return setInterval(function () {
            if (!Up.C.lastAlive) {
                return;
            }
            
            var now = Math.round(new Date().getTime() / 1000);

            var lastAcceptableAlive = now - 4;
            
            if (lastAcceptableAlive >= Up.C.lastAlive) {
                Up.I.M.showMessage({message: i18n.t('Connection to server is lost'), messageType: 'error'});
                delete Up.C.lastAlive;
            }
            else {
                Up.I.M.closeMessage();
            }
        }, 1000);
    }
});
