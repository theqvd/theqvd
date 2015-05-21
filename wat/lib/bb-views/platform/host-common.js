// Common lib for Host views (list and details)
Wat.Common.BySection.host = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        // Empty
    },
    
    updateElement: function (dialog) {
        var that = that || this;
        that.id = that.id || that.selectedItems[0];
        
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(that, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = that.properties;
                
        var context = $('.' + that.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var address = context.find('input[name="address"]').val();
        
        var filters = {"id": that.id};
        var arguments = {};
        
        if (Wat.C.checkACL('host.update.name')) {
            arguments['name'] = name;
        }        
        if (Wat.C.checkACL('host.update.address')) {
            arguments['address'] = address;
        }

        if (properties.delete.length > 0 || !$.isEmptyObject(properties.set)) {
            arguments["__properties_changes__"] = properties;
        }

        that.updateModel(arguments, filters, that.fetchAny);
    },
    
    openEditElementDialog: function() {
        this.model = this.model || this.collection.where({id: this.selectedItems[0]})[0];
        
        this.dialogConf.title = $.i18n.t('Edit node') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this);
    },
}