Wat.Models.AssetFile = Wat.Models.DIG.extend({
    defaults: {
    },
    
    parse: function(response) {
        return $.extend({}, response, this.mock(response));
    },
    
    mock: function (response) {
        var asset = {
            id: this.id,
            name: 'Ball',
            type: 'wallpaper',
            url: 'http://www.planwallpaper.com/static/images/6768666-1080p-wallpapers.jpg'
        }
        
        return asset;
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