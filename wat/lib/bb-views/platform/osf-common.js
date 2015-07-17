// Common lib for OSF views (list and details)
Wat.Common.BySection.osf = {
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
        
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(that, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = that.properties;
        
        var context = $('.' + that.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();        
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        var description = context.find('textarea[name="description"]').val();

        arguments = {};
        
        if (Wat.C.checkACL('osf.update.name')) {
            arguments['name'] = name;
        }        
        
        if (Wat.C.checkACL('osf.update.memory')) {
            arguments['memory'] = memory;
        }   
        
        if (Wat.C.checkACL('osf.update.user-storage')) {
            arguments['user_storage'] = user_storage;
        }
        
        if (properties.delete.length > 0 || !$.isEmptyObject(properties.set)) {
            arguments["__properties_changes__"] = properties;
        }
            
        if (Wat.C.checkACL('osf.update.description')) {
            arguments["description"] = description;
        }
        
        var filters = {"id": that.id};

        that.updateModel(arguments, filters, that.fetchAny);
    },
    
    openEditElementDialog: function(e) {
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }   
                
        this.dialogConf.title = $.i18n.t('Edit OS Flavour') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
    },
}