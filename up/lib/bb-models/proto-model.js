Up.Models.Model = Backbone.Model.extend({
    defaults: {},
    id: 0,
    detailsView: false,
    operation: '',
    
    parse: function(response) {        
        if (response.rows) {
            var view = 'detail';
            if (Up.C.sessionExpired(response)) {
                return;
            }
        }
        else {
            var view = 'list';
        }
                
        switch (view) {
            case 'detail':
                return this.processResponse(response.rows[0]);
                break;
            case 'list':
                return this.processResponse(response);
                break;
            case 'error':
                Up.I.M.showMessage({messageType: 'error'}, response);
                break;
        }        
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
        url += this.actionPrefix + "_get_details";
        if (this.id != undefined) {
            url += "&filters={\"id\":" + this.id + "}";
        }
        
        return url
    },
    
    setActionPrefix: function (newActionPrefix) {
        this.actionPrefix = newActionPrefix;
    },
    
    setOperation: function (operation) {
        // TODO or DELETE
        this.operation = this.actionPrefix;
    },
    
    sync: function(method, model, options) {        
        var that = this;
        var params = _.extend({
            type: 'POST',
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
                break;
            case 'update':
                var type = 'PUT';
                break;
        }
        
        options = {
            url: encodeURI(Up.C.getBaseUrl(this.actionPrefix) + '/' + attributes.id),
            data: this.formatData(options),
            type: type,
            contentType: 'application/json'
        };
        
        return Backbone.Model.prototype.save.call(this, attributes, options);
    }
});