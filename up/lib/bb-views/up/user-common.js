// Common lib for User views (list and details)
Up.Common.BySection.user = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        // Empty
    },
    
    updateElement: function (dialog) {
        var that = that || this;
        
        // If current view is list, use selected ID as update element ID
        if (that.viewKind == 'list') {
            that.id = that.selectedItems[0];
        }
        
        var valid = Up.Views.DetailsView.prototype.updateElement.apply(that, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = that.properties;
        
        var arguments = {'properties' : properties};
        
        var context = $('.' + that.cid + '.editor-container');
        
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": that.id};
        var arguments = {};
        
        if (!$.isEmptyObject(properties.set) && Up.C.checkACL('user.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        if (Up.C.checkACL('user.update.password')) {
            // If change password is checked
            if (context.find('input.js-change-password').is(':checked')) {
                var password = context.find('input[name="password"]').val();
                var password2 = context.find('input[name="password2"]').val();
                if (password && password2 && password == password2) {
                    arguments['password'] = password;
                }
            }
        }
        
        if (Up.C.checkACL('user.update.description')) {
            arguments["description"] = description;
        }
        
        //that.updateModel(arguments, filters, that.fetchDetails);
        that.updateModel(arguments, filters, that.fetchAny);
    },
    
    openEditElementDialog: function(e) {
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }   
        
        this.dialogConf.title = $.i18n.t('Edit user') + ": " + this.model.get('name');
        
        Up.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
    },
}