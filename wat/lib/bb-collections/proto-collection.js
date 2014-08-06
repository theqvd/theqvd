var Collection = Backbone.Collection.extend({
    model: {},
    elementsTotal: 0,
    status: 0,
    blocked: 10,
    filters: {},
    
    initialize: function (params) {
        this.blocked = params.blocked;
        this.offset = params.offset;
    },
    
    getUrl: function () {
        var fullUrl = this.url  + "&offset=" + this.offset + "&blocked=" + this.blocked + "&filters=" + JSON.stringify(this.filters);
        console.log(fullUrl);
        return fullUrl;
    },
    
    setFilters: function (filters) {
        this.filters = filters;
    },

    parse: function(response) {
        this.status = response.status;
        this.elementsTotal = response.result.total;
        return response.result.rows;
    },

    sync: function(method, model, options) {
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