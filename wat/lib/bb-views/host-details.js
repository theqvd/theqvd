Wat.Views.HostDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'host',

    initialize: function (params) {
        this.model = new Wat.Models.Host(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        if (this.checkSide({'host.see.vm-list': '.js-side-component1'}) === false) {
            return;
        }
        
        var sideContainer = '.' + this.cid + ' .bb-details-side1';
        
        // Render Virtual Machines list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer;
        params.forceListColumns = {checks: true, name: true};

        if (Wat.C.checkGroupACL('hostVmEmbeddedInfo')) {
            params.forceListColumns['info'] = true;
        }

        // Check ACLs to show or not info icons in Hosts list
        params.forceInfoRestrictions = {};
        if (Wat.C.checkACL('host.see.vm-list-block')) {
            params.forceInfoRestrictions.block = true;
        }
        if (Wat.C.checkACL('host.see.vm-list-expiration')) {
            params.forceInfoRestrictions.expiration = true;
        }
        if (Wat.C.checkACL('host.see.vm-list-state')) {
            params.forceInfoRestrictions.state = true;
        }
        if (Wat.C.checkACL('host.see.vm-list-user-state')) {
            params.forceInfoRestrictions.user_state = true;
        }
        
        params.forceSelectedActions = {disconnect: true};
        params.forceListActionButton = null;
        params.block = 5;
        params.filters = {"host_id": this.elementId};
        
        this.sideView = new Wat.Views.VMListView(params);
    },
    
    updateElement: function (dialog) {
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var address = context.find('input[name="address"]').val();
        
        var filters = {"id": this.id};
        var arguments = {};
        
        if (Wat.C.checkACL('host.update.name')) {
            arguments['name'] = name;
        }        
        if (Wat.C.checkACL('host.update.address')) {
            arguments['address'] = address;
        }

        if (properties.delete.length > 0 || !$.isEmptyObject(properties.set)) {
            arguments["__properties_changes__"] = properties;
        }

        this.updateModel(arguments, filters, this.fetchDetails);
    },
    
    openEditElementDialog: function() {
        this.dialogConf.title = $.i18n.t('Edit host') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this);
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
    }
});