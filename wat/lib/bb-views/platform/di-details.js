Wat.Views.DIDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'di',
    relatedDoc: {
        image_update: "Images update guide"
    },
    
    initialize: function (params) {
        this.model = new Wat.Models.DI(params);
        
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        var sideCheck = this.checkSide({
            'di.see.vm-list': '.js-side-component1', 
            'di.see.log': '.js-side-component2', 
        });

        if (sideCheck === false) {
            return;
        }
        
        if (sideCheck['di.see.vm-list']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side1';

            // Render Virtual Machines list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer;
            params.forceListColumns = {name: true, tag: true};

            if (Wat.C.checkGroupACL('diVmEmbeddedInfo')) {
                params.forceListColumns['info'] = true;
            }

            // Check ACLs to show or not info icons in DIs list
            params.forceInfoRestrictions = {};
            if (Wat.C.checkACL('di.see.vm-list-block')) {
                params.forceInfoRestrictions.block = true;
            }
            if (Wat.C.checkACL('di.see.vm-list-expiration')) {
                params.forceInfoRestrictions.expiration = true;
            }
            if (Wat.C.checkACL('di.see.vm-list-state')) {
                params.forceInfoRestrictions.state = true;
            }
            if (Wat.C.checkACL('di.see.vm-list-user-state')) {
                params.forceInfoRestrictions.user_state = true;
            }

            params.forceSelectedActions = {};
            params.forceListActionButton = null;
            params.block = 5;
            params.filters = {"di_id": this.elementId};

            this.sideViews.push(new Wat.Views.VMListView(params));
        }
        
        if (sideCheck['di.see.log']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side2';

            // Render Related log list on side
            var params = this.getSideLogParams(sideContainer);

            this.sideViews.push(new Wat.Views.LogListView(params));
        
            this.renderLogGraph(params);
        }
    },
    
    applyDefault: function () {
        var arguments = {
            "__tags_changes__": {
                'create': ['default'],
            }
        }
        
        this.tagChanges = arguments['__tags_changes__'];

        this.updateModel(arguments, {id: this.elementId}, this.checkMachinesChanges);
    },
    
    render: function () {
        this.notFound = this.model.attributes.disk_image == undefined;
        
        Wat.Views.DetailsView.prototype.render.apply(this);        
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
    }
});