Wat.Collections.DIG = Backbone.Collection.extend({
    apiCode: 'dig',
    
    baseUrl: function () {
        return Wat.C.getApiUrl() + 'proxy/' + this.apiCode;
    }
});