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
        'click .js-vm-settings': 'openSettingsDialog',
        'click .js-vm-warnings': 'openVMWarningsDialog',
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
                "Force disconnection": function () {
                    $(this).dialog('close');
                },
                "Reboot VM": function () {
                    $(this).dialog('close');
                }
            },
            button1Class : 'fa fa-sign-out',
            button2Class : 'fa fa-refresh',
            fillCallback : this.fillDetailsDialog
        }
                
        Wat.I.dialog(dialogConf, this); 
    },  
    
    openSettingsDialog: function (e) {    
        this.selectedModelId = $(e.target).attr('data-model-id');
        
        var dialogConf = {
            title: 'Connection settings',
            buttons : {
                "Save": function () {
                    $(this).dialog('close');
                },
            },
            button1Class : 'fa fa-save',
            fillCallback : this.fillSettingsDialog
        }
                
        Wat.I.dialog(dialogConf, this); 
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
    
    fillSettingsDialog: function (dialog, that) {
        var model = that.collection.get(that.selectedModelId);
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.connectionSettings, {
                model: model
            });
        
        $(dialog).html(template);
        
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
});