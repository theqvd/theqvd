Wat.Models.AssetFile = Wat.Models.DIG.extend({
    defaults: {
    },
    
    initialize: function (params) {
        if (params !== undefined) {
            this.id = params.id;
        }
    },
    
    url: function () {
        var url = this.baseUrl() + '/asset/' + this.id + '/file';
        
        return url;
    },
    
    save: function(attributes, options) { 
        options = {
            processData: false,
            contentType: false,
            data: attributes.data
        };
        
        return Backbone.Model.prototype.save.call(this, attributes, options);
    }
});