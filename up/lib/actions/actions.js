Up.A = {
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
                        
                        Up.TPL[storing] = tmplString;
                            
                        templatesCount++;
                        if (templatesCount >= templatesMax) {
                            afterCallback(that);
                        }                    
                    }
                });
            }
            else {
                if (cache) {
                    Up.TPL[storing] = $(templateNameHashSelector).html();
                }
                else {
                    Up.TPL[storing] = tmplString;
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
    //      messages: hash with messages to be showed in success and error cases.
    //      successCallback: function that will be executed after action execution.
    //      that: current context where will be stored retrieved response and passed as parameter to successCallback function.
    //      method: GET/POST
    performAction: function (action, messages, successCallback, that, method) {
        var that = that || {};
        
        var method = method || 'GET';
        
        var url = Up.C.getBaseUrl(action);

        messages = messages || {};

        successCallback = successCallback || function () {};   
        var params = {
            url: encodeURI(url),
            type: method,
            dataType: 'json',
            processData: false,
            parse: true,
            statusCode: {
                401: function (errorRaw) {                return;

                    var errorJSON = JSON.parse(errorRaw.responseText);
                    var errorMsg = errorJSON.message;
                    
                    that.retrievedData = {
                        status: 401,
                        error: errorMsg
                    }
                    successCallback(that);
                }
            },
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

                    Up.I.M.showMessage(messageParams, response);
                }                   
            },
            success: function (response, result, raw) {
                if (Up.A.isExpirableAction() && Up.C.sessionExpired(response)) {
                    return;
                }
                
                // Aborted
                if (response.readyState == 0) {
                    return;
                }
                
                if (response['sid']) {
                    Up.C.sid = response['sid'];
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

                    Up.I.M.showMessage(messageParams, response);
                }                
            }
        };
        
        var request = $.ajax(params);
        
        Up.C.requests.push(request);
    },
        
    // Get API info calling un-auth 'info' url
    // Params:
    //      successCallback: function that will be executed after action execution.
    //      that: current context where will be stored retrieved response and passed as parameter to successCallback function.
    apiInfo: function (successCallback, that) {
        var url = Up.C.getApiUrl() + 'info';

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

                    Up.I.M.showMessage(messageParams, response);
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

                    Up.I.M.showMessage(messageParams, response);
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
        var url = Up.C.getApiUrl() + 'login';
        url +=  "?login=" + Up.C.login + "&password=" + Up.C.password;
        
        var params = {
            url: encodeURI(url),
            type: 'POST',
            dataType: 'json',
            processData: false,
            parse: true,
            success: function (response, result, raw) {
                that.retrievedData = response;
                raw.status == STATUS_SUCCESS_HTTP ? that.retrievedData.status = STATUS_SUCCESS : that.retrievedData.status = raw.status;
                
                // Retrieve account data
                var accountModel = new Up.Models.Profile();
                
                accountModel.fetch({      
                    complete: function (e) {
                        successCallback(that);    
                    }
                });
            },
            error: function (response, result, raw) {
                var responseMsg = JSON.parse(response.responseText).message;
                Up.I.M.showMessage({message: i18n.t('Error logging in') + ": " + responseMsg, messageType: 'error'});
            }
        };
        
        $.ajax(params);
    },
    
    // Call server side logout action
    // Params:
    //      successCallback: function that will be executed after action execution.
    //      that: current context where will be stored retrieved response and passed as parameter to successCallback function.
    apiLogOut: function (successCallback, that) {
        var url = Up.C.getApiUrl() + 'logout';
        
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
                Up.I.M.showMessage({message: i18n.t('Error logging out'), messageType: 'error'});
            }
        };
        
        $.ajax(params);
    }
};