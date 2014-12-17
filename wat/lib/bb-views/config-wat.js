Wat.Views.ConfigWatView = Wat.Views.DetailsView.extend({  
    qvdObj: 'configwat',
    
    initialize: function () {
        var params = {id: Wat.C.tenantID};
        this.model = new Wat.Models.Tenant(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    setBreadCrumbs: function () {
        this.breadcrumbs = {
            'screen': 'Home',
            'link': '#',
            'next': {
                'screen': 'WAT Config'
            }
        };
    },
    
    setViewACL: function () {
        this.viewACL = 'config.wat.';
    },
    
    updateElement: function (dialog) {        
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var context = $('.' + this.cid + '.editor-container');
                        
        var filters = {"id": Wat.C.tenantID};
        var arguments = {};
        
        var language = context.find('select[name="language"]').val(); 
        
        this.oldLanguage = this.model.get('language');
        
        if (Wat.C.checkACL('config.wat.')) {
            arguments['language'] = language;
        }     
        
        // Store new language to make things after update
        this.newLanguage = language;
        
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
        if (that.retrievedData.status == STATUS_SUCCESS && that.oldLanguage != that.newLanguage) {
            // If administratos has changed the language of his tenant and his language is default, translate interface
            if (Wat.C.language == 'default') {
                Wat.T.initTranslate();
            }
        }
    },
    
    openEditElementDialog: function(e) {
        this.dialogConf.title = $.i18n.t('WAT Config');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
    }
});