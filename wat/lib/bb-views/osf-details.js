Wat.Views.OSFDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.model = new Wat.Models.OSF(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        var sideCheck = this.checkSide({'osf.see-details.vm-list': '.js-side-component1', 'osf.see-details.di-list': '.js-side-component2'});

        if (sideCheck === false) {
            return;
        }
        
        if (sideCheck['osf.see-details.vm-list']) { 
            var sideContainer1 = '.' + this.cid + ' .bb-details-side1';

            // Render Virtual Machines list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer1;
            params.forceListColumns = {info: true, name: true, tag: true};
            params.forceSelectedActions = {};
            params.forceListActionButton = null;
            params.block = 5;
            params.filters = {"osf_id": this.elementId};
            this.sideView2 = new Wat.Views.VMListView(params);
        }
        
        
        if (sideCheck['osf.see-details.di-list']) { 
            var sideContainer2 = '.' + this.cid + ' .bb-details-side2';

            // Render Disk images list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer2;
            params.forceListColumns = {info: true, disk_image: true, default: true};
            params.forceSelectedActions = {};
            params.forceListActionButton = null;
            params.block = 5;
            params.filters = {"osf_id": this.elementId};
            this.sideView2 = new Wat.Views.DIListView(params);  
        }
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
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        
        arguments = {
            __properties_changes__: properties,
            name: name,
            memory: memory,
            user_storage: user_storage
        };
        
        var filters = {"id": this.id};

        this.updateModel(arguments, filters, this.fetchDetails);
    },
    
    openEditElementDialog: function(e) {
        this.dialogConf.title = $.i18n.t('Edit OS Flavour') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
    }
});