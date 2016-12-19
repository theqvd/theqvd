// Common lib for Tenant views (list and details)
Wat.Common.BySection.tenant = {
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
                   
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var context = $('.' + this.cid + '.editor-container');
                        
        var filters = {"id": this.id};
        var arguments = {};
        
        
        var name = context.find('input[name="name"]').val();
        var language = context.find('select[name="language"]').val(); 
        var block = context.find('select[name="block"]').val();
        var description = context.find('textarea[name="description"]').val();
        
        if (Wat.C.checkACL('tenant.update.name')) {
            arguments['name'] = name;
        }     
        
        if (Wat.C.checkACL('tenant.update.blocksize')) {
            arguments['block'] = block;
        }    
        
        this.oldLanguage = this.model.get('language');
        this.oldBlock = this.model.get('block');
        
        if (Wat.C.checkACL('tenant.update.language')) {
            arguments['language'] = language;
        }     
        
        if (Wat.C.checkACL('role.update.description')) {
            arguments["description"] = description;
        }
        
        // Store new language to make things after update
        this.newLanguage = language;
        this.newBlock = block;
        
        this.updateModel(arguments, filters, this.afterUpdateElement);
    },
    
    openEditElementDialog: function(e) {
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }   
        
        this.dialogConf.title = $.i18n.t('Edit tenant') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        Wat.I.chosenElement('select[name="language"]', 'single100');
        Wat.I.chosenElement('select[name="block"]', 'single100');
    },
    
    afterUpdateElement: function (that) {
        that.fetchAny(that);

        // If change is made succesfully check new language to ender again and translate
        if (that.retrievedData.status == STATUS_SUCCESS && Wat.C.tenantID == that.model.get('id')) {
            // If administratos has changed the language of his tenant and his language is default, translate interface
            if (that.oldLanguage != that.newLanguage) {
                if (Wat.C.language == 'default') {
                    Wat.C.tenantLanguage = that.newLanguage;
                    Wat.T.initTranslate();
                }
            }
            if (that.oldBlock != that.newBlock) {
                Wat.C.tenantBlock = that.newBlock;
            }
        }
    }
}