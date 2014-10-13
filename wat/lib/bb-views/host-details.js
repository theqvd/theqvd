Wat.Views.HostDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'host',

    initialize: function (params) {
        this.model = new Wat.Models.Host(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        var sideContainer = '.' + this.cid + ' .bb-details-side1';
        
        // Render Virtual Machines list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer;
        params.forceListColumns = {checks: true, info: true, name: true};
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
        var arguments = {
            "__properties_changes__": properties,
            "name": name,
            "address": address
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