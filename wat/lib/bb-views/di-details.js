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

            this.sideView = new Wat.Views.VMListView(params);
        }
        
        if (sideCheck['di.see.log']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side2';

            // Render Related log list on side
            var params = this.getSideLogParams(sideContainer);

            this.sideView = new Wat.Views.LogListView(params);
        }
    },
    
    applyDefault: function () {
        var arguments = {
            "__tags_changes__": {
                'create': ['default'],
            }
        }
        
        this.updateModel(arguments, {id: this.elementId}, this.fetchDetails);
    },
    
    updateElement: function (dialog) {
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');
                        
        var tags = context.find('input[name="tags"]').val();
        var newTags = tags && Wat.C.checkACL('di.update.tags') ? tags.split(',') : [];

        var def = context.find('input[name="default"][value=1]').is(':checked');
        
        // If we set default (only if the DI wasn't default), add this tag
        if (def && !this.model.get('default') && Wat.C.checkACL('di.update.default')) {
            newTags.push('default');
        }
                
        var baseTags = this.model.attributes.tags ? this.model.attributes.tags.split(',') : [];
        var keepedTags = _.intersection(baseTags, newTags);
        
        var createdTags = _.difference(newTags, keepedTags);
        var deletedTags = _.difference(baseTags, keepedTags);
        
        var filters = {"id": this.id};
        var arguments = {};
        
        if (Wat.C.checkACL('di.update.tags') || Wat.C.checkACL('di.update.default')) {
            arguments['__tags_changes__'] = {
                'create': createdTags,
                'delete': deletedTags
            };
        }
        
        if (properties.delete.length > 0 || !$.isEmptyObject(properties.set)) {
            arguments["__properties_changes__"] = properties;
        }
        
        this.updateModel(arguments, filters, this.fetchDetails);
    },
    
    render: function () {
        this.notFound = this.model.attributes.disk_image == undefined;
        
        Wat.Views.DetailsView.prototype.render.apply(this);        
    },
    
    openEditElementDialog: function(e) {
        this.dialogConf.title = $.i18n.t('Disk image') + ": " + this.model.get('disk_image');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        // Configure tags inputs
        Wat.I.tagsInputConfiguration();
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
    }
});