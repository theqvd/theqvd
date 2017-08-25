Wat.Models.Package = Wat.Models.DIG.extend({
    defaults: {
    },
    
    initialize: function (params) {
        this.urlRoot = this.baseUrl() + '/osd/' + Wat.CurrentView.OSDmodel.id + '/pkg';
    }
});