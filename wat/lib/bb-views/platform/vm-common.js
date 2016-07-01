// Common lib for VM views (list and details)
Wat.Common.BySection.vm = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = Wat.I.T.getTemplateList('commonVMS');
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    updateElement: function (dialog) {
        var that = that || this;
        
        // If current view is list, use selected ID as update element ID
        if (that.viewKind == 'list') {
            that.id = that.selectedItems[0];
        }
                
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(that, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = that.properties;
        
        var context = $('.' + that.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var di_tag = context.find('select[name="di_tag"]').val(); 
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": that.id};
        var arguments = {};
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('user.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        if (Wat.C.checkACL('vm.update.name')) {
            arguments['name'] = name;
        }     
        
        if (Wat.C.checkACL('vm.update.di-tag')) {
            arguments['di_tag'] = di_tag;
        }
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL(this.qvdObj + 'vm.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        if (Wat.C.checkACL('vm.update.expiration')) {
            // If expire is checked
            if (context.find('input.js-expire').is(':checked')) {
                var expiration_soft = context.find('input[name="expiration_soft"]').val();
                var expiration_hard = context.find('input[name="expiration_hard"]').val();

                if (expiration_soft != undefined) {
                    arguments['expiration_soft'] = expiration_soft;
                }

                if (expiration_hard != undefined) {
                    arguments['expiration_hard'] = expiration_hard;
                }
            }
            else {
                // Delete the expiration if exist
                arguments['expiration_soft'] = '';
                arguments['expiration_hard'] = '';
            }
        }
        
        if (Wat.C.checkACL('vm.update.description')) {
            arguments["description"] = description;
        }
                
        that.updateModel(arguments, filters, that.fetchAny);
    },
    
    openEditElementDialog: function(e) {
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }   
                
        this.dialogConf.title = $.i18n.t('Edit Virtual machine') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        // Virtual machine form include a date time picker control, so we need enable it
        Wat.I.enableDataPickers();
                
        var params = {
            'action': 'tag_tiny_list',
            'selectedId': this.model.get('di_tag'),
            'controlName': 'di_tag',
            'filters': {
                'osf_id': this.model.get('osf_id')
            },
            'nameAsId': true,
            'chosenType': 'single100'
        };

        Wat.A.fillSelect(params);
    },
    
    spyVM: function () {        
        this.applySpyVM(this.model);
    },
    
    applySpyVM: function (vmModel) { 
        var that = this;
        
        var dialogConf = {
            title: $.i18n.t('Spy'),
            buttons : {
                "Close": function () { 
                    UI.rfb.disconnect();

                    Wat.I.closeDialog($(this));
                }
            },
            
            buttonClasses : ['fa fa-ban'],
            
            fillCallback : function (target) {
                $('.ui-dialog').addClass('ui-dialog--fullscreen');   
                $('.noVNC_log').draggable();
                
                // Add common parts of editor to dialog
                var template = _.template(
                    Wat.TPL.spyVM, {
                        vmId:  vmModel.get('id'),
                        apiHost: Wat.C.apiUrl.split("/")[2].split(':')[0],
                        apiPort: Wat.C.apiUrl.split("/")[2].split(':')[1],
                        sid: Wat.C.sid
                    }
                );

                var noVNCIncludes = '<script src="lib/thirds/noVNC/include/util.js"></script><script src="lib/interface/interface-noVNC.js"></script>';
                
                target.html(template + noVNCIncludes);
                
                // Hide normal screen button from the begining
                $(".ui-dialog-buttonset button span.fa-compress").parent().hide();
                
                // Configure details and settings
                var templateDetails = _.template(
                    Wat.TPL.spyVMDetails, {
                        model: vmModel
                    }
                );
                                
                var templateSettings = _.template(
                    Wat.TPL.spyVMSettings, {
                    }
                );
                
                $(".ui-dialog-buttonset button:last-child").parent().append(templateDetails + templateSettings);
                
                Wat.T.translate();
                Wat.I.chosenElement('.vms-spy-settings select', 'single100');
                
                $(".ui-dialog-buttonset .js-vms-spy-setting-resolution").on('change', that.changeSettingResolution);
                $(".ui-dialog-buttonset .js-vms-spy-setting-mode").on('change', that.changeSettingMode);
                $(".ui-dialog-buttonset .js-vms-spy-setting-log").on('change', that.changeSettingLog);
                
                
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
                        
                        $(".js-vms-spy-settings").show();
                        $(".js-vms-spy-details").show();

                        //UI.onresize();
                        clearInterval(loopCheck);
                    }
                }, 400);
            }
        }

        this.dialog = Wat.I.dialog(dialogConf);  
    },
    
    changeSettingLog: function (e) {
        var level = $(e.target).val();
        
        switch (level) {
            case "disabled":
                $('.noVNC_log').hide();
                break;
            default:
                $('.noVNC_log').show();
                $('.noVNC_log').draggable({handle: '.drag-title'});
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
    }
}