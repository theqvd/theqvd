Wat.Views.AdminEditorView = Wat.Views.AdministratorRoleEditorView.extend({
    qvdObj: 'administrator',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.AdministratorRoleEditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
        'change input[name="change_password"]': 'toggleNewPassword'
    },
    
    render: function (target, that) {
        Wat.Views.EditorView.prototype.render.apply(this, [target, that]);
        // If the field tenant is not present, fetch and render roles. Otherwise, this rendering will be done after tenant select filling

        this.fetchAndRenderRoles();
    },
    
    renderCreate: function (target, that) {
        Wat.CurrentView.model = new Wat.Models.Admin();
        $('.ui-dialog-title').html($.i18n.t('New Administrator'));
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
        
        Wat.I.chosenElement('[name="language"]', 'single100');
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-title').html($.i18n.t('Edit Administrator') + ": " + this.model.get('name'));

        Wat.I.chosenElement('[name="language"]', 'single100');
    },
    
    renderMassiveUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderMassiveUpdate.apply(this, [target, that]);
        
        // Empty roles from aux model to avoid show any role in massive editor
        if (Wat.CurrentView.model) {
            Wat.CurrentView.model.set('roles',{});
        }
        
        Wat.I.chosenElement('[name="language"]', 'single100');
        
        this.fetchAndRenderRoles();
    },
    
    fetchAndRenderRoles: function () {
        // If the field tenant is not present, fetch and render roles. Otherwise, this rendering will be done after tenant select filling
        if ($('[name="tenant_id"]').length > 0) {
            // When tenant id is present attach change events. Roles will be filled once the events were triggered
            Wat.B.bindEvent('change', 'select[name="tenant_id"]', function () {
                this.fetchAndRenderRoles({
                    forcedTenantId: $('select[name="tenant_id"]').val()
                });
            });
        }
        else {
            this.fetchAndRenderRoles({
                forcedTenantId: Wat.C.tenantID
            });
        }
    },
    
    createElement: function () {
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        var password = context.find('input[name="password"]').val();

        var args = {
            "name": name,
            "password": password,
        };
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            args["description"] = description;
        }
        
        if (Wat.C.checkACL('administrator.create.language')) { 
            var language = context.find('select[name="language"]').val();
            args["language"] = language;
        }
        
        if (Wat.C.isSuperadmin()) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            args['tenant_id'] = tenant_id;
        }
        
        if (Wat.C.checkACL('administrator.update.assign-role')) {
            if (this.assignRoles.length > 0) {
                args["__roles__"] = this.assignRoles;
            }
        }
        
        Wat.CurrentView.createModel(args, Wat.CurrentView.fetchList);
    },
    
    updateElement: function (dialog) {
        // If current view is list, use selected ID as update element ID
        if (Wat.CurrentView.viewKind == 'list') {
            Wat.CurrentView.id = Wat.CurrentView.selectedItems[0];
        }
        
        var filters = {"id": Wat.CurrentView.id};
        var args = {};
        
        var context = $('.' + this.cid + '.editor-container');

        if (Wat.C.checkACL('administrator.update.password')) {
            // If change password is checked
            if (context.find('input.js-change-password').is(':checked')) {
                var password = context.find('input[name="password"]').val();
                var password2 = context.find('input[name="password2"]').val();
                if (password && password2 && password == password2) {
                    args['password'] = password;
                }
            }
        }
        
        if (Wat.C.checkACL('administrator.update.language')) {
            var language = context.find('select[name="language"]').val();
            args['language'] = language;
        }
        
        if (Wat.C.checkACL('administrator.update.description')) {
            var description = context.find('textarea[name="description"]').val();
            args["description"] = description;
        }
        
        if (Wat.C.checkACL('administrator.update.assign-role')) {
            if (this.assignRoles.length > 0 || this.unassignRoles.length > 0) {
                args["__roles_changes__"] = {};
                
                if (this.assignRoles.length > 0) {
                    args["__roles_changes__"].assign_roles = this.assignRoles;
                }
                
                if (this.unassignRoles.length > 0) {
                    args["__roles_changes__"].unassign_roles = this.unassignRoles;
                }
            }
        }
        
        Wat.CurrentView.updateModel(args, filters, Wat.CurrentView.fetchAny);
    },
    
    updateMassiveElement: function (dialog, id) {
        var args = {};
        
        var context = $('.' + this.cid + '.editor-container');
        
        var description = context.find('textarea[name="description"]').val();
        var language = context.find('select[name="language"]').val(); 
        
        var filters = {"id": id};
        
        if (Wat.I.isMassiveFieldChanging("description") && Wat.C.checkACL('administrator.update.description')) {
            args["description"] = description;
        }
        
        if (language && Wat.C.checkACL('administrator.update.language')) {
            args["language"] = language;
        }
        
        if (Wat.C.checkACL('administrator.update.assign-role')) {
            if (this.assignRoles.length > 0 || this.unassignRoles.length > 0) {
                args["__roles_changes__"] = {};
                
                if (this.assignRoles.length > 0) {
                    args["__roles_changes__"].assign_roles = this.assignRoles;
                }
                
                if (this.unassignRoles.length > 0) {
                    args["__roles_changes__"].unassign_roles = this.unassignRoles;
                }
            }
        }
        
        Wat.CurrentView.assignRoles = Wat.CurrentView.unassignRoles = [];
        
        Wat.CurrentView.resetSelectedItems();
        
        var auxModel = new Wat.Models.Admin();
        Wat.CurrentView.updateModel(args, filters, Wat.CurrentView.fetchList, auxModel);
    },
    
    toggleNewPassword: function () {
        $('.new_password_row').toggle();
    }
});