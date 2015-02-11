Wat.A = {
    // Get template from template file caching if specified to avoid future loadings
    // Params:
    //      templateName: name of the template file to be loaded without extension.
    //      cache: boolean that specify if template will be cached in code or not (it will be cached if not provided).
    getTemplate: function(templateName, cache) {
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
                async: false,
                contentType: 'text',
                cache: false,
                success: function (data) {
                    tmplString = data;
                }
            });
            
            if (cache) {
                $('head').append('<script id="template_' + templateName + '" type="text/template">' + tmplString + '<\/script>');
            }
        }

        if (cache) {
            return $('#template_' + templateName).html();
        }
        else {
            return tmplString;
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
    //      async: boolean that specify if API call will be asynchronous or not (Default: Asynchronous).
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
    
    // Fill select combo with API call, passed values or both
    // Params:
    //      params: hash with parameters.
    //          - params.controlSelector: CSS selector for the select combo
    //          - params.controlId: select combo's ID (used if controlSelector is not retrieved)
    //          - params.controlName: select combo's name (used if controlSelector and controlId are not retrieved)
    //          - params.params.startingOptions: hash with pairs id-name of elements to fill the select combo
    //          - params.selectedId: Id of the element that will be selected
    //          - params.translateOptions: Array of ids of those elements that will be translated
    //          - params.action: API action that will be used to fill select combo
    //          - params.filters: API filters that will be used to fill select combo
    //          - params.order_by: API order by that will be used to fill select combo
    //          - params.nameAsId: Boolean that specifies if name of the options will be taken as Id too
    //          - params.group: HTML native optgroup where the options will be grouped
    fillSelect: function (params) {
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
                }
            });
        }
    },
    
    // Get a documentation guide from template and return <body> of this document to be ebeded in WAT
    // Params:
    //      selectedGuide: guide name.
    getDocBody: function (selectedGuide) {
        // Load language
        var lan = $.i18n.options.lng;
        
        if ($.inArray(lan, DOC_AVAILABLE_LANGUAGES) === -1) {
            lan = DOC_DEFAULT_LANGUAGE;
        }
            
        var templateDoc = Wat.A.getTemplate('documentation-' + lan + '-' + selectedGuide, false);

        var pattern = /<body[^>]*>((.|[\n\r])*)<\/body>/im
        var array_matches = pattern.exec(templateDoc);
        
        return array_matches[1];
    },
    
    // Get a documentation guide´s section from guide
    // Params:
    //      guide: guide name.
    //      sectionId: Id of the section of the guide to be parsed.
    //      toc: boolean to specify if include or not Table of Contents (Default: False).
    //      imagesPrefix: prefix to be added to each src attribute in images.
    getDocSection: function (guide, sectionId, toc, imagesPrefix) {
        if (toc == undefined) {
            toc = false;
        }
        
        var docBody = Wat.A.getDocBody(guide);
        
        if (toc) {
            var guideHeader = $.parseHTML(docBody)[1].outerHTML;
            var guideToc = $.parseHTML(guideHeader)[1].childNodes[3].outerHTML;
        }
        
        var pattern = new RegExp('(<h[1|2|3|4] id="' + sectionId + '"[^>]*>((.|[\n\r])*))', 'im');
        var array_matches2 = pattern.exec(docBody); 
        
        if (!array_matches2) {
            return null;
        }
        
        // When doc sections are retrieved from different path than standard (i.e. tests), we can add a prefix to the images path
        if (imagesPrefix) {
            array_matches2[1] = array_matches2[1].replace(/src="images/g, 'src="../images');
        }
        
        var secBody = $.parseHTML('<div>' + array_matches2[1])[0].innerHTML;
        
        if (toc) {
            return '<div id="content">' + guideToc + secTitle + secBody + '</div>';
        }
        else {
            return '<div class="doc-text" style="height: 50vh;">' + secBody + '</div>';
        }
    }
};