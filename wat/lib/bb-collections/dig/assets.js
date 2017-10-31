Wat.Collections.Assets = Wat.Collections.DIG.extend({
    parse: function (response) {
        var that = this;
        
        $.each(response, function (i, asset) {
            response[i].url = that.baseUrl() + '/asset/' + asset.id + '/file';
        });
        
        return response;
    },
    
    initialize: function (attrs, opts) {
        opts = opts || {};
        
        this.filter = opts.filter;
        
        Wat.Collections.DIG.prototype.initialize.apply(this, [attrs]);
    },
    
    url: function () {
        var url = this.baseUrl() + '/asset';
        
        if (this.filter) {
            url += '?type=' + this.filter.type;
        }
        
        return url;
    }
});