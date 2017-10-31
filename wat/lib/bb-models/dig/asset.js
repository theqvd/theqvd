Wat.Models.Asset = Wat.Models.DIG.extend({
    defaults: {
    },
    
    initialize: function (params) {
        if (params !== undefined) {
            this.id = params.id;
        }
        
        this.urlRoot = this.baseUrl() + '/asset';
    }
});