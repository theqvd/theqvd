Wat.Views.DIDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'di',
    
    initialize: function (params) {
        this.model = new Wat.Models.DI(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        if (this.checkSide({'di.see.vm-list': '.js-side-component1'}) === false) {
            return;
        }
        
        var sideContainer = '.' + this.cid + ' .bb-details-side1';
        
        // Render Virtual Machines list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer;
        params.forceListColumns = {name: true, tag: true};
        params.forceSelectedActions = {};
        params.forceListActionButton = null;
        params.block = 5;
        params.filters = {"di_id": this.elementId};
        
        this.sideView = new Wat.Views.VMListView(params);
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
        var def = context.find('input[name="default"][value=1]').is(':checked');
        
        // If we set default (only if the DI wasn't default), add this tag
        if (def && !this.model.get('default')) {
            tags += ',default';
        }
                
        var baseTags = this.model.attributes.tags ? this.model.attributes.tags.split(',') : [];
        var newTags = tags ? tags.split(',') : [];
        var keepedTags = _.intersection(baseTags, newTags);
        
        var createdTags = _.difference(newTags, keepedTags);
        var deletedTags = _.difference(baseTags, keepedTags);
        
        var filters = {"id": this.id};
        var arguments = {
            "__properties_changes__": properties,
            "__tags_changes__": {
                'create': createdTags,
                'delete': deletedTags
            },
            
        };
        
        this.updateModel(arguments, filters, this.fetchDetails);
    },
    
    render: function () {
        // Add name of the image disk to breadcrumbs because in this case is not 'name'
        this.breadcrumbs.next.next.screen = this.model.get('disk_image');
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