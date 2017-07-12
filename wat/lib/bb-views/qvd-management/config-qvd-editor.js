Wat.Views.ConfigQVDEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'config',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
    },
    
    // Create new token
    createElement: function () {
        var context = $('.' + this.cid + '.editor-container');

        var key = context.find('input[name="key"]').val();
        var value = context.find('input[name="value"]').val();

        var arguments = {
            "key": key,
            "value": value
        };

        Wat.CurrentView.createdKey = key;

        if (Wat.C.isSuperadmin()) {
            arguments['tenant_id'] = Wat.CurrentView.selectedTenant;
        }

        Wat.A.performAction('config_set', arguments, {}, {'error': i18n.t('Error creating'), 'success': i18n.t('Successfully created')}, this.afterCreateToken, Wat.CurrentView);
    },

    // Hook executed after create token (executed before change hook)
    afterCreateToken: function (that) {
        var keySplitted = that.createdKey.split('.');
        
        if (keySplitted.length > 1) {
            that.currentTokensPrefix = keySplitted[0];
        }
        else {
            that.currentTokensPrefix = UNCLASSIFIED_CONFIG_CATEGORY;
        }
        
        that.selectPrefixMenu(that.currentTokensPrefix);

        that.afterChangeToken(that);
    },
});