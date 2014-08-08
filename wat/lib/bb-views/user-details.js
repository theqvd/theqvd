Wat.Views.UserDetailsView = Wat.Views.DetailsView.extend({
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
        this.model = new Wat.Models.User(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
        //_.extend(this.events, DetailsView.prototype.events);
        
        this.renderSide();
    },
    
    renderSide: function () {
        // Render Virtual Machines list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = '.bb-details-side1';
        params.forceListColumns = {checks: true, info: true, name: true};
        params.forceSelectedActions = {disconnect: true};
        params.forceListActionButton = null;
        params.elementsBlock = 5;
        params.filters = {"user_id": this.elementId};
        
        this.sideView = new Wat.Views.VMListView(params);
    },
    
    updateElement: function (dialog) {
        Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
        
        var arguments = {'properties' : properties};
        
        var context = $('.' + this.cid + '.editor-container');
        
        // If change password is checked
        if (context.find('input.js-change-password').is(':checked')) {
            var password = context.find('input[name="password"]').val();
            var password2 = context.find('input[name="password2"]').val();
            if (!password || !password2) {
                console.error('password empty');
            }
            else if (password != password2) {
                console.error('password missmatch');
            }
            else {
                arguments['password'] = password;
            }
        }
        
        var blocked = $('input[name="blocked"][value=1]').is(':checked');
        
        arguments['blocked'] = blocked ? 1 : 0;
        
        var filters = {"id": this.id};
        
        Wat.A.performAction('update_user', filters, arguments);
        
        this.fetchDetails();
        this.renderSide();
        
        dialog.dialog('close');
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
    
    editElement: function() {
        Wat.Views.DetailsView.prototype.editElement.apply(this);
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
        
        // Toggle controls for new password
        this.bindEvent('change', 'input[name="change_password"]', this.userEditorBinds.toggleNewPassword);
    },
    
    userEditorBinds: {
        toggleNewPassword: function () {
            $('.new_password_row').toggle();
        }
    }
});