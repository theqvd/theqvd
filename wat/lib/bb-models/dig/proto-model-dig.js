Wat.Models.DIG = Backbone.Model.extend({
    baseUrl: function () {
        return Wat.C.getApiUrl() + 'proxy/' + Wat.C.digApiCode;
    }
});