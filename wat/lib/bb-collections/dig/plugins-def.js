Wat.Collections.PluginsDef = Wat.Collections.DIG.extend({
    initialize: function (attrs, opts) {
        opts = opts || {};
        
        if (opts.osdId) {
            this.osdId = opts.osdId;
        }
        
        Wat.Collections.DIG.prototype.initialize.apply(this, [attrs]);
    },
    
    url: function () {
        if (this.osdId) {
            var url = this.urlRoot = this.baseUrl() + '/osd/' + this.osdId + '/plugin';
        }
        else {
            var url = this.urlRoot = this.baseUrl() + '/plugin';
        }
        
        return url;
    }
});