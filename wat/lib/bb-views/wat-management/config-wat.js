Wat.Views.ConfigWatView = Wat.Views.DetailsView.extend({  
    qvdObj: 'configwat',
    
    initialize: function () {
        // If user have not access to main section, redirect to home
        if (!Wat.C.checkACL('config.wat.')) {
            Wat.Router.app_router.trigger('route:defaultRoute');
            return;
        }
        
        var params = {id: Wat.C.tenantID};
        this.model = new Wat.Models.Tenant(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    setBreadCrumbs: function () {
        this.breadcrumbs = {
            'screen': 'Home',
            'link': '#',
            'next': {
                'screen': 'WAT Management',
                'next': {
                    'screen': 'WAT Config'
                }
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
        var block = context.find('select[name="block"]').val(); 
        
        this.oldLanguage = this.model.get('language');
        this.oldBlock = this.model.get('block');
        
        if (Wat.C.checkACL('config.wat.')) {
            arguments['language'] = language;
            arguments['block'] = block;
        }     
        
        // Check style customizer if is possible and modify cookie
        if (Wat.C.isSuperadmin() || !Wat.C.isMultitenant()) { 
            if ($('input[name="style-customizer"]').is(':checked')) {
                $.cookie('styleCustomizer', true, { expires: 7, path: '/' });
                Wat.I.C.initCustomizer();
            }
            else {
                $.removeCookie('styleCustomizer', { path: '/' });
                Wat.I.C.hideCustomizer();
            }
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
        if (that.retrievedData.status == STATUS_SUCCESS) {
            if (that.oldLanguage != that.newLanguage) {
                // If administratos has changed the language of his tenant and his language is default, translate interface
                if (Wat.C.language == 'default') {
                    Wat.C.tenantLanguage = that.newLanguage;
                    Wat.T.initTranslate();
                }
            }
            if (that.oldBlock != that.newBlock) {
                // If administratos has changed the language of his tenant and his language is default, translate interface
                if (Wat.C.block == 0) {
                    Wat.C.tenantBlock = that.newBlock;
                }
            }
        }
    },
    
    openEditElementDialog: function(e) {
        this.dialogConf.title = $.i18n.t('WAT Config');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        Wat.I.chosenElement('select[name="language"]', 'single100');
        Wat.I.chosenElement('select[name="block"]', 'single100');
    }
});