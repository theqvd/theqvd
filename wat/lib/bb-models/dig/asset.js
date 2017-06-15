Wat.Models.Asset = Wat.Models.DIG.extend({
    defaults: {
    },
    
    parse: function(response) {
        response.id = this.id;
        response.name = 'Ball';
        response.type = 'wallpaper';
        response.url = 'http://www.planwallpaper.com/static/images/6768666-1080p-wallpapers.jpg';
        return response;
    },
    
    initialize: function (params) {
        if (params !== undefined) {
            this.id = params.id;
        }
    },
    
    url: function () {
        var url = this.baseUrl() + '/osd';
        
        return url;
    }
});