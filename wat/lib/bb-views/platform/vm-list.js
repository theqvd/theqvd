Wat.Views.VMListView = Wat.Views.ListView.extend({  
    qvdObj: 'vm',
    liveFields: ['state', 'user_state', 'ip', 'host_id', 'host_name', 'ssh_port', 'vnc_port', 'serial_port', 'expiration_soft', 'expiration_hard', 'time_until_expiration_soft', 'time_until_expiration_hard'],
    
    relatedDoc: {
        image_update: "Images update guide",
        full_vm_creation: "Create a virtual machine from scratch",
    },
    
    initialize: function (params) {   
        this.collection = new Wat.Collections.VMs(params);
        
        var templates = Wat.I.T.getTemplateList('vmList');
        Wat.A.getTemplates(templates, function () {});
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    renderList: function () {
        Wat.Views.ListView.prototype.renderList.apply(this, []);
        
        if (Wat.C.checkACL('vm.see.expiration')) {
            $.each($('.bb-vm-list-expiration'), function (iCell, cell) {
                var expirationType = typeof $(cell).attr('data-expiration_soft') == "undefined" ? 'hard' : 'soft';
                var id = $(cell).attr('data-id');
                var model = Wat.CurrentView.collection.where({id: parseInt(id)})[0];
                
                if (model.get('expiration_' + expirationType)) {
                    var template = _.template(
                            Wat.TPL.vmListExpiration, {
                                expiration: Wat.U.databaseDateToString(model.get('expiration_' + expirationType)),
                                remainingTime: Wat.U.processRemainingTime(model.get('time_until_expiration_' + expirationType)),
                                time_until_expiration_raw: Wat.U.base64.encodeObj(model.get('time_until_expiration_' + expirationType)),
                            }
                        );
                    
                    $(cell).html(template);
                }
            });
            
            Wat.T.translate();
        }
    },
    
    // This events will be added to view events
    listEvents: {},
    
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
    
    
    setupMassiveChangesDialog: function (that) {
        // If the edition is performed over one single element, call single editor
        if (that.selectedItems.length == 1) {
            that.editingFromList = true;
            this.openEditElementDialog(that);
            return;
        }
        
        Wat.A.performAction('osf_all_ids', {}, {"vm_id": that.selectedItems}, {}, that.openMassiveChangesDialog, that);
    },
    
    // Extend massive configurator to fill Tag select on virtual machines
    configureMassiveEditor: function (that) {
        Wat.Views.ListView.prototype.configureMassiveEditor.apply(this, [that]);
        
        // Virtual machine form include a date time picker control, so we need enable it
        Wat.I.enableDataPickers();
        
        var osfId = FILTER_ALL;
        // If there are returned more than 1 OSFs, it will restrict tag selection to head and default
        if($.unique(that.retrievedData.rows).length == 1) {
            osfId = that.retrievedData.rows[0];
            $('.js-advice-various-osfs').hide();
        }
        else {
            $('.js-advice-various-osfs').show();
        }
        
        var params = {
            'actionAuto': 'tag',
            'startingOptions': {
                '' : $.i18n.t('No changes'),
                'default' : 'default',
                'head' : 'head'
            },
            'selectedId': '',
            'controlName': 'di_tag',
            'filters': {
                'osf_id': osfId
            },
            'nameAsId': true,
            'chosenType': 'advanced100'
        };
        
        Wat.A.fillSelect(params);
    },
});