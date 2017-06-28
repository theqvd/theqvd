Wat.Views.TenantEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'tenant',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
    },
    
    renderCreate: function (target, that) {
        Wat.CurrentView.model = new Wat.Models.Tenant();
        $('.ui-dialog-title').html($.i18n.t('New Tenant'));
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
        
        Wat.I.chosenElement('[name="language"]', 'single100');
        Wat.I.chosenElement('[name="block"]', 'single100');
    },
    
    renderUpdate: function(target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-title').html($.i18n.t('Edit tenant') + ": " + this.model.get('name'));

        Wat.I.chosenElement('select[name="language"]', 'single100');
        Wat.I.chosenElement('select[name="block"]', 'single100');
    },
    
    createElement: function () {
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        var language = context.find('select[name="language"]').val(); 
        var block = context.find('select[name="block"]').val();
        
        var arguments = {
            "name": name,
            "block": block,
            "language": language
        };
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            arguments["description"] = description;
        }
                                
        Wat.CurrentView.createModel(arguments, Wat.CurrentView.fetchList);
    },
    
    updateElement: function (dialog) {
        // If current view is list, use selected ID as update element ID
        if (Wat.CurrentView.viewKind == 'list') {
            Wat.CurrentView.id = Wat.CurrentView.selectedItems[0];
        }
        
        var context = $('.' + this.cid + '.editor-container');
        
        var filters = {"id": Wat.CurrentView.id};
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
        
        Wat.CurrentView.oldLanguage = this.model.get('language');
        Wat.CurrentView.oldBlock = this.model.get('block');
        
        if (Wat.C.checkACL('tenant.update.language')) {
            arguments['language'] = language;
        }
        
        if (Wat.C.checkACL('role.update.description')) {
            arguments["description"] = description;
        }
        
        // Store new language to make things after update
        Wat.CurrentView.newLanguage = language;
        Wat.CurrentView.newBlock = block;
        
        Wat.CurrentView.updateModel(arguments, filters, this.afterUpdateElement);
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
});