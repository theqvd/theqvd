Wat.Collections.DIG = Backbone.Collection.extend({
    baseUrl: function () {
        return Wat.C.getApiUrl() + 'proxy/' + Wat.C.digApiCode;
    }
});