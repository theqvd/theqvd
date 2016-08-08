Up.Models.Model = Backbone.Model.extend({
    defaults: {},
    id: 0,
    detailsView: false,
    operation: '',
    
    parse: function(response) {        
        return this.processResponse(response);
    },
    
    processResponse: function (response) {
        // If found creation_date field, replace ugly T by blank space
        if (response) {
            // Creation date must be converted to local timezone and proper format
            if (response.creation_date) {
                response.creation_date = response.creation_date.replace("T", " ");
                response.creation_date = Up.U.getLocalDatetimeFormatted(response.creation_date);
            }
        
            // Escape strings to avoid injections
            $.each (response, function (field, value) {
                if (typeof value == 'string') {
                    response[field] = _.escape(value);
                }
            });
        }
        
        return response;
    },
    
    initialize: function (params) {
        if (params !== undefined) {
            this.params = params.id;
        }
    },
    
    url: function () {
        var url = Up.C.getBaseUrl();
        
        return url;
    },
    
    setOperation: function (operation) {
        // TODO or DELETE
        this.operation = this.actionPrefix;
    },
    
    sync: function(method, model, options) {        
        var that = this;
        var params = _.extend({
            type: 'GET',
            dataType: 'json',
            url: encodeURI(that.url()),
            processData: false,
        }, options);
        
        return $.ajax(params);
    },
    
    formatData: function (options) {
        return JSON.stringify(options);
    },
    
    save: function(attributes, options, action) {
        var action = action || 'update';
        
        switch(action) {
            case 'create':
                type = 'POST';
                url = encodeURI(Up.C.getBaseUrl(this.actionPrefix));
                break;
            case 'update':
                var type = 'PUT';
                url = encodeURI(Up.C.getBaseUrl(this.actionPrefix));
                
                if (attributes.id) {
                    url += '/' + attributes.id;
                }
                break;
            case 'delete':
                var type = 'DELETE';
                url = encodeURI(Up.C.getBaseUrl(this.actionPrefix) + '/' + attributes.id);
                break;
        }
        
        options = {
            url: url,
            data: this.formatData(options),
            type: type,
            contentType: 'application/json'
        };
        
        return Backbone.Model.prototype.save.call(this, attributes, options);
    }
});