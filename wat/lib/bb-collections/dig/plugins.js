Wat.Collections.Plugins = Wat.Collections.DIG.extend({
    initialize: function (attrs, opts) {
        Wat.Collections.DIG.prototype.initialize.apply(this, [attrs]);
        
        this.urlRoot = Wat.C.getApiUrl() + 'proxy/' + Wat.C.digApiCode + '/osd/' + this.osdId;
    }
});