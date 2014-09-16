Wat.Views.VMListView = Wat.Views.ListView.extend({  
    qvdObj: 'vm',
        
    initialize: function (params) {   
        this.collection = new Wat.Collections.VMs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {},
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.VM();
        
        this.dialogConf.title = $.i18n.t('New Virtual machine');
        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
        
        // Fill OSF select on virtual machines creation form
        var params = {
            'action': 'user_tiny_list',
            'selectedId': '',
            'controlName': 'user_id'
        };

        Wat.A.fillSelect(params);  
        
        Wat.I.chosenElement('[name="user_id"]', 'advanced100');
        
        // Fill OSF select on virtual machines creation form
        var params = {
            'action': 'osf_tiny_list',
            'selectedId': '',
            'controlName': 'osf_id'
        };

        Wat.A.fillSelect(params);  
        
        Wat.I.chosenElement('[name="osf_id"]', 'single100');
        
        // Fill DI Tags select on virtual machines creation form
        var params = {
            'action': 'tag_tiny_list',
            'selectedId': 'default',
            'controlName': 'di_tag',
            'filters': {
                'osf_id': $('[name="osf_id"]').val()
            },
            'nameAsId': true
        };

        Wat.A.fillSelect(params);
        
        Wat.I.chosenElement('[name="di_tag"]', 'single100');
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');

        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        var user_id = context.find('select[name="user_id"]').val();
        var osf_id = context.find('select[name="osf_id"]').val();
        
        var arguments = {
            "propertyChanges" : properties.create,
            "blocked": blocked ? 1 : 0,
            "user_id": user_id,
            "osf_id": osf_id
        };
        
        var di_tag = context.find('select[name="di_tag"]').val();
        
        if (di_tag) {
            arguments.di_tag = di_tag;
        }
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            arguments["name"] = name;
        }
                                
        this.createModel(arguments);
    },
    
    startVM: function (filters) {        
        var messages = {
            'success': 'Successfully started',
            'error': 'Error starting VM'
        }
        
        Wat.A.performAction ('vm_start', {}, filters, messages, this.fetchList, this);
    },
    
    stopVM: function (filters) {        
        var messages = {
            'success': 'Successfully stopped',
            'error': 'Error stopping VM'
        }
        
        Wat.A.performAction ('vm_stop', {}, filters, messages, this.fetchList, this);
    },
    
    disconnectVMUser: function (filters) {        
        var messages = {
            'success': 'User successfully disconnected from VM',
            'error': 'Error disconnecting user from VM'
        }
        
        Wat.A.performAction ('vm_user_disconnect', {}, filters, messages, this.fetchList, this);
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
    
    
    setupMassiveChangesDialog: function (that) {
        Wat.A.performAction('osf_all_ids', {}, {"vm_id": that.selectedItems}, {}, that.openMassiveChangesDialog, that);
    },
    
    configureMassiveEditor: function (that) {
        // Virtual machine form include a date time picker control, so we need enable it
        Wat.I.enableDataPickers();
        
        var osfId = -1;
        // If there are returned more than 1 OSFs, it will restrict tag selection to head and default
        if(that.retrievedData.result.rows.length == 1) {
            osfId = that.retrievedData.result.rows[0];
            $('.js-advice-various-osfs').hide();
        }
        else {
            $('.js-advice-various-osfs').show();
        }

        var params = {
            'action': 'tag_tiny_list',
            'startingOptions': {
                '' : 'No changes',
                'default' : 'default',
                'head' : 'head'
            },
            'selectedId': '',
            'controlName': 'di_tag',
            'filters': {
                'osf_id': osfId
            },
            'nameAsId': true
        };


        Wat.A.fillSelect(params);

        Wat.I.chosenElement('[name="di_tag"]', 'single100');
        
    },
    
    updateMassiveElement: function (dialog, id) {
        var valid = Wat.Views.ListView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
        
        var arguments = {
            'propertyChanges' : properties
        };
        
        var context = $('.' + this.cid + '.editor-container');
        
        var di_tag = context.find('select[name="di_tag"]').val(); 
        
        var filters = {"id": id};
        
        if (di_tag != '') {
            arguments["di_tag"] = di_tag;
        }
        
        
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
        
        this.resetSelectedItems();
        
        var auxModel = new Wat.Models.VM();
        this.updateModel(arguments, filters, this.fetchList, auxModel);
    },
});