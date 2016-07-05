Wat.Views.VMSpyView = Wat.Views.MainView.extend({  
    qvdObj: 'vm',
    liveFields: [],

    relatedDoc: {
    },
    
    initialize: function (params) {
        var that = this;
        
        $('.bb-super-wrapper').html(HTML_LOADING);
        this.model = new Wat.Models.VM(params);
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        this.model.fetch({
            complete: function () {
                that.getTemplatesAndRender();
            }
        });
    },
    
    getTemplatesAndRender: function () {
        var templates = Wat.I.T.getTemplateList('commonVMS');
        
        Wat.A.getTemplates(this.templates, Wat.CurrentView.render); 
    },
    
    render: function () {
        var that = this;

        $('.bb-super-wrapper').css('padding', '0px');
        var template = _.template(
            Wat.TPL.spyVM, {
                vmId:  this.model.get('id'),
                apiHost: Wat.C.apiUrl.split("/")[2].split(':')[0],
                apiPort: Wat.C.apiUrl.split("/")[2].split(':')[1],
                sid: Wat.C.sid,
                model: this.model
            }
        );
        
        var noVNCIncludes = '<script src="lib/thirds/noVNC/include/util.js"></script><script src="lib/interface/interface-noVNC.js"></script>';
              
        $('.bb-super-wrapper').html(template + noVNCIncludes);
        
        Wat.T.translate();
        
        $('.js-vm-spy-settings-panel').buildMbExtruder({
            position:"left",
            width:270,
            extruderOpacity:.9,
            hidePanelsOnClose:true,
            accordionPanels:true,
            onExtOpen:function(){
                $(".js-vms-spy-setting-resolution").on('change', that.changeSettingResolution);
                $(".js-vms-spy-setting-mode").on('change', that.changeSettingMode);
                $(".js-vms-spy-setting-log").on('change', that.changeSettingLog);
                $(".js-vnc-keyboard").on('click', that.clickKeyboard);
                
                Wat.T.translate();
                Wat.I.chosenConfiguration();
                Wat.I.chosenElement('.vms-spy-settings select', 'single100');
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
                    if ($('.js-vms-spy-setting-resolution').val() == 'adapted') {
                        UI.onresize();
                    }
                });
                clearInterval(loopCheck);
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
    
    changeSettingMode: function (e) {
        switch ($(e.target).val()) {
            case "view_only":
                UI.rfb.set_view_only(true);
                $('.noVNC_canvas').addClass('noVNC_canvas--viewonly');
                $('.noVNC_canvas').removeClass('noVNC_canvas--interactive');
                break;
            case "interactive":
                UI.rfb.set_view_only(false);
                $('.noVNC_canvas').removeClass('noVNC_canvas--viewonly');
                $('.noVNC_canvas').addClass('noVNC_canvas--interactive');
                break;
        }
    },
    
    clickKeyboard: function (e) {
        // focus on a visible input may work
        $('#kbi').focus();
		$('#kbi').hide();
    }
});