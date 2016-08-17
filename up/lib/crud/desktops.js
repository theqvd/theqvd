// Desktops CRUD functions
Up.CRUD.desktops = {
    editDesktopSettings: function (e) {
        var selectedId = $(e.target).attr('data-id');
        var model = Up.CurrentView.collection.where({id: parseInt(selectedId)})[0];
        
        var that = this;
        var dialogConf = {
            title: $.i18n.t('Desktop settings') + ': ' + model.get('name'),
            buttons : {
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
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-save',
            fillCallback : function (target) { 
                Up.I.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    },
    
    connectDesktop: function (e) {
        var that = this;
        
        var selectedId = $(e.target).attr('data-id');

        Up.A.performAction('desktops/' + selectedId + '/token', {}, function (e) {
            that.setDesktopState(selectedId, 'connecting');
            that.startConnectionTimeout(selectedId);
            
            var token = e.retrievedData.token;
            
            var options = {
                "client.ssl.options.SSL_version": "TLSv1_2",
                "client.auto_connect": "1",
                "client.auto_connect.vm_id": selectedId,
                "client.auto_connect.token": token
            };
            
            // Retrieve effective desktop setup to make the client call
            Up.A.performAction('desktops/' + selectedId + '/setup', {}, function (e) {
                options['client.host.name'] = e.retrievedData.hostname;

                $.each(CLIENT_PARAMS_MAPPING, function (field, param) {
                    options[param.value] = e.retrievedData.settings[field].value;
                });  

                var shareFolders = parseInt(e.retrievedData.settings.share_folders.value);
                var shareUsb = parseInt(e.retrievedData.settings.share_usb.value);

                if (shareFolders) {
                    var foldersList = e.retrievedData.settings.share_folders.list;

                    $.each(foldersList, function (k, folder) {
                        options['client.share.' + k] = folder;
                    });
                }

                options['client.usb.enable'] = parseInt(shareUsb);

                if (shareUsb) {
                    var usbList = e.retrievedData.settings.share_usb.list;

                    options['client.usb.share_list'] = usbList.join(',');
                }

                var query = '';
                $.each(options, function (optName, optVal) {
                    query += optName + '=' + optVal + ' ';
                });

                // Store ID of the desktop we are trying to connect with to use it if fails
                that.connectingDesktopId = selectedId;
                
                window.protocolCheck('qvd:' + query, that.connectDesktopFail)
                //open('qvd:' + query, '_self');
            });
        }, this, 'GET');
    },
    
    connectDesktopFail: function () {        
        // Set selected desktop as disconnected
        var model = Up.CurrentView.collection.where({id: parseInt(Up.CurrentView.connectingDesktopId)})[0];
        Up.CurrentView.setDesktopState(model.get('id'), 'disconnected');
        
        var dialogConf = {
            title: $.i18n.t('QVD client not installed'),
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
            button1Class : 'fa fa-ban',
            button2Class : CLASS_ICON_CLIENT_DOWNLOAD,
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
}