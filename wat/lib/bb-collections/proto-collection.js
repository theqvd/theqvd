Wat.Collections.Collection = Backbone.Collection.extend({
    model: {},
    elementsTotal: 0,
    status: 0,
    offset: 1,
    block: 10,
    filters: {},
    // Order by id by default
    sort: {"field": "id", "order": "-asc"},
    baseUrl: "http://172.20.126.12:3000/?login=benja&password=benja",
    
    initialize: function (params) {
        params = params || {};
        
        this.block = params.block || this.block;
        this.offset = params.offset || this.offset;
        this.filters = params.filters || this.filters;
    },
    
    getListUrl: function () {
        var fullUrl = this.baseUrl  + 
            "&action=" + this.actionPrefix + '_get_list' +
            "&offset=" + this.offset + 
            "&block=" + this.block + 
            "&filters=" + JSON.stringify(this.filters) + 
            "&order_by=" + JSON.stringify(this.sort);

        return fullUrl;
    },
    
    setFilters: function (filters) {
        this.filters = filters;
    }, 
    
    setSort: function (sort) {
        this.sort = sort;
    },

    parse: function(response) {
        this.status = response.status;
        this.elementsTotal = response.result.total;
        return response.result.rows;
    },

    sync: function(method, model, options) {
        var that = this;
        
        var params = _.extend({
            type: 'GET',
            dataType: 'json',
            url: that.getListUrl(),
            processData: false
        }, options);
        
        return $.ajax(params);
    }
});