Wat.Models.Model = Backbone.Model.extend({
    defaults: {},
    id: 0,
    url: "",
    detailsView: false,

    parse: function(response) {
        if (this.detailsView) {
            return response.result.rows[0];
        }
        else {
            return response;
        }
    },
    
    initialize: function (params) {
        if (params !== undefined) {
            this.id = params.id;
        }
    },
    
    getUrl: function () {
        return this.url + "&filters={\"id\":" + this.id + "}";
    },
    
    
    sync: function(method, model, options) {
        this.detailsView = true;
        
        var that = this;
        var params = _.extend({
            type: 'POST',
            dataType: 'json',
            url: that.getUrl(),
            processData: false
        }, options);
        
        return $.ajax(params);
    }
});