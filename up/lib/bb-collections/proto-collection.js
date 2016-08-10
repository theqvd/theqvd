Up.Collections.Collection = Backbone.Collection.extend({
    model: {},
    elementsTotal: 0,
    status: 0,
    offset: 1,
    block: 10,

    filters: {},
    // Order by id by default
    sort: {"field": "id", "order": "-desc"},
    
    initialize: function (params) {
        params = params || {};
        
        this.block = params.block || this.block;
        this.offset = params.offset || this.offset;
        this.filters = params.filters || this.filters;
        this.action = params.action || this.actionPrefix;
        this.sort = params.sort || this.sort;
    },
    
    getListUrl: function () {
        var fullUrl = Up.C.getBaseUrl(this.action)  + 
            "?offset=" + this.offset + 
            "&block=" + this.block + 
            "&filters=" + JSON.stringify(this.filters) + 
            "&order_by=" + JSON.stringify(this.sort);

        return fullUrl;
    },
    
    setFilters: function (filters) {
        this.filters = filters;
    }, 
        
    deleteFilter: function (filterDelete) {
        delete this.filters[filterDelete];
    }, 
    
    setSort: function (sort) {
        this.sort = sort;
    },

    parse: function(response) {
        if (Up.C.sessionExpired(response)) {
            return;
        }
        
        return response;
    },

    sync: function(method, model, options) {
        var that = this;
        
        var params = _.extend({
            type: 'GET',
            dataType: 'json',
            url: encodeURI(that.getListUrl()),
            headers: {
                "Geo-Location": Up.C.getGeolocation()
            },
            processData: false
        }, options);
        
        return $.ajax(params);
    }
});