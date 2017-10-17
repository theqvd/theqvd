Wat.Collections.PluginEnums = Wat.Collections.DIG.extend({
    initialize: function (attrs, opts) {
        this.location = attrs.location;
        
        Wat.Collections.DIG.prototype.initialize.apply(this, [attrs]);
    },
    
    url: function () {
        var url = this.baseUrl() + this.location;
        
        return url;
    }
});