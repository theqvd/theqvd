var Collection = Backbone.Collection.extend({
    model: {},
    url: "",
    elementsTotal: 0,
    result: 0,

    parse: function(response) {
        this.result = response.result;
        this.elementsTotal = response.total_elements;
        return response.list;
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