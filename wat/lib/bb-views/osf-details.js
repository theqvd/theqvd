Wat.Views.OSFDetailsView = Wat.Views.DetailsView.extend({
    editorTemplateName: 'editor-osf',
    detailsTemplateName: 'details-osf',
    detailsSideTemplateName: 'details-osf-side',
    sideContainer: '.bb-details-side',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#/home',
        'next': {
            'screen': 'OSF list',
            'link': '#/osfs',
            'next': {
                'screen': ''
            }
        }
    },

    initialize: function (params) {
        this.model = new Wat.Models.OSF(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        var sideContainer1 = '.' + this.cid + ' .bb-details-side1';
        var sideContainer2 = '.' + this.cid + ' .bb-details-side2';
        
        // Render Virtual Machines list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer1;
        params.forceListColumns = {name: true, tag: true};
        params.forceSelectedActions = {};
        params.forceListActionButton = null;
        params.block = 5;
        params.filters = {"osf_id": this.elementId};
        this.sideView2 = new Wat.Views.VMListView(params);
        
        // Render Disk images list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer2;
        params.forceListColumns = {disk_image: true, default: true};
        params.forceSelectedActions = {};
        params.forceListActionButton = null;
        params.block = 5;
        params.filters = {"osf_id": this.elementId};
        this.sideView2 = new Wat.Views.DIListView(params);
        
        
    },
    
    updateElement: function (dialog) {
        Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
        
        var arguments = {'properties' : properties};
        
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        
        arguments['name'] = name;
        
        var memory = context.find('input[name="memory"]').val();
        
        arguments['memory'] = memory;
        
        var user_storage = context.find('input[name="user_storage"]').val();
        
        arguments['user_storage'] = user_storage;
        
        var filters = {"id": this.id};

        this.updateModel(arguments, filters);
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
    
    editElement: function(e) {
        this.dialogConf.title = $.i18n.t('Edit OS Flavour') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.editElement.apply(this, [e]);
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
    }
});