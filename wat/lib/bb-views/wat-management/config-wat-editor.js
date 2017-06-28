Wat.Views.ConfigWatEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'configwat',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-title').html($.i18n.t('WAT Config'));
        
        Wat.I.chosenElement('select[name="language"]', 'single100');
        Wat.I.chosenElement('select[name="block"]', 'single100');
    },
    
    updateElement: function (dialog) {
        var context = $('.' + this.cid + '.editor-container');
        
        var filters = {};
        var arguments = {};
        
        var language = context.find('select[name="language"]').val(); 
        var block = context.find('select[name="block"]').val(); 
        
        this.oldLanguage = Wat.CurrentView.model.get('language');
        this.oldBlock = Wat.CurrentView.model.get('block');
        
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
        Wat.CurrentView.newLanguage = language;
        Wat.CurrentView.newBlock = block;
        
        Wat.CurrentView.updateModel(arguments, filters, this.afterUpdateElement);
    },
    
    afterUpdateElement: function (that) {
        that.fetchDetails();

        // If change is made succesfully check new language to ender again and translate
        if (that.retrievedData.status == STATUS_SUCCESS) {
            if (that.oldLanguage != that.newLanguage) {
                Wat.C.tenantLanguage = that.newLanguage;
                
                // If administratos has changed the language of his tenant and his language is default, translate interface
                if (Wat.C.language == 'default') {
                    Wat.T.initTranslate();
                }
            }
            if (that.oldBlock != that.newBlock) {
                // If administratos has changed the block size of his tenant and his language is default, translate interface
                if (Wat.C.block == 0) {
                    Wat.C.tenantBlock = that.newBlock;
                }
            }
            
            // Render footer to update translations if necessary
            Wat.I.renderFooter();
        }
    }
});