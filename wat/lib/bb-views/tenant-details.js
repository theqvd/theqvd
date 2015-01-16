Wat.Views.TenantDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'tenant',

    initialize: function (params) {
        this.model = new Wat.Models.Tenant(params);
        
        this.setBreadCrumbs();
       
        // Clean previous item name
        this.breadcrumbs.next.next.next.screen="";
        
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    updateElement: function (dialog) {        
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
        
        if (Wat.C.checkACL('tenant.update.name')) {
            arguments['name'] = name;
        }     
        
        if (Wat.C.checkACL('tenant.update.block')) {
            arguments['block'] = block;
        }    
        
        this.oldLanguage = this.model.get('language');
        this.oldBlock = this.model.get('block');
        
        if (Wat.C.checkACL('tenant.update.language')) {
            arguments['language'] = language;
        }     
        
        // Store new language to make things after update
        this.newLanguage = language;
        this.newBlock = block;
        
        this.updateModel(arguments, filters, this.afterUpdateElement);
    },
    
    renderSide: function () {
        // No side rendered
        if (this.checkSide({'fake.acl': '.js-side-component1'}) === false) {
            return;
        }
    },
    
    afterUpdateElement: function (that) {
        that.fetchDetails();

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
    },
    
    openEditElementDialog: function(e) {
        this.dialogConf.title = $.i18n.t('Edit tenant') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        Wat.I.chosenElement('select[name="language"]', 'single');
        Wat.I.chosenElement('select[name="block"]', 'single');
    }
});