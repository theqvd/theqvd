// Desktops CRUD functions
Up.CRUD.desktops = {
    editDesktopSettings: function (e) {
        var selectedId = $(e.target).attr('data-id');
        var model = Up.CurrentView.collection.where({id: parseInt(selectedId)})[0];
        
        var that = this;
        var dialogConf = {
            title: $.i18n.t('Desktop settings') + ': ' + model.get('name'),
            buttons : {
                "Reset form": function () {
                    that.resetForm(this);
                },
                "Cancel": function () {
                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Save": function () {
                    var params = Up.I.parseForm(this);
                    
                    // On desktops, editable name is alias field
                    params.alias = params.name;
                    delete params.name;
                                        
                    Up.CurrentView.updateModel({id: model.get('id')}, params, Up.CurrentView.render, model);
                    
                    Up.I.closeDialog($(this));
                }
            },
            buttonClasses : [CLASS_ICON_RESET, CLASS_ICON_CANCEL, CLASS_ICON_SAVE],
            fillCallback : function (target) { 
                Up.I.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    },
    
    connectDesktopClassic: function (selectedId, desktopSetup, token) {
        var that = this;
        
        this.startConnectionTimeout(selectedId);
        
        var options = {
            "client.ssl.options.SSL_version": "TLSv1_2",
            "client.auto_connect": "1",
            "client.auto_connect.vm_id": selectedId,
            "client.auto_connect.token": token
        };

        options['client.host.name'] = desktopSetup.hostname;
        
        $.each(CLIENT_PARAMS_MAPPING, function (field, param) {
            options[param.value] = desktopSetup.settings[field].value;
        });  

        var shareFolders = parseInt(desktopSetup.settings.share_folders.value);
        var shareUsb = parseInt(desktopSetup.settings.share_usb.value);

        if (shareFolders) {
            var foldersList = desktopSetup.settings.share_folders.list;

            $.each(foldersList, function (k, folder) {
                options['client.share.' + k] = folder;
            });
        }

        options['client.usb.enable'] = parseInt(shareUsb);

        if (shareUsb) {
            var usbList = desktopSetup.settings.share_usb.list;

            options['client.usb.share_list'] = usbList.join(',');
        }

        var query = '';
        $.each(options, function (optName, optVal) {
            query += optName + '=' + optVal + ' ';
        });

        // Store ID of the desktop we are trying to connect with to use it if fails
        this.connectingDesktopId = selectedId;
        
        // Protocol Check is not working properly on chrome. We handle it manually.
        if ($.browser.chrome) {
            open('qvd:' + query, '_self');
        }
        else {
            window.protocolCheck('qvd:' + query, this.connectDesktopFail, this.connectDesktopSuccess);
        }
    },
    
    connectDesktopHTML5: function (selectedId, desktopSetup, token) {
        open('#desktops/' + selectedId + '/connect/' + token);
    },
    
    connectDesktop: function (e) {
        var that = this;
        
        var selectedId = $(e.target).attr('data-id');

        Up.A.performAction('desktops/' + selectedId + '/token', {}, function (e) {
            if (e.retrievedData.status && e.retrievedData.status != STATUS_SUCCESS_HTTP) {
                return;
            }
            
            var token = e.retrievedData.token;
            
            // Retrieve effective desktop setup to make the client call
            Up.A.performAction('desktops/' + selectedId + '/setup', {}, function (e) {
                if (e.retrievedData.status && e.retrievedData.status != STATUS_SUCCESS_HTTP) {
                    return;
                }
                
                var client = e.retrievedData.settings.client.value;
                that.setDesktopState(selectedId, 'connecting');
                
                switch (client) {
                    case 'classic':
                        if ($.cookie('dontShowFirstConnectionMsg')) {
                            that.connectDesktopClassic(selectedId, e.retrievedData, token);
                        }
                        else {
                            that.showClassicClientMessage(selectedId, e.retrievedData, token);
                        }
                        break;
                    case 'html5':
                        that.connectDesktopHTML5(selectedId, e.retrievedData, token);
                        break;
                }
            });
        }, this, 'GET');
    },
    
    // Callback used on custom protocol handler success
    connectDesktopSuccess: function () {
        // Success
    },
    
    // Callback used on custom protocol handler fail
    connectDesktopFail: function () {
        // Set selected desktop as disconnected
        var model = Up.CurrentView.collection.where({id: parseInt(Up.CurrentView.connectingDesktopId)})[0];
        Up.CurrentView.setDesktopState(model.get('id'), 'disconnected');
        
        var dialogConf = {
            title: $.i18n.t('QVD client is taking too much time to respond'),
            buttons : {
                "Cancel": function () {
                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Download": function () {
                    // Go to download section
                    window.location = '#/downloads';

                    // Close dialog
                    Up.I.closeDialog($(this));
                }
            },
            buttonClasses : [CLASS_ICON_CANCEL, CLASS_ICON_CLIENT_DOWNLOAD],
            fillCallback : function (target) { 
                var template = _.template(
                    Up.TPL.dialogClientNotInstalled, {
                    }
                );
                
                $(target).html(template);
            },
        }

        Up.I.dialog(dialogConf);
    },  
    
    // Show dialog with info about qvd client requierement
    showClassicClientMessage: function (selectedId, retrievedData, token) {
        var that = this;
        
        var dialogConf = {
            title: $.i18n.t('Read me before continue'),
            buttons : {
                "Cancel": function () {
                    // Store cookie to never show this message again if is required
                    if ($('.js-never-show-again').is(':checked')) {
                        $.cookie('dontShowFirstConnectionMsg', true, {expires: 365, path: '/'});
                    }

                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Download": function () {
                    // Store cookie to never show this message again if is required
                    if ($('.js-never-show-again').is(':checked')) {
                        $.cookie('dontShowFirstConnectionMsg', true, {expires: 1, path: '/'});
                    }

                    // Go to download section
                    window.location = '#/downloads';

                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Connect": function () {
                    that.setDesktopState(selectedId, 'connecting');

                    // Store cookie to never show this message again if is required
                    if ($('.js-never-show-again').is(':checked')) {
                        $.cookie('dontShowFirstConnectionMsg', true, {expires: 1, path: '/'});
                    }

                    // Connect
                    that.connectDesktopClassic(selectedId, retrievedData, token);

                    // Close dialog
                    Up.I.closeDialog($(this));
                }
            },
            buttonClasses : [CLASS_ICON_CANCEL, CLASS_ICON_CLIENT_DOWNLOAD, CLASS_ICON_DESKTOP_CONNECT],
            fillCallback : function (target) {
                // Abort connection animation
                Up.CurrentView.setDesktopState(selectedId, 'disconnected');

                var template = _.template(
                    Up.TPL.dialogClientFirstMessage, {
                    }
                );

                $(target).html(template);
            },
        }

        Up.I.dialog(dialogConf);
    },
    
    resetForm: function (context) {
        Up.I.renderEditionModeParameters(Up.CurrentView.modelInEdition, Up.CurrentView.modelInEdition.get('settings_enabled'));
        
        // Restore name and settings enabled checkbox
        var nameCtl = $(context).find('.js-form-field[name="name"]');
        var nameValue = $(nameCtl).attr('data-original-value');
        $(nameCtl).val(nameValue);
        
        var settingsEnabledCtl = $(context).find('.js-form-field[name="settings_enabled"]');
        var settingsEnabledChecked = parseInt($(settingsEnabledCtl).attr('data-original-checked')) ? true : false;
        $(settingsEnabledCtl).prop('checked',settingsEnabledChecked);
    },
}