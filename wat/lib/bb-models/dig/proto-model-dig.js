Wat.Models.DIG = Backbone.Model.extend({
    apiCode: 'dig-pre',
    
    baseUrl: function () {
        return Wat.C.getApiUrl() + 'proxy/' + this.apiCode;
    }
});