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
                cache: false,
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
        var params = {
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
                if (Wat.C.sessionExpired(response)) {
                    return;
                }
                
                if (raw.getResponseHeader('sid')) {
                    Wat.C.sid = raw.getResponseHeader('sid');
                }
                else {
                    //console.log('NO SID FOUND');
                }
                
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
        };
        
        $.ajax(params);
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
                    
                    var additionalAttributes = '';
                    if (params.translateOptions !== undefined && $.inArray(id, params.translateOptions) != -1) {
                        additionalAttributes = 'data-i18n';
                        combo.attr('data-contain-i18n', '');
                    }
                    
                    combo.append('<option ' + additionalAttributes + ' value="' + id + '" ' + selected + '>' + 
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
            
            if (params.order_by) {
                jsonUrl += '&order_by=' + JSON.stringify(params.order_by);
            }

            $.ajax({
                url: jsonUrl,
                type: 'POST',
                async: false,
                dataType: 'json',
                processData: false,
                parse: true,
                success: function (data) {
                    if (Wat.C.sessionExpired(data)) {
                        return;
                    }
                    $.each($('select[name="' + params.controlName + '"]'), function () {
                        var combo = $(this);
                        
                        var options = '';
                        
                        if (params.group) {
                            //combo.append('<optgroup label="' + params.group + '">');
                        }

                        var optGroup = '';
                        $(data.rows).each(function(i,option) {
                            var selected = '';

                            var id = option.id;
                            if (params.action == 'di_tiny_list') {
                                var name = option.disk_image;
                            }
                            else {
                                var name = option.name;
                            }

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

                            options += '<option value="' + id + '" ' + selected + '>' + 
                                                                        name + 
                                                                        '<\/option>';
                        });

                        if (params.group) {
                            combo.append('<optgroup label="' + params.group + '">' + options + '</optgroup>');
                        }
                        else {
                            combo.append(options);
                        }

                    });
                }
            });
        }
    }
};