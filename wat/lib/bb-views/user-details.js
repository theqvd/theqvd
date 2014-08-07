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
        
        // Render Virtual Machines list on side
        params.whatRender = 'list';
        params.listContainer = '.bb-details-side1';
        params.forceListColumns = {checks: true, info: true, name: true};
        params.forceSelectedActions = {disconnect: true};
        params.forceListActionButton = null;
        params.elementsBlock = 5;
        params.filters = {"user_id": params.id};
        
        var sideView = new Wat.Views.VMListView(params);
    },
    
    updateElement: function () {
        Wat.Views.DetailsView.prototype.updateElement.apply(this);
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
        
        var arguments = {'properties' : properties};
        
        var context = $('.' + this.cid + '.editor-container');
        
        // If change password is checked
        if (context.find('input.js-change-password').is(':checked')) {
            var password = context.find('input[name="password"]').val();
            var password2 = context.find('input[name="password2"]').val();
            if (!password || !password2) {
                console.log('password empty');
            }
            else if (password != password2) {
                console.log('password missmatch');
            }
            else {
                arguments['password'] = password;
            }
        }
        
        var blocked = $('input[name="blocked"][value=1]').is(':checked');
        
        arguments['blocked'] = blocked ? 1 : 0;
        
        // TODO: Send arguments to user_update function of API
    },
    
    render: function () {
        // Add name of the model to breadcrumbs
        this.breadcrumbs.next.next.screen = this.model.get('name');
        
        Wat.Views.DetailsView.prototype.render.apply(this);
        
        this.templateDetailsSide = this.getTemplate(this.detailsSideTemplateName);
        
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