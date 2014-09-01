Wat.Views.DIDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'di',
    editorTemplateName: 'editor-di',
    detailsTemplateName: 'details-di',
    detailsSideTemplateName: 'details-di-side',
    sideContainer: '.bb-details-side',
    
    initialize: function (params) {
        this.model = new Wat.Models.DI(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
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
    
    updateElement: function (dialog) {
        Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');
        
        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
                
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
            "properties": properties,
            "blocked": blocked ? 1 : 0,
            "tags": {
                'create': createdTags,
                'delete': deletedTags
            },
            
        };
        
        this.updateModel(arguments, filters, this.fetchDetails);
    },
    
    render: function () {
        // Add name of the model to breadcrumbs
        this.breadcrumbs.next.next.screen = this.model.get('name');
        
        Wat.Views.DetailsView.prototype.render.apply(this);
        
        this.templateDetailsSide = Wat.A.getTemplate(this.detailsSideTemplateName);
        
        this.template = _.template(
            this.templateDetailsSide, {
                model: this.model
            }
        );
        
        $(this.sideContainer).html(this.template);
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