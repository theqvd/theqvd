Wat.Views.VMListView = Wat.Views.ListView.extend({  
    qvdObj: 'vm',
    viewMode: 'grid',
    liveFields: ['state', 'user_state', 'ip', 'host_id', 'host_name', 'ssh_port', 'vnc_port', 'serial_port'],
    
    relatedDoc: {
        image_update: "Images update guide",
        full_vm_creation: "Create a virtual machine from scratch",
    },
    
    initialize: function (params) {  
        this.collection = new Wat.Collections.VMs(params);

        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {
        'click .js-change-viewmode': 'changeViewMode',
        'click .js-vm-details': 'openDetailsDialog',
        'click .js-vm-settings': 'openVmSettingsDialog',
    },
    
    startVM: function (filters) {        
        var messages = {
            'success': 'Successfully required to be started',
            'error': 'Error starting Virtual machine'
        }
        
        Wat.A.performAction ('vm_start', {}, filters, messages, function(){}, this);
    },
    
    // Different functions applyed to the selected items in list view
    applyStart: function (that) {
        that.startVM (that.applyFilters);
        that.resetSelectedItems ();
    },
    
    applyStop: function (that) {
        that.stopVM (that.applyFilters);
        that.resetSelectedItems ();
    },
    
    applyDisconnect: function (that) {
        that.disconnectVMUser (that.applyFilters);
        that.resetSelectedItems ();
    },
    
    openDetailsDialog: function (e) {  
        this.selectedModelId = $(e.target).attr('data-model-id');
        
        var dialogConf = {
            title: 'Details',
            buttons : {
                "Close": function () {
                    Wat.I.closeDialog($(this));
                },
            },
            button1Class : 'fa fa-check',
            fillCallback : this.fillDetailsDialog
        }
                
        Wat.I.dialog(dialogConf, this); 
    },  
    
    openProfilesDialog: function (e) {    
        this.selectedModelId = $(e.target).attr('data-model-id');
        
        var dialogConf = {
            title: 'Profile selection',
            fillCallback : this.fillProfilesSelectDialog,
            buttons : {
                "Cancel": function () {
                    Wat.I.closeDialog($(this));
                },
                "Save": function () {
                    Wat.I.closeDialog($(this));
                },
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-save',
        }
                
        Wat.I.dialog(dialogConf, this); 
    },      
    
    openProfilesManageDialog: function (e) {    
        this.selectedModelId = $(e.target).attr('data-model-id');
        
        var dialogConf = {
            title: 'Profiles management',
            fillCallback : this.fillProfilesManageDialog,
            buttons : {
                "Close": function () {
                    Wat.I.closeDialog($(this));
                },
            },
            button1Class : 'fa fa-check',
        }
                
        Wat.I.dialog(dialogConf, this); 
    },  
    
    openProfileChangeDialog: function (e) {            
        var dialogConf = {
            title: 'Profile change',
            fillCallback : this.fillProfileChangeDialog,
            buttons : {
                "Cancel": function () {
                    Wat.I.closeDialog($(this));
                },
                "OK": function () {
                    Wat.I.closeDialog($(this));
                },
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-check',
        }
                
        Wat.I.dialog(dialogConf, this); 
    },     
    
    openVmSettingsDialog: function (e) {    
        this.selectedModelId = $(e.target).attr('data-model-id');
        
        var dialogConf = {
            title: 'Connection settings for this Virtual Machine',
            buttons : {
                "Cancel": function () {
                    Wat.I.closeDialog($(this));
                },
                "Save": function () {
                    Wat.I.closeDialog($(this));
                },
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-save',
            fillCallback : this.fillVmSettingsDialog
        }
                
        Wat.I.dialog(dialogConf, this); 
    },      
    
    openEditProfileDialog: function (e) {  
        this.selectedModelId = $(e.target).attr('data-profile-id');
        
        var dialogConf = {
            title: 'Edit profile',
            buttons : {
                "Cancel": function () {
                    Wat.I.closeDialog($(this));
                },
                "Save": function () {
                    Wat.I.closeDialog($(this));
                },
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-save',
            fillCallback : this.fillSettingsEditorDialog
        }
                
        Wat.I.dialog(dialogConf, this); 
    },      
    
    openNewProfileDialog: function (e) {          
        var dialogConf = {
            title: 'New profile',
            buttons : {
                "Cancel": function () {
                    Wat.I.closeDialog($(this));
                },
                "Save": function () {
                    Wat.I.closeDialog($(this));
                },
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-save',
            fillCallback : this.fillSettingsEditorDialog
        }
                
        Wat.I.dialog(dialogConf, this); 
    },
    
    deleteProfile: function (e) {
        this.dialog = $('.js-dialog-container');
        if (confirm($.i18n.t("Are you sure?"))) {        
            $(this.dialog).html('');
            this.fillProfilesManageDialog(this.dialog, this);
            Wat.T.translate();
        }
    },
    
    openVMWarningsDialog: function (e) {
        this.selectedModelId = $(e.target).attr('data-model-id');
        
        var dialogConf = {
            title: 'Warnings',
            fillCallback : this.fillVMWarningsDialog
        }
                
        Wat.I.dialog(dialogConf, this); 
    },
    
    fillDetailsDialog: function (dialog, that) {
        var model = that.collection.get(that.selectedModelId);
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.details_vm, {
                model: model,
                userStateIcon: that.getUserStateIcon(model.get('user_state'), that.selectedModelId), 
                warningIcon: that.getWarningIcon(model.get('expiration_hard'), that.selectedModelId), 
            });
        
        $(dialog).html(template);
    },   
    
    fillProfileChangeDialog: function (dialog, that) {        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.profileChange, {
                newProfile: $('select[name="connection_profile"]').val()
            });
        
        $(dialog).html(template);
    },    
    
    fillProfilesSelectDialog: function (dialog, that) {
        var model = that.collection.get(that.selectedModelId);
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.profilesSelect, {
                model: model
            });
        
        $(dialog).html(template);
        
        Wat.I.chosenElement('select[name="connection_profile"]', 'single100');
        Wat.I.chosenElement('select[name="connection_profile_remember"]', 'single100');
    },    
    
    fillProfilesManageDialog: function (dialog, that) {
        var model = that.collection.get(that.selectedModelId);
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.profilesManage, {
                model: model
            });
        
        $(dialog).html(template);
    },       
    
    fillVmSettingsDialog: function (dialog, that) {
        var model = that.collection.get(that.selectedModelId);
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.vmConnectionSettings, {
                model: model
            });
        
        $(dialog).html(template);
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.connectionSettings, {
                model: model,
                onlyread: true,
            });
        
        $(dialog).find('.bb-vm-settings-global').html(template); 
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.connectionSettings, {
                model: model,
                onlyread: false,
            });
        
        $(dialog).find('.bb-vm-settings-custom').html(template);
        
        Wat.I.chosenElement('select[name="type"]', 'single100');
        Wat.I.chosenElement('select[name="custom_settings"]', 'single100');
        Wat.T.translate();
    },    
    
    fillSettingsEditorDialog: function (dialog, that) {
        var model = that.collection.get(that.selectedModelId);
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.editConnectionSettings, {
                model: model,
            });
        
        $(dialog).html(template);        
        
        var template = _.template(
            Wat.TPL.connectionSettings, {
                model: model,
                onlyread: false,
            });
        
        $(dialog).find('.bb-vm-settings').html(template);
        
        Wat.I.chosenElement('select[name="type"]', 'single100');
    },    
    
    fillVMWarningsDialog: function (dialog, that) {
        var model = that.collection.get(that.selectedModelId);
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.VMwarnings, {
                model: model
            });
        
        $(dialog).html(template);        
    },
    
    getUserStateIcon: function (userState, modelId) {
        switch (userState) {
            case 'disconnected':
                var icon = '<i class="fa fa-user not-notify state-icon js-state-icon" data-i18n="[title]User not connected" data-wsupdate="user_state" data-id="' + modelId + '"></i>';
                break;
            case 'connected':
                var icon = '<i class="fa fa-user ok state-icon js-state-icon" data-i18n="[title]Running" data-wsupdate="state" data-id="' + modelId + '"></i>';
                break;
            case 'hanged':
                var icon = '<i class="fa fa-user error state-icon js-state-icon" data-i18n="[title]Hanged" data-wsupdate="state" data-id="' + modelId + '"></i>';
                break;
        }
        
        return icon;
    },    
    
    getWarningIcon: function (expiration, modelId) {
        if (expiration) {
            var icon = '<a href="javascript:" class="js-vm-warnings" data-model-id="' + modelId + '">';
            icon += '<i class="fa fa-warning error warning-icon js-warning-icon" data-i18n="[title]The VM will expire" data-wsupdate="warning_icon" data-model-id="' + modelId + '"></i>';
            icon += '</a>';
        }
        else {
            var icon = '<i class="fa fa-warning not-notify warning-icon js-warning-icon" data-i18n="[title]There are not warnings" data-wsupdate="warning_icon" data-model-id="' + modelId + '"></i>';
        }
        
        return icon;
    },
    
    fillChangePasswordDialog: function (dialog, that) {   
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.changePassword, {
            });

        $(dialog).html(template);
    },
});