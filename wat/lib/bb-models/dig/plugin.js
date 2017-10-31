Wat.Models.Plugin = Wat.Models.DIG.extend({
    defaults: {
    },
    
    initialize: function (attrs, opts) {
        this.pluginId = opts.pluginId;
        this.osdId = opts.osdId;
        
        Wat.Models.DIG.prototype.initialize.apply(this, [attrs]);
        
        this.urlRoot = this.baseUrl() + '/osd/' + opts.osdId + '/' + opts.pluginId;
    },
    
    parse: function (response) {
        if (response.status && response.status != STATUS_SUCCESS) {
            response.error = response.message;
        }
        
        return response;
    }
});