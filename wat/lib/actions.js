Wat.A = {
    getTemplate: function(templateName) {
        if ($('#template_' + templateName).html() == undefined) {
            var tmplDir = APP_PATH + 'templates';
            var tmplUrl = tmplDir + '/' + templateName + '.tpl';
            var tmplString = '';

            $.ajax({
                url: tmplUrl,
                method: 'GET',
                async: false,
                contentType: 'text',
                success: function (data) {
                    tmplString = data;
                }
            });

            $('head').append('<script id="template_' + templateName + '" type="text/template">' + tmplString + '<\/script>');
        }

        return $('#template_' + templateName).html();
    },
    
    performAction: function (action, arguments, filters, messages, successCallback, that, async) {
        if (async == undefined) {
            async = true;
        }
        
        var url = Wat.C.getBaseUrl() + 
            '&action=' + action;
        
        if (filters && !$.isEmptyObject(filters)) {
            url += '&filters=' + JSON.stringify(filters);
        }
        
        if (arguments && !$.isEmptyObject(arguments)) {
            url += '&arguments=' + JSON.stringify(arguments);
        }

        messages = messages || {};
        var that2 = that;
        successCallback = successCallback || function () {};   
        $.ajax({
            url: url,
            type: 'POST',
            dataType: 'json',
            processData: false,
            parse: true,
            async: async,
            error: function (response) {
                if (that) {
                    that.retrievedData = response;
                }
                
                successCallback(that);

                if (!$.isEmptyObject(messages)) {
                    that.message = messages.error;
                    that.messageType = 'error';

                    var messageParams = {
                        message: that.message,
                        messageType: that.messageType
                    };

                    Wat.I.showMessage(messageParams, response);
                }                   
            },
            success: function (response, result, raw) {
                if (that) {
                    that.retrievedData = response;
                }

                successCallback(that);
                
                if (!$.isEmptyObject(messages)) {
                    if (response.status == 0) {
                        that.message = messages.success;
                        that.messageType = 'success';
                    }
                    else {
                        that.message = messages.error;
                        that.messageType = 'error';
                    }

                    var messageParams = {
                        message: that.message,
                        messageType: that.messageType
                    };

                    Wat.I.showMessage(messageParams, response);
                }                
            }
        });
    },
    
    // Fill filter selects 
    fillSelect: function (params) {
        // Some starting options can be added as first options
        if (params.startingOptions) {
            $.each($('select[name="' + params.controlName + '"]'), function () {
                var combo = $(this);
                $.each(params.startingOptions, function (id, name) {
                    var selected = '';
                    if (params.selectedId !== undefined && params.selectedId == id) {
                        selected = 'selected="selected"';
                    }
                    combo.append('<option value="' + id + '" ' + selected + '>' + 
                                                               name + 
                                                               '<\/option>');
                });
            });
        }

        // If action is defined, add retrieved items from ajax to select
        if (params.action) {
            var jsonUrl = Wat.C.getBaseUrl() + '&action=' + params.action;

            if (params.filters) {
                jsonUrl += '&filters=' + JSON.stringify(params.filters);
            }

            $.ajax({
                url: jsonUrl,
                type: 'POST',
                async: false,
                dataType: 'json',
                processData: false,
                parse: true,
                success: function (data) {
                    $(data.result.rows).each(function(i,option) {
                        var selected = '';

                        var id = option.id;
                        var name = option.name;
                        
                        if (params.nameAsId) {
                            id = name;
                        }

                        // If one option is defined in starting options, will be ignored
                        if (params.startingOptions && params.startingOptions[id]) {
                            return;
                        }

                        if (params.selectedId !== undefined && params.selectedId == id) {
                            selected = 'selected="selected"';
                        }
                        
                        $.each($('select[name="' + params.controlName + '"]'), function () {
                            $(this).append('<option value="' + id + '" ' + selected + '>' + 
                                                                       name + 
                                                                       '<\/option>');
                        });
                    });
                }
            });
        }
    }
};