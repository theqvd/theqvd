var VMDetailsView = DetailsView.extend({
    editorTemplateName: 'editor-vm',
    detailsTemplateName: 'details-vm',
    detailsSideTemplateName: 'details-vm-side',
    sideContainer: '.bb-details-side',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#/home',
        'next': {
            'screen': 'Virtual machine list',
            'link': '#/vms',
            'next': {
                'screen': ''
            }
        }
    },
    
    editorDialogTitle: function () {
        return $.i18n.t('Edit Virtual machine') + ": " + this.model.get('name');
    },


    initialize: function (params) {
        this.model = new VM(params);
        DetailsView.prototype.initialize.apply(this, [params]);
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
        this.bindEvent('change', 'input[name="change_password"]', this.vmEditorBinds.toggleNewPassword);
    },
    
    vmEditorBinds: {
        toggleNewPassword: function () {
            $('.new_password_row').toggle();
        }
    }
});