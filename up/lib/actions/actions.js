Wat.A = {
    // Get templates from template files caching if specified to avoid future loadings
    // Params:
    //      templateName: name of the template file to be loaded without extension.
    //      cache: boolean that specify if template will be cached in code or not (it will be cached if not provided).
    getTemplates: function(templates, afterCallback, that) {
        
        var templatesCount = 0;
        var templatesMax = Object.keys(templates).length;
        
        $.each (templates, function (storing, template) {
            var templateName = template.name;
            var cache = template.cache;
            
            if (cache == undefined) {
                cache = true;
            }
            
            var templateNameHash = 'template_' + templateName.replace(/\//gi, '-');
            var templateNameHashSelector = '#' + templateNameHash;
            
            if ($(templateNameHashSelector).html() == undefined || !cache) {
                var tmplDir = APP_PATH + 'templates';
                var tmplUrl = tmplDir + '/' + templateName + '.tpl';
                var tmplString = '';

                $.ajax({
                    url: encodeURI(tmplUrl),
                    method: 'GET',
                    async: true,
                    contentType: 'text',
                    cache: false,
                    success: function (tmplString) {
                        if (cache) {
                            $('head').append('<script id="' + templateNameHash + '" type="text/template">' + tmplString + '<\/script>');
                        }
                        
                        Wat.TPL[storing] = tmplString;
                            
                        templatesCount++;
                        if (templatesCount >= templatesMax) {
                            afterCallback(that);
                        }                    
                    }
                });
            }
            else {
                if (cache) {
                    Wat.TPL[storing] = $(templateNameHashSelector).html();
                }
                else {
                    Wat.TPL[storing] = tmplString;
                }
                
                templatesCount++;
                if (templatesCount >= templatesMax) {
                    afterCallback(that);
                }    
            }
        });
    },

    // Check if any action can be affected by expiration or not
    isExpirableAction: function (action) {
        switch (action) {
            case 'current_admin_setup':
                return false;
                break;
            default:
                return false;
                break;
        }
    },
    
    // Perform any action of the API
    // Params:
    //      action: action name.
    //      arguments: hash to be passed in JSON format as arguments to the call API.
    //      filters: hash to be passed in JSON format as filters to the call API.
    //      messages: hash with messages to be showed in success and error cases.
    //      successCallback: function that will be executed after action execution.
    //      that: current context where will be stored retrieved response and passed as parameter to successCallback function.
    //      fields: fields to be returned by the API
    //      orderBy: Order factor
    performAction: function (action, arguments, filters, messages, successCallback, that, fields, orderBy) {
        var that = that || {};
        
        var url = Wat.C.getBaseUrl() + 
            '&action=' + action;
        
        if (filters && !$.isEmptyObject(filters)) {
            url += '&filters=' + JSON.stringify(filters);
        }
        
        if (arguments && !$.isEmptyObject(arguments)) {
            url += '&arguments=' + JSON.stringify(arguments);
        }       
        
        if (fields && !$.isEmptyObject(fields)) {
            url += '&fields=' + JSON.stringify(fields);
        }      
        
        if (orderBy && !$.isEmptyObject(orderBy)) {
            url += '&order_by=' + JSON.stringify(orderBy);
        }
        
        // Add source argument to all queries to be stored by API log
        url += '&parameters=' + JSON.stringify({source: Wat.C.source});

        messages = messages || {};

        successCallback = successCallback || function () {};   
        var params = {
            url: encodeURI(url),
            type: 'POST',
            dataType: 'json',
            processData: false,
            parse: true,
            error: function (response) {
                if (that) {
                    that.retrievedData = response;
                }
                
                // Aborted
                if (that.retrievedData.readyState == 0) {
                    //return;
                }
                
                successCallback(that);

                if (!$.isEmptyObject(messages)) {
                    that.message = messages.error;
                    that.messageType = 'error';

                    var messageParams = {
                        message: that.message,
                        messageType: that.messageType
                    };

                    Wat.I.M.showMessage(messageParams, response);
                }                   
            },
            success: function (response, result, raw) {
                if (Wat.A.isExpirableAction() && Wat.C.sessionExpired(response)) {
                    return;
                }
                
                // Aborted
                if (response.readyState == 0) {
                    return;
                }
                
                if (response['sid']) {
                    Wat.C.sid = response['sid'];
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

                    Wat.I.M.showMessage(messageParams, response);
                }                
            }
        };
        
        var request = $.ajax(params);
        
        Wat.C.requests.push(request);
    },
        
    // Get API info calling un-auth 'info' url
    // Params:
    //      successCallback: function that will be executed after action execution.
    //      that: current context where will be stored retrieved response and passed as parameter to successCallback function.
    apiInfo: function (successCallback, that) {
        var url = Wat.C.getApiUrl() + 'info';

        messages = {};

        successCallback = successCallback || function () {};   
        var params = {
            url: encodeURI(url),
            type: 'GET',
            dataType: 'json',
            processData: false,
            parse: true,
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

                    Wat.I.M.showMessage(messageParams, response);
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

                    Wat.I.M.showMessage(messageParams, response);
                }                
            }
        };
        
        $.ajax(params);
    },
    
    // Call server side logout action
    // Params:
    //      successCallback: function that will be executed after action execution.
    //      that: current context where will be stored retrieved response and passed as parameter to successCallback function.
    apiLogIn: function (successCallback, that) {
        var url = Wat.C.getApiUrl() + 'login';
        if (Wat.C.crossOrigin) {
            if (Wat.C.sid) {
                url += '?sid=' + Wat.C.sid;
            }
            else {
                url +=  "?user=" + Wat.C.login + "&password=" + Wat.C.password;
                
                if (Wat.C.multitenant) {
                    url += "&tenant=" + Wat.C.tenant;
                }
            }
        }
        
        var params = {
            url: encodeURI(url),
            type: 'POST',
            dataType: 'json',
            processData: false,
            parse: true,
            success: function (response, result, raw) {
                that.retrievedStatus = 0 ? raw.status == 200 : -1;
                successCallback(that);    
            },
            error: function (response, result, raw) {
                var responseMsg = JSON.parse(response.responseText).message;
                Wat.I.M.showMessage({message: i18n.t('Error logging in') + ": " + responseMsg, messageType: 'error'});
            }
        };
        
        $.ajax(params);
    },
    
    // Call server side logout action
    // Params:
    //      successCallback: function that will be executed after action execution.
    //      that: current context where will be stored retrieved response and passed as parameter to successCallback function.
    apiLogOut: function (successCallback, that) {
        var url = Wat.C.getApiUrl() + 'logout';
        if (Wat.C.crossOrigin) {
            url += '?sid=' + Wat.C.sid;
        }
        
        var params = {
            url: encodeURI(url),
            type: 'POST',
            dataType: 'json',
            processData: false,
            parse: true,
            success: function (response, result, raw) {
                successCallback(that);    
            },
            error: function (response, result, raw) {
                Wat.I.M.showMessage({message: i18n.t('Error logging out'), messageType: 'error'});
            }
        };
        
        $.ajax(params);
    },
    
    // Fill select combo with API call, passed values or both
    // Params:
    //      params: hash with parameters.
    //          - params.controlSelector: CSS selector for the select combo
    //          - params.controlId: select combo's ID (used if controlSelector is not retrieved)
    //          - params.controlName: select combo's name (used if controlSelector and controlId are not retrieved)
    //          - params.startingOptions: hash with pairs id-name of elements to fill the select combo
    //          - params.selectedId: Id of the element that will be selected
    //          - params.translateOptions: Array of ids of those elements that will be translated
    //          - params.action: API action that will be used to fill select combo
    //          - params.filters: API filters that will be used to fill select combo
    //          - params.order_by: API order by that will be used to fill select combo
    //          - params.nameAsId: Boolean that specifies if name of the options will be taken as Id too
    //          - params.group: HTML native optgroup where the options will be grouped
    //      afterCallBack: Function to be executed after filling
    fillSelect: function (params, afterCallBack) {
        if (params.controlSelector) {
            var controlSelector = params.controlSelector;
        }
        else if (params.controlId) {
            var controlSelector = 'select#' + params.controlId;
        }
        else if (params.controlName) {
            var controlSelector = 'select[name="' + params.controlName + '"]';
        }
        else {
            return;
        }
        
        if (params.chosenType) {
            Wat.I.chosenElement(controlSelector, params.chosenType);
        }
        
        // Some starting options can be added as first options
        if (params.startingOptions) {
            $.each($(controlSelector), function () {
                var combo = $(this);
                
                // Reset select options
                combo.find('option').remove();
                
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
                    
                    var translateAttr = 'data-i18n'
                    
                    combo.append('<option ' + additionalAttributes + ' value="' + id + '" ' + selected + ' ' + translateAttr + '>' + 
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
            
            Wat.I.disableChosenControls(controlSelector);
            
            // Change content of chosen combo to Loading while data is loaded
            $(controlSelector + '+.chosen-container span').html($.i18n.t('Loading'));
            
            var request = $.ajax({
                url: encodeURI(jsonUrl),
                type: 'POST',
                async: true,
                dataType: 'json',
                processData: false,
                parse: true,
                success: function (data) {
                    if (Wat.C.sessionExpired(data)) {
                        return;
                    }
                    
                    $.each($(controlSelector), function () {
                        var combo = $(this);
                        
                        var options = '';

                        var optGroups = {};
                        
                        var storedIds = [];
                        
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
                            
                            // If one option is already in select, will be ignored
                            if ($.inArray(id, storedIds) != -1) {
                                return;
                            }
                            
                            // Store option id
                            storedIds.push(id);

                            if (params.selectedId !== undefined && params.selectedId == id) {
                                selected = 'selected="selected"';
                            }

                            var optionHTML = '<option value="' + id + '" ' + selected + '>' +  
                                                                        _.escape(name) + 
                                                                        '<\/option>';
                                                        
                            if (params.groupByField) {
                                var groupField = option[params.groupByField];
                                
                                if (!optGroups[groupField]) {
                                    optGroups[groupField] = '';
                                }
                                
                                optGroups[groupField] += optionHTML
                            }
                            else {
                                options += optionHTML;
                            }
                        });

                        if (params.groupByField) {
                            $.each(optGroups, function (groupLabel, groupOptions) {
                                combo.append('<optgroup label="' + groupLabel + '">' + groupOptions + '</optgroup>');
                            });
                        }
                        else if (params.group) {
                            combo.append('<optgroup label="' + params.group + '">' + options + '</optgroup>');
                        }
                        else {
                            combo.append(options);
                        }

                        // Clean loading attribute
                        $(controlSelector).removeAttr('data-loading');
                    });

                    // Enable again control if isn't tenant filter or current admin is not a superadmin
                    if (!Wat.C.isSuperadmin() || $('[data-waiting-loading]').length == 0 || ($('[data-waiting-loading]').length > 0 && $(controlSelector).attr('name') != 'tenant')) {
                        Wat.I.enableChosenControls(controlSelector);
                    }

                    // If there are any control waiting loading and there arent any loading element more, enable tenant filter
                    if ($('[data-waiting-loading]').length > 0 && $('[data-loading]').length == 0) {
                        Wat.I.enableChosenControls('[name="tenant"]');
                    }
                    
                    if (params.chosenType) {
                        Wat.I.updateChosenControls(controlSelector);
                    }
                    
                    if (afterCallBack != undefined) {
                        afterCallBack ();
                    }
                }
            });
                    
            Wat.C.requests.push(request);
        }
        else {
            if (params.chosenType) {
                Wat.I.updateChosenControls(controlSelector);
            }
                    
            if (afterCallBack != undefined) {
                afterCallBack ();
            }
        }
    },
};