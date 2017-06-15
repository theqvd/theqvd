Wat.Models.OSDSavepoint = Wat.Models.DIG.extend({
    pluginDef: {},
    pluginData: {},
    
    initialize: function (attrs, opts) {
        Backbone.Model.prototype.initialize.apply(this, [attrs]);
        
        this.urlRoot = this.baseUrl() + '/osd/' + opts.osdId + '/savepoint';
        
        if ( opts.discard) {
            this.urlRoot += '/discard';
        }
    },
    
    defaults: {
    },
    
    parse: function(response) {
        return $.extend({}, response, this.mock(response));
    },
    
    mock: function (response) {
        var osd = {};
        
        return osd;
    }
});