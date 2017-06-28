Wat.Views.UserEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'user',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
        'change input[name="change_password"]': 'toggleNewPassword'
    },
    
    renderCreate: function (target, that) {
        Wat.CurrentView.model = new Wat.Models.User();
        $('.ui-dialog-title').html($.i18n.t('New User'));
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-title').html($.i18n.t('Edit user') + ": " + this.model.get('name'));
    },
    
    createElement: function () {
        var properties = this.parseProperties('create');
        
        var context = $('.' + this.cid + '.editor-container');

        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        
        var arguments = {
            "blocked": blocked ? 1 : 0
        };
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('user.create.properties')) {
            arguments["__properties__"] = properties.set;
        }
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            arguments["name"] = name;
        }
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            arguments["description"] = description;
        }
        
        var password = context.find('input[name="password"]').val();
        var password2 = context.find('input[name="password2"]').val();
        if (password && password2 && password == password2) {
            arguments['password'] = password;
        }
        
        if (Wat.C.isSuperadmin()) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            arguments['tenant_id'] = tenant_id;
        }
        
        Wat.CurrentView.createModel(arguments, Wat.CurrentView.fetchList);
    },
    
    updateElement: function (dialog) {
        // If current view is list, use selected ID as update element ID
        if (Wat.CurrentView.viewKind == 'list') {
            Wat.CurrentView.id = Wat.CurrentView.selectedItems[0];
        }
        
        var properties = this.parseProperties('update');
        
        var arguments = {'properties' : properties};
        
        var context = $('.' + this.cid + '.editor-container');
        
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": Wat.CurrentView.id};
        var arguments = {};
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('user.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        if (Wat.C.checkACL('user.update.password')) {
            // If change password is checked
            if (context.find('input.js-change-password').is(':checked')) {
                var password = context.find('input[name="password"]').val();
                var password2 = context.find('input[name="password2"]').val();
                if (password && password2 && password == password2) {
                    arguments['password'] = password;
                }
            }
        }
        
        if (Wat.C.checkACL('user.update.description')) {
            arguments["description"] = description;
        }
        
        Wat.CurrentView.updateModel(arguments, filters, Wat.CurrentView.fetchAny);
    },
    
    toggleNewPassword: function () {
        $('.new_password_row').toggle();
    }
});