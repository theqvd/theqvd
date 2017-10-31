Wat.Models.PluginDef = Wat.Models.DIG.extend({
    defaults: {
    },
    
    initialize: function (attrs, opts) {
        opts = opts || {};
        
        if (opts.osdId) {
            this.osdId = opts.osdId;
            this.urlRoot = this.baseUrl() + '/osd/' + opts.osdId + '/plugin';
        }
        else {
            this.urlRoot = this.baseUrl() + '/plugin';
        }

        Backbone.Model.prototype.initialize.apply(this, [attrs]);
    }
});