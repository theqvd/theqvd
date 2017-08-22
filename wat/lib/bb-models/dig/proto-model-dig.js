Wat.Models.DIG = Backbone.Model.extend({
    apiCode: 'dig',
    
    baseUrl: function () {
        return Wat.C.getApiUrl() + 'proxy/' + this.apiCode;
    }
});