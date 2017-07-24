Wat.Views.OSDSettingsEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
    },
    
    render: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorSettings, {
                massive: this.massive,
                model: Wat.CurrentView.OSDmodel,
                cid: this.cid
            }
        );

        $('.bb-os-conf-settings').html(template);
    },
});