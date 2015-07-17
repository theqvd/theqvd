// Common lib for Administrator views (list and details)
Wat.Common.BySection.administrator = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        // Empty
    },
    
    updateElement: function (dialog) {
        var that = that || this;
        
        if (that.viewKind == 'list') {
            that.id = that.selectedItems[0];
        }
        
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var filters = {"id": this.id};
        var arguments = {};
        
        var context = $('.' + this.cid + '.editor-container');

        if (Wat.C.checkACL('administrator.update.password')) {
            // If change password is checked
            if (context.find('input.js-change-password').is(':checked')) {
                var password = context.find('input[name="password"]').val();
                var password2 = context.find('input[name="password2"]').val();
                if (password && password2 && password == password2) {
                    arguments['password'] = password;
                }
            }
        }
        
        if (Wat.C.checkACL('administrator.update.language')) {
            var language = context.find('select[name="language"]').val();
            arguments['language'] = language;
        }
        
        if (Wat.C.checkACL('administrator.update.description')) {
            var description = context.find('textarea[name="description"]').val();
            arguments["description"] = description;
        }
        
        this.updateModel(arguments, filters, this.fetchAny);
    },
    
    openEditElementDialog: function(e) {
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }
        
        this.dialogConf.title = $.i18n.t('Edit Administrator') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        Wat.I.chosenElement('[name="language"]', 'single100');
    },
}