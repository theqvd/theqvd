var Model = Backbone.Model.extend({
    defaults: {},
    url: "",

    parse: function(response) {
        return response;
    },
    
    
    sync: function(method, model, options) {
        var that = this;
        var params = _.extend({
            type: 'GET',
            dataType: 'json',
            url: that.url,
            processData: false
        }, options);

        return $.ajax(params);
    }
});