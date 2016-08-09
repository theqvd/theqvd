Up.Models.Model = Backbone.Model.extend({
    defaults: {},
    id: 0,
    
    initialize: function (params) {
    },
    
    parse: function(response) {
        return this.processResponse(response);
    },
    
    processResponse: function (response) {
        if (response) {
            // Escape strings to avoid injections
            $.each (response, function (field, value) {
                if (typeof value == 'string') {
                    response[field] = _.escape(value);
                }
            });
        }
        
        return response;
    },
    
    url: function () {
        return Up.C.getBaseUrl();
    },
    
    sync: function(method, model, options) {
        var params = _.extend({
            type: 'GET',
            dataType: 'json',
            url: encodeURI(this.url()),
            processData: false,
        }, options);
        
        return $.ajax(params);
    },
    
    getActionType: function (action) {
        switch(action) {
            case 'create':
                var type = 'POST';
                break;
            case 'update':
                var type = 'PUT';
                break;
            case 'delete':
                var type = 'DELETE';
                break;
        }
        
        return type;
    },
    
    getActionUrl: function (action, id) {
        switch(action) {
            case 'create':
                var url = encodeURI(Up.C.getBaseUrl(this.actionPrefix));
                break;
            case 'update':
                var url = encodeURI(Up.C.getBaseUrl(this.actionPrefix));
                
                if (id) {
                    url += '/' + id;
                }
                break;
            case 'delete':
                var url = encodeURI(Up.C.getBaseUrl(this.actionPrefix) + '/' + id);
                break;
        }
        
        return url;
    },
    
    save: function(attributes, options, action) {
        var action = action || 'update';
        
        options = {
            url: this.getActionUrl(action, attributes.id),
            data: JSON.stringify(options),
            type: this.getActionType(action),
            contentType: 'application/json'
        };
        
        return Backbone.Model.prototype.save.call(this, attributes, options);
    }
});