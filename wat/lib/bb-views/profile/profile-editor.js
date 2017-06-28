Wat.Views.ProfileEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'profile',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
    },
    
    updateElement: function (dialog) {
        var filters = {};
        var arguments = {};
        
        var context = $('.' + this.cid + '.editor-container');

        // If change password is checked
        if (context.find('input.js-change-password').is(':checked')) {
            var password = context.find('input[name="password"]').val();
            var password2 = context.find('input[name="password2"]').val();
            if (password && password2 && password == password2) {
                arguments['password'] = password;
            }
        }
        
        // Set language
        var language = context.find('select[name="language"]').val();
        arguments['language'] = language;
        
        // Set block size
        var block = context.find('select[name="block"]').val();
        arguments['block'] = block;
        
        // Store new language to make things after update
        Wat.CurrentView.newLanguage = language;
        Wat.CurrentView.newBlock = block;
        
        Wat.CurrentView.updateModel(arguments, filters, this.afterUpdateElement);
    },
    
    afterUpdateElement: function (that) {
        // If change is made succesfully check new language to ender again and translate
        if (that.retrievedData.status == STATUS_SUCCESS) {
            if (Wat.C.language != that.newLanguage) {
                Wat.C.language = that.newLanguage;
            }
            if (Wat.C.block != that.newBlock) {
                Wat.C.block = that.newBlock;
            }
            that.render();
            
            // Render footer to update translations if necessary
            Wat.I.renderFooter();
            
            Wat.T.initTranslate();
        }
    }
});