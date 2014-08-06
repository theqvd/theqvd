var UserDetailsView = DetailsView.extend({
    editorTemplateName: 'editor-user',
    detailsTemplateName: 'details-user',
    detailsSideTemplateName: 'details-user-side',
    sideContainer: '.bb-details-side',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#/home',
        'next': {
            'screen': 'User list',
            'link': '#/users',
            'next': {
                'screen': ''
            }
        }
    },
    
    editorDialogTitle: function () {
        return $.i18n.t('Edit user') + ": " + this.model.get('name');
    },


    initialize: function (params) {
        this.model = new User(params);
        DetailsView.prototype.initialize.apply(this, [params]);
        //_.extend(this.events, DetailsView.prototype.events);
        
        // Render Virtual Machines list on side
        params.whatRender = 'list';
        params.listContainer = '.bb-details-side1';
        params.forceListColumns = {checks: true, info: true, name: true};
        params.forceSelectedActions = {disconnect: true};
        params.forceListActionButton = null;
        params.elementsBlock = 5;
        
        var sideView = new VMListView(params);
    },
    
    render: function () {
        // Add name of the model to breadcrumbs
        this.breadcrumbs.next.next.screen = this.model.get('name');
        
        DetailsView.prototype.render.apply(this);
        
        this.templateDetailsSide = this.getTemplate(this.detailsSideTemplateName);
        
        this.template = _.template(
            this.templateDetailsSide, {
                model: this.model
            }
        );
        
        $(this.sideContainer).html(this.template);
    },
    
    editElement: function() {
        DetailsView.prototype.editElement.apply(this);
    },
    
    bindEditorEvents: function() {
        DetailsView.prototype.bindEditorEvents.apply(this);
        
        // Toggle controls for new password
        this.bindEvent('change', 'input[name="change_password"]', this.userEditorBinds.toggleNewPassword);
    },
    
    userEditorBinds: {
        toggleNewPassword: function () {
            $('.new_password_row').toggle();
        }
    }
});