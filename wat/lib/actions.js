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
            
            if ($('#template_' + templateName).html() == undefined || !cache) {
                var tmplDir = APP_PATH + 'templates';
                var tmplUrl = tmplDir + '/' + templateName + '.tpl';
                var tmplString = '';

                $.ajax({
                    url: tmplUrl,
                    method: 'GET',
                    async: true,
                    contentType: 'text',
                    cache: false,
                    success: function (tmplString) {
                        if (cache) {
                            $('head').append('<script id="template_' + templateName + '" type="text/template">' + tmplString + '<\/script>');
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
                    Wat.TPL[storing] = $('#template_' + templateName).html();
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
    
    // Perform any action of the API
    // Params:
    //      action: action name.
    //      arguments: hash to be passed in JSON format as arguments to the call API.
    //      filters: hash to be passed in JSON format as filters to the call API.
    //      messages: hash with messages to be showed in success and error cases.
    //      successCallback: function that will be executed after action execution.
    //      that: current context where will be stored retrieved response and passed as parameter to successCallback function.
    performAction: function (action, arguments, filters, messages, successCallback, that) {
        var url = Wat.C.getBaseUrl() + 
            '&action=' + action;
        
        if (filters && !$.isEmptyObject(filters)) {
            url += '&filters=' + JSON.stringify(filters);
        }
        
        if (arguments && !$.isEmptyObject(arguments)) {
            url += '&arguments=' + JSON.stringify(arguments);
        }
        
        // Add source argument to all queries to be stored by API log
        url += '&parameters=' + JSON.stringify({source: Wat.C.source});

        messages = messages || {};

        successCallback = successCallback || function () {};   
        var params = {
            url: url,
            type: 'POST',
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
        
    // Get API info calling un-auth 'info' url
    // Params:
    //      successCallback: function that will be executed after action execution.
    //      that: current context where will be stored retrieved response and passed as parameter to successCallback function.
    apiInfo: function (successCallback, that) {
        var url = Wat.C.getApiUrl() + 'info';

        messages = {};

        successCallback = successCallback || function () {};   
        var params = {
            url: url,
            type: 'POST',
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
            
            $.ajax({
                url: jsonUrl,
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

                    if (params.chosenType) {
                        Wat.I.updateChosenControls(controlSelector);
                    }
                    
                    // If no elements found, set label of chosen select as Empty
                    if ($(controlSelector).find('option').length == 0) {
                        $(controlSelector + '+.chosen-container span').html($.i18n.t('Empty'));
                    }
                    
                    if (afterCallBack != undefined) {
                        afterCallBack ();
                    }
                }
            });
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
    
    // Get a documentation guide from template and return <body> of this document to be ebeded in WAT
    // Params:
    //      selectedGuide: guide name.
    getDocBody: function (docParams, callBack) {        
        // Load language
        var lan = $.i18n.options.lng;
        
        if ($.inArray(lan, DOC_AVAILABLE_LANGUAGES) === -1) {
            lan = DOC_DEFAULT_LANGUAGE;
        }
        
        var templates = {
            docSection: {
                name: 'documentation-' + lan + '-' + docParams.guide,
                cache: false
            }
        }
        
        Wat.A.getTemplates(templates, callBack, docParams);
    },
    
    processDocBody: function (docParams) {
        var pattern = /<body[^>]*>((.|[\n\r])*)<\/body>/im
        var array_matches = pattern.exec(Wat.TPL.docSection);
        
        docParams.docBody = array_matches[1];
        
        Wat.A.processDocSection(docParams);
    }, 
    
    fillDocBody: function (docParams) {
        var pattern = /<body[^>]*>((.|[\n\r])*)<\/body>/im
        var array_matches = pattern.exec(Wat.TPL.docSection);
        
        docParams.docBody = array_matches[1];
        
        Wat.A.fillTemplateString(docParams.docBody, docParams.target, true, docParams);
    },
    
    fillTemplateString: function (string, target, toc, docParams) {
        if (!string) {
            return;
        }
        
        target.html(target.html() + string);  

        if (toc) {
            asciidoc.toc(3);
        }
        
        if (docParams.callback) {
            docParams.callback();
        }
    },
    
    fillTemplate: function (docParams) {
        docParams.target.html(Wat.TPL[docParams.templateName]);
        
        Wat.T.translate();
    },
    
    // Get a documentation guide´s section from guide
    // Params:
    //      guide: guide name.
    //      sectionId: Id of the section of the guide to be parsed.
    //      toc: boolean to specify if include or not Table of Contents (Default: False).
    //      imagesPrefix: prefix to be added to each src attribute in images.
    //      target: target where the doc section will be load.
    fillDocSection: function (guide, sectionId, toc, imagesPrefix, target) {
        var docParams = {
            guide: guide,
            sectionId: sectionId,
            toc: toc,
            imagesPrefix: imagesPrefix,
            target: target
        };
        
        if (guide == 'multitenant' && !Wat.C.isSuperadmin()) {
            Wat.A.fillTemplateString (null, target, toc, docParams);
            return;
        }
        
        Wat.A.getDocBody(docParams, this.processDocBody);
    },
    
    processDocSection: function (docParams) {  
        var toc = docParams.toc;
        
        if (toc == undefined) {
            toc = false;
        }
        
        if (toc) {
            var guideHeader = $.parseHTML(docParams.docBody)[1].outerHTML;
            var guideToc = $.parseHTML(guideHeader)[1].childNodes[3].outerHTML;
        }
        
        var pattern = new RegExp('(<h[1|2|3|4] id="' + docParams.sectionId + '"[^>]*>((.|[\n\r])*))', 'im');
        var array_matches2 = pattern.exec(docParams.docBody); 
        
        if (!array_matches2) {
            return null;
        }
        
        // When doc sections are retrieved from different path than standard (i.e. tests), we can add a prefix to the images path
        if (docParams.imagesPrefix) {
            array_matches2[1] = array_matches2[1].replace(/src="images/g, 'src="../images');
        }
        
        var secBody = $.parseHTML('<div>' + array_matches2[1])[0].innerHTML;
        var secTitle = '';
        
        if (toc) {
            var content = '<div id="content">' + guideToc + secTitle + secBody + '</div>';
        }
        else {
            var content = '<div class="doc-text">' + secBody + '</div>';
        }
        
        Wat.A.fillTemplateString(content, docParams.target, false, docParams)
    }
};