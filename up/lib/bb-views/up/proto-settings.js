Up.Views.SettingsProtoView = Up.Views.ListView.extend({      
    
    initialize: function (params) {
        Up.Views.MainView.prototype.initialize.apply(this, [params]);
    },
    
    // Render edition
    renderEditionMode: function (model, target) {
        // List of settings
        this.template = _.template(
            Up.TPL.settingsDetails, {
                cid: this.cid,
                name: model.get('name'),
                settings: model.get('settings'),
                nameEditable: !model.get('systemWS')
            }
        );
        
        target.html(this.template);
        
        Up.I.chosenElement($('select[name="connection_type"]'), 'single100');
    },
});