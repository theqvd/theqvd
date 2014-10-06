// Pure interface utilities
Wat.I = {
    // Graphs
    G: {},
    
    cornerMenu : {},
    
    getCornerMenu: function () {
        return $.extend(true, [], this.cornerMenu);
    },
    
    listColumns: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {},
        role: {},
        admin: {},
        acl: {}
    },
    
    getListColumns: function (qvdObj) {
        return $.extend(true, {}, this.listColumns[qvdObj]);
    },
    
    // DEPRECATED
    getListColumnsByField: function (qvdObj) {
        var listColumns = this.getListColumns(qvdObj);
        
        // Get default values for custom columns
        var listColumnsByField = {};
        $.each(listColumns, function (columnName, column) {
            $.each(column.fields, function (iField, field) {
                listColumnsByField[field] = listColumnsByField[field] || {};
                listColumnsByField[field][columnName] = column.display;
            });
        });
        
        return listColumnsByField;
    },
    
    formFilters: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {}
    },
    
    getFormFilters: function (qvdObj) {
        return $.extend(true, {}, this.formFilters[qvdObj]);
    },
    
    // DEPRECATED
    getFormFiltersByField: function (qvdObj) {
        var formFilters = this.getFormFilters(qvdObj);
        
        // Get default values for custom filters
        var formFiltersByField = {desktop: {}, mobile: {}};
        $.each(formFilters, function (filterName, filter) {
            // For desktop
            formFiltersByField['desktop'][filter.filterField] = formFiltersByField['desktop'][filter.filterField] || {};
            formFiltersByField['desktop'][filter.filterField][filterName] = filter.displayDesktop;
            
            // For mobile
            formFiltersByField['mobile'][filter.filterField] = formFiltersByField['mobile'][filter.filterField] || {};
            formFiltersByField['mobile'][filter.filterField][filterName] = filter.displayMobile;
        });
        
        return formFiltersByField;
    },
    
    getCurrentCustomization: function (qvdObj) {
        var currentCustomization = {};

        var listColumns = this.getListColumns(qvdObj);
        
        // Get default values for custom columns
        var listColumnsByField = {};
        $.each(listColumns, function (fieldName, column) {
            $.each(column.fields, function (iField, field) {
                currentCustomization[field] = currentCustomization[field] || {};
                currentCustomization[field]['listColumns'] = currentCustomization[field]['listColumns'] || {};
                currentCustomization[field]['listColumns'][fieldName] = column.display;
            });
        });
        
        //return listColumnsByField;
        
        var formFilters = this.getFormFilters(qvdObj);
        
        // Get default values for custom filters
        var formFiltersByField = {desktop: {}, mobile: {}};
        $.each(formFilters, function (fieldName, filter) {
            var field = filter.filterField;
            // For desktop
            currentCustomization[field] = currentCustomization[field] || {};
            currentCustomization[field]['desktopFilters'] = currentCustomization[field]['desktopFilters'] || {};
            currentCustomization[field]['desktopFilters'][fieldName] = filter.displayDesktop; 
            
            // For mobile
            currentCustomization[field] = currentCustomization[field] || {};
            currentCustomization[field]['mobileFilters'] = currentCustomization[field]['mobileFilters'] || {};
            currentCustomization[field]['mobileFilters'][fieldName] = filter.displayMobile;
        });
        
        return currentCustomization;
    },
    
    setCustomizationFields: function (qvdObj) {
        var filters = {};

        // If qvd object is not specified, all will be setted
        if (qvdObj) {
            filters.qvd_obj = qvdObj;
        }
        
        Wat.A.performAction('config_field_get_list', {}, filters, {}, this.setCustomizationFieldsCallback, this, false);
    },
    
    setCustomizationFieldsCallback: function (that) {
        if (that.retrievedData.status === 0 && that.retrievedData.result) {
            var fields = that.retrievedData.result.rows;

            $.each(fields, function (iField, field) {
                // If field options are not defined, we keep the default options doing nothing
                if (!field.filter_options) {
                    return;
                }
                
                var fieldName = field.name;               
                var qvdObj = field.qvd_obj;
                
                // Fix bad JSON format returned by API
                optionsJSON = field.filter_options.replace(/\\"/g,'"');
                optionsJSON = optionsJSON.replace(/^"/,'');
                optionsJSON = optionsJSON.replace(/"$/,'');
                
                var options = JSON.parse(optionsJSON);
                
                if (options.listColumns) {
                    $.each(options.listColumns, function (columnName, display) {
                        that.listColumns[qvdObj][columnName].display = display;
                    });
                }
                
                if (options.mobileFilters) {
                    $.each(options.mobileFilters, function (columnName, display) {
                        that.formFilters[qvdObj][columnName].displayMobile = display;
                    });
                }
                
                if (options.desktopFilters) {
                    $.each(options.desktopFilters, function (columnName, display) {
                        that.formFilters[qvdObj][columnName].displayDesktop = display;
                    });
                }
            });            
        }
    },
    
    selectedActions: {
        vm: [],
        user: [],
        host: [],
        osf: [],
        di: []
    },
    
    getSelectedActions: function (qvdObj) {
        return $.extend(true, [], this.selectedActions[qvdObj]);
    },
    
    listActionButton: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {}
    },
    
    getListActionButton: function (qvdObj) {
        return $.extend(true, [], this.listActionButton[qvdObj]);
    },
    
    // Breadcrumbs
    
    homeBreadCrumbs: {
        'screen': 'Home',
        'link': '#'
    },
    
    // List breadcrumbs
    listBreadCrumbs: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {},
        admin: {},
        tenant: {},
        role: {},
        acl: {}
    },   
        
    getListBreadCrumbs: function (qvdObj) {
        return this.listBreadCrumbs[qvdObj];
    },
    
    // List breadcrumbs
    detailsBreadCrumbs: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {},
        admin: {},
        tenant: {},
        role: {},
        acl: {}
    },   
        
    getDetailsBreadCrumbs: function (qvdObj) {
        return this.detailsBreadCrumbs[qvdObj];
    },
    
    showAll: function () {
        var firstLoad = $('.wrapper').css('visibility') == 'hidden';

        this.showContent();

        if (firstLoad) {
            $('.wrapper').css('visibility','visible').hide().fadeIn('fast');
            $('.menu').css('visibility','visible');
            $('.header-wrapper').css('visibility','visible').hide().fadeIn('fast');
            $('.content').css('visibility','visible').hide().fadeIn('fast');
            $('.breadcrumbs').css('visibility','visible').hide().fadeIn('fast');
            $('.menu-corner').css('visibility','visible');
        }
    },

    showContent: function () {
        // Set to the side box the same height of the content box
        $('.js-side').css('min-height', $('.content').height());

        $('.breadcrumbs').css('visibility','visible').hide().show();
        $('.content').css('visibility','visible').hide().show();
        $('.footer').css('visibility','visible').hide().show();
        $('.loading').hide();
    },

    showLoading: function () {
        var firstLoad = $('.wrapper').css('visibility') == 'hidden';

        if (!firstLoad) {
            $('.breadcrumbs').hide();
            $('.content').hide();
            $('.footer').hide();
            $('.loading').show();
        }
    },
    
    updateSortIcons: function (view) {
        // If not view is passed, use currentView
            if (view === undefined) {
                view = Wat.CurrentView;
            }
        
        // Get the context to the view
            var context = $('.' + view.cid);

        // Add sort icons to the table headers            
            var sortClassDefault = 'fa-sort';
            var sortClassAsc = 'fa-sort-asc';
            var sortClassDesc = 'fa-sort-desc';
                
            if (view.sortedBy != '') {
                switch(view.sortedOrder) {
                    case '': 
                        var sortClassSorted = '';
                        break;
                    case '-asc':            
                        var sortClassSorted = sortClassAsc;
                        break;
                    case '-desc':
                        var sortClassSorted = sortClassDesc;
                        break;
                }
            }

            context.find('th.sortable i').removeClass(sortClassDefault + ' ' + sortClassAsc + ' ' + sortClassDesc);
            context.find('th.sortable i').addClass(sortClassDefault);

            if (view.sortedBy != '') {
                context.find('[data-sortby="' + view.sortedBy + '"]').addClass('sorted');
                context.find('[data-sortby="' + view.sortedBy + '"] i').removeClass(sortClassDefault);
                context.find('[data-sortby="' + view.sortedBy + '"] i').addClass(sortClassSorted);
            }
    },
    
    enableDataPickers: function () {
        $('.datetimepicker').datetimepicker({
            dayOfWeekStart: 1,
            lang: 'en',
            format:'Y-m-d H:i'
        });
    },
    
    chosenConfiguration: function () {
        // Convert the filter selects to library chosen style
            var chosenOptions = {};
            chosenOptions.no_results_text = i18n.t('No results match');
            chosenOptions.placeholder_text_single = i18n.t('Select an option');
            chosenOptions.placeholder_text_multiple = i18n.t('Select some options');
            chosenOptions.search_contains = true;

            var chosenOptionsSingle = jQuery.extend({}, chosenOptions);
            chosenOptionsSingle.disable_search = true;
            chosenOptionsSingle.width = "150px";

            var chosenOptionsSingle100 = jQuery.extend({}, chosenOptionsSingle);
            chosenOptionsSingle100.width = "100%"; 

            var chosenOptionsAdvanced = jQuery.extend({}, chosenOptions);
        
            var chosenOptionsAdvanced100 = jQuery.extend({}, chosenOptions);
            chosenOptionsAdvanced100.width = "100%";
        
            // Store options to be retrieved in dinamic loads
            this.chosenOptions = {
                'single': chosenOptionsSingle,
                'single100': chosenOptionsSingle100,
                'advanced': chosenOptionsAdvanced,
                'advanced100': chosenOptionsAdvanced100
            };

            $('.filter-control select.chosen-advanced').chosen(chosenOptionsAdvanced100);
            $('.filter-control select.chosen-single').chosen(chosenOptionsSingle100);
            $('select.chosen-single').chosen(chosenOptionsSingle100);
    },
    
    chosenElement: function (selector, type) {
        $(selector).chosen(this.chosenOptions[type]);
    },
    
    updateChosenControls: function (selector) {
        var selector = selector || 'select.chosen-advanced, select.chosen-single';
        $(selector).trigger('chosen:updated');
    },
    
    // Set specific menu section as selected
    setMenuOpt: function (opt) {
        $('.menu-option').removeClass('menu-option--selected');
        $('.menu-option[data-target="' + opt + '"]').addClass('menu-option--selected');
    },
    
    renderMain: function () {
        var templateMain = Wat.A.getTemplate('main');
        // Fill the html with the template and the collection
        var template = _.template(
            templateMain, {
                loggedIn: Wat.C.loggedIn,
                loin: Wat.C.login,
                cornerMenu: this.cornerMenu
            });
        
        $('.bb-super-wrapper').html(template);
        
        this.updateLoginOnMenu();
    },
    
    tooltipConfiguration: function () {
        $( document ).tooltip({
            position: { 
                my: "left+15 center", 
                at: "right center" 
            },
            content: function(callback) {
                // Carriage return support
                callback($(this).prop('title').replace('\n', '<br />')); 
            }
        }
                             );
    },
    
    tagsInputConfiguration: function () {
        $('[name="tags"]').tagsInput({
            'defaultText': i18n.t('Add a tag')
        });
                
        
    },
    
    dialog: function (dialogConf) {
        $('.js-dialog-container').dialog({
            dialogClass: "loadingScreenWindow",
            resizable: false,
            dialogClass: 'no-close',
            collision: 'fit',
            modal: true,
            buttons: dialogConf.buttons,
            open: function(e) {                
                // Close message if open
                    $('.message-close').trigger('click');

                // Set title content manually to support HTML
                    $('.ui-dialog-titlebar').html(dialogConf.title);
                
                // Buttons style
                    var buttons = $(e.target).next().find('button');
                    var buttonsText = $(".ui-dialog-buttonset .ui-button .ui-button-text");

                    buttons.attr('class', '');
                    buttons.addClass("button");

                    var button1 = buttonsText[0];
                    var button2 = buttonsText[1];

                    Wat.T.translateElementContain($(button1));
                    Wat.T.translateElementContain($(button2));

                    // Delete jQuery UI default classes
                    buttons.attr("class", "");
                    // Add our button class
                    buttons.addClass("button");

                    $(button1).addClass(dialogConf.button1Class);
                    $(button2).addClass(dialogConf.button2Class);
                
                // Call to the callback function that will fill the dialog
                    dialogConf.fillCallback($(this));
                
                // Translate dialog strings
                    Wat.T.translateElement($(this).find('[data-i18n]'));
            },
            
            close: function () {
            }
        });     
    },
    
    updateLoginOnMenu: function () {
        $('.js-menu-corner').find('.js-login').html(Wat.C.login);
    },
    
    // Messages
    showMessage: function (msg, response) {
        // Process message to set expanded message if proceeds
        msg = this.processMessage (msg, response);
        
        this.clearMessageTimeout();
        
        if (msg.expandedMessage) {
            var expandIcon = '<i class="fa fa-plus-square-o expand-message js-expand-message"></i>';
            var expandedMessage = '<article class="expandedMessage">' + msg.expandedMessage + '</article>';
        }
        else {
            var expandIcon = '';
            var expandedMessage = '';
        }
        
        var summaryMessage = '<summary>' + msg.message + '</summary>';
        
        $('.message').html(expandIcon + summaryMessage + expandedMessage);
        $('.message-container').hide().slideDown(500);
        $('.message-container').removeClass('success error info warning');
        $('.message-container').addClass(msg.messageType);
        
        // Success and info messages will be hidden automatically
        if (msg.messageType != 'error') {
            this.messageTimeout = setTimeout(function() { 
                $('.message-close').trigger('click');
            },3000);
        }
    },
    
    closeMessage: function () {
        this.clearMessageTimeout();
        $('.js-message-container').slideUp(500);
    },
    
    setMessageTimeout: function () {
        this.clearMessageTimeout();
        this.messageTimeout = setTimeout(function() { 
            $('.message-close').trigger('click');
        },3000);
    },
    
    clearMessageTimeout: function () {
        if (this.messageTimeout) {
            clearInterval(this.messageTimeout);
        }
    },
    
    processMessage: function (msg, response) {
        if (!response) {
            return msg;
        }
        
        if (!msg.message) {
            msg.message = response.message;
        }
        
        switch (msg.messageType) {
            case 'error':
                msg.expandedMessage = msg.expandedMessage || '';
                
                if (response.message != msg.message) {
                    msg.expandedMessage += '<strong>' + response.message + '</strong> <br/><br/>';
                }
            
                if (response.failures && !$.isEmptyObject(response.failures)) {
                    msg.expandedMessage += this.getTextFromFailures(response.failures) + '<br/>';
                }
                break;
        }
        
        return msg;
    },
    
    getTextFromFailures: function (failures) {
        // Group failures by text
        var failuresByText = {};
        $.each(failures, function(id, text) {
            failuresByText[text] = failuresByText[text] || [];
            failuresByText[text].push(id);
        });
        
        // Get class from the icon of the selected item from menu to use it in list
        var elementClass = $('.menu-option--selected').find('i').attr('class');
        
        var failuresList = '<ul>';
        $.each(failuresByText, function(text, ids) {
            failuresList += '<li>';
            failuresList += '<i class="fa fa-angle-double-right strong">' + text + '</i>';
            failuresList += '<ul>';
            $.each(ids, function(iId, id) {
                if ($('.list')) {
                    var elementName = $('.list').find('tr.row-' + id).find('.js-name .text').html();
                    if (!elementName) {
                        elementName = '(ID: ' + id + ')';
                    }
                    
                    failuresList += '<li class="' + elementClass + '">' + elementName + '</li>';
                }
                else {
                    failuresList += '<li class="' + elementClass + '">' + id + '</li>';
                }
            });
            failuresList += '</ul>';
            failuresList += '</li>';
        });
        
        failuresList += '</ul>';
        
        return failuresList;
    },
    
    
    fillCustomizeOptions: function (qvdObj) { 
        var listColumns = this.listColumns[qvdObj]
        var head = '<tr><th data-i18n="Column">' + i18n.t('Column') + '</th><th data-i18n="Show">' + i18n.t('Show') + '</th></tr>';
        var selector = '.js-customize-columns table';
        $(selector + ' tr').remove();
        $(selector).append(head);

        $.each(listColumns, function (fName, field) {
            if (field.fixed) {
                return;
            }

            var cellContent = Wat.I.controls.CheckBox({checked: field.display});
            
            var fieldText = field.text;
            
            if (field.noTranslatable) {
                var fieldTextTranslated = field.text;
            }
            else {
                var fieldTextTranslated = i18n.t(field.text);
            }
            
            var row = '<tr><td data-i18n="' + fieldText + '">' + fieldTextTranslated + '</td><td class="center">' + cellContent + '</td></tr>';
            
            $(selector).append(row);
        });
        
        var formFilters = this.formFilters[qvdObj]
        var head = '<tr><th data-i18n="Filter control">' + i18n.t('Filter control') + '</th><th data-i18n="Desktop version">' + i18n.t('Desktop version') + '</th><th data-i18n="Mobile version">' + i18n.t('Mobile version') + '</th></tr>';
        var selector = '.js-customize-filters table';
        $(selector + ' tr').remove();
        $(selector).append(head);

        $.each(formFilters, function (fName, field) {
            if (field.fixed) {
                return;
            }

            var cellContentDesktop = Wat.I.controls.CheckBox({checked: field.display && field.device != 'mobile'});
            var cellContentMobile = Wat.I.controls.CheckBox({checked: field.display && field.device != 'desktop'});
            
            var fieldType = '';
            switch(field.type) {
                case 'text':
                    fieldType = 'Text input';
                    break;
                case 'select':
                    fieldType = 'Combo box';
                    break;
            }
            
            var fieldText = field.text;
            
            if (field.noTranslatable) {
                var fieldTextTranslated = field.text;
            }
            else {
                var fieldTextTranslated = i18n.t(field.text);
            }
            
            var rowField = '<td><div data-i18n="' + fieldText + '">' + fieldTextTranslated + '</div><div class="second_row" data-i18n="' + fieldType + '">' + i18n.t(fieldType) + '</div></td>';
            var rowMobile = '<td class="center">' + cellContentDesktop + '</td>';
            var rowDesktop = '<td class="center">' + cellContentMobile + '</td></tr>';
            var row = '<tr>' + rowField + rowMobile + rowDesktop + '</tr>';
            
            $(selector).append(row);
        });
    },
    
    controls: {
        CheckBox: function (params) {
            var checked = '';
            if (params.checked){
                checked = 'checked';
            }

            var control = '<input type="checkbox" value="1" ' + checked + '/>';

            return control;
        },
    },
    
    getFieldTypeName: function (type) {
        var fieldType = '';
        switch(type) {
            case 'text':
                fieldType = 'Text input';
                break;
            case 'select':
                fieldType = 'Combo box';
                break;
        }
        
        return fieldType;
    },
    
    
    validateForm: function (context) {
        var blankControls = $( context + " input[data-required]:blank:visible" );
        if(blankControls.length > 0) {
            blankControls.addClass('not_valid');
            blankControls.parent().find('.validation-message').remove();
            blankControls.parent().append('<div class="second_row--error validation-message">' + i18n.t('Required field') + '</div>');
            return false;
        }
        
        var equalControls = $( context + " input[data-equal]:visible" );
        var equalValues = {};
        
        var returnFalse = false;
        
        $.each(equalControls, function (iEqual, equal) {
            var equalID = $(equal).attr('data-equal');
            if (equalValues[equalID]) {
                if (equalValues[equalID] != $(equal).val()) {
                    $(equal).addClass('not_valid');
                    $(equal).parent().find('.validation-message').remove();
                    $(equal).parent().append('<div class="second_row--error validation-message">' + i18n.t('Value doesnt match') + '</div>');
                    returnFalse = true;
                }
            }
            else {
                equalValues[equalID] = $(equal).val();
            }
        });
        
        if (returnFalse) {
            return false;
        }
        
        return true;
    },
    
    
    // Update the indicator of selected intems situated under the list table
    updateSelectedItems: function (selectedItemns) {        
        $('.elements-selected').html(selectedItemns);
    },
    
    confirm: function (templateName, successCallback, that) {        
        var dialogConf = {
            title: '<i class="fa fa-question"></i>',
            buttons : {
                "Cancel": function () {
                    $(this).dialog('close');
                },
                "Accept": function () {
                    $(this).dialog('close');
                    successCallback(that);
                }
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-check',
            fillCallback : function(target) {
                target.html(Wat.A.getTemplate(templateName));
            }
        }
        
        $("html, body").animate({ scrollTop: 0 }, 200);
        this.dialog(dialogConf);
    }
}