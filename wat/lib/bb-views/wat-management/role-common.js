// Common lib for Role views (list and details)
Wat.Common.BySection.role = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        // Empty
    },
    
    updateElement: function (dialog) {
        var that = that || this;
        that.id = that.id || that.selectedItems[0];
        
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": this.id};
        var arguments = {};
        
        if (Wat.C.checkACL('role.update.name')) {
            arguments['name'] = name;
        }
        
        if (Wat.C.checkACL('role.update.description')) {
            arguments["description"] = description;
        }
        
        this.updateModel(arguments, filters, this.fetchAny);
    },
    
    openEditElementDialog: function(e) {
        this.model = this.model || this.collection.where({id: this.selectedItems[0]})[0];
        
        this.dialogConf.title = $.i18n.t('Edit Role') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
    },
}