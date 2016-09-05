// Common lib for Administrator views (list and details)
Wat.Common.BySection.administrator = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = Wat.I.T.getTemplateList('commonAdministrator');
        
        this.templates = $.extend({}, this.templates, templates);
        
        // Extend view with common methods with Role views
        $.extend(that, Wat.Common.BySection.administratorRole);
    },
    
    updateElement: function (dialog) {
        var that = that || this;
        
        // If current view is list, use selected ID as update element ID
        if (that.viewKind == 'list') {
            that.id = that.selectedItems[0];
        }
        
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var filters = {"id": this.id};
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
            if (that.assignRoles.length > 0 || that.unassignRoles.length > 0) {
                args["__roles_changes__"] = {};
                
                if (that.assignRoles.length > 0) {
                    args["__roles_changes__"].assign_roles = that.assignRoles;
                }
                
                if (that.unassignRoles.length > 0) {
                    args["__roles_changes__"].unassign_roles = that.unassignRoles;
                }
            }
        }
        
        this.updateModel(args, filters, this.fetchAny);
    },
    
    openEditElementDialog: function(e) {
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }
        
        this.dialogConf.title = $.i18n.t('Edit Administrator') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        Wat.I.chosenElement('[name="language"]', 'single100');
    },
    
    fillEditor: function (target, that) {
        Wat.Views.MainView.prototype.fillEditor.apply(this, [target, that]);
        that.fetchAndRenderRoles();
    },
}