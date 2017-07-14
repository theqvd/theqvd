Wat.Collections.DIG = Backbone.Collection.extend({
    apiCode: 'dig-pre',
    
    baseUrl: function () {
        return Wat.C.getApiUrl() + 'proxy/' + this.apiCode;
    }
});