Wat.Views.OSDSettingsEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'change input[type="checkbox"][js-vma-field]': 'updateVmaValue'
    },
    
    render: function () {
        var that = this;
        
        Wat.CurrentView.OSDmodel.pluginData.vma.fetch({
            success: function () {
                var template = _.template(
                    Wat.TPL.osConfigurationEditorSettings, {
                        massive: this.massive,
                        vmaModel: Wat.CurrentView.OSDmodel.pluginData.vma,
                        cid: that.cid
                    }
                );

                $('.bb-os-conf-settings').html(template);
            }
        });
    },
    
    updateVmaValue: function (e) {
        var that = this;
        
        var pluginId = $(e.target).attr('data-plugin-id');
        
        var pluginFields = $('[js-vma-field][data-plugin-id="' + pluginId + '"]');
        
        var attributes = {};
        $.each(pluginFields, function (i, field) {
            attributes[$(field).attr('name')] = $(field).is(':checked');
        });
        
        Wat.DIG.setPluginAttr({
            pluginId: pluginId,
            attributes: attributes
        }, this.afterUpdateVmaValue, function () {});
    },
    
    afterUpdateVmaValue: function (e) {
        var response = JSON.parse(e.responseText);
        
        Wat.I.M.showMessage({message: i18n.t('Successfully updated'), messageType: 'success'});
    }
});