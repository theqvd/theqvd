// Pure interface utilities
Wat.I = {
    // Graphs
    G: {},
    
    menu : {},
    mobileMenu : {},
    cornerMenu : {},
    
    getCornerMenu: function () {
        return $.extend(true, [], this.cornerMenu);
    },
    
    detailsFields: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {},
        role: {},
        administrator: {},
        log: {}
    }, 
    
    detailsDefaultFields: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {},
        role: {},
        administrator: {},
        log: {}
    },
    
    getDetailsFields: function (qvdObj) {
        return $.extend(true, {}, this.detailsFields[qvdObj]);
    },   
    
    listFields: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {},
        role: {},
        administrator: {},
        log: {}
    },
    
    listDefaultFields: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {},
        role: {},
        administrator: {},
        log: {}
    }, 
    
    getListColumns: function (qvdObj) {
        return $.extend(true, {}, this.listFields[qvdObj]);
    },
    
    getListDefaultColumns: function (qvdObj) {
        return $.extend(true, {}, this.listDefaultFields[qvdObj]);
    },
    
    restoreListColumns: function () {
        this.listFields = $.extend(true, {}, this.listDefaultFields);
    },
    
    formFilters: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {},
        log: {}
    }, 
    
    formDefaultFilters: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {},
        log: {}
    },
    
    getFormFilters: function (qvdObj) {
        return $.extend(true, {}, this.formFilters[qvdObj]);
    },   
    
    getFormDefaultFilters: function (qvdObj) {
        return $.extend(true, {}, this.formDefaultFilters[qvdObj]);
    },
        
    restoreFormFilters: function () {
        this.formFilters = $.extend(true, {}, this.formDefaultFilters);
    },
    
    getCurrentCustomization: function (qvdObj) {
        var currentCustomization = {};

        var listFields = this.getListColumns(qvdObj);
        
        // Get default values for custom columns
        var listFieldsByField = {};
        $.each(listFields, function (fieldName, column) {
            $.each(column.fields, function (iField, field) {
                currentCustomization[field] = currentCustomization[field] || {};
                currentCustomization[field]['listFields'] = currentCustomization[field]['listFields'] || {};
                currentCustomization[field]['listFields'][fieldName] = column.display;
            });
        });
        
        //return listFieldsByField;
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
        return;
        var filters = {};

        // If qvd object is not specified, all will be setted
        if (qvdObj) {
            filters.qvd_obj = qvdObj;
        }

        Wat.A.performAction('config_field_get_list', {}, filters, {}, this.setCustomizationFieldsCallback, this);
    },
    
    setCustomizationFieldsCallback: function (that) {
        if (that.retrievedData.status === 0 && that.retrievedData) {
            var fields = that.retrievedData.rows;

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
                
                if (options.listFields) {
                    $.each(options.listFields, function (columnName, display) {
                        that.listFields[qvdObj][columnName].display = display;
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
        return $.extend(true, {}, this.selectedActions[qvdObj]);
    },
    
    listActionButton: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {}
    },
    
    docSections: {
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
        administrator: {},
        tenant: {},
        role: {},
        acl: {},
        log: {}
    },   
        
    getListBreadCrumbs: function (qvdObj) {
        var breadcrumbs = this.listBreadCrumbs[qvdObj];
        
        return breadcrumbs;
    },
    
    // List breadcrumbs
    detailsBreadCrumbs: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {},
        administrator: {},
        tenant: {},
        role: {},
        acl: {},
        log: {}
    },   
        
    getDetailsBreadCrumbs: function (qvdObj) {
        var breadcrumbs = this.detailsBreadCrumbs[qvdObj];
        
        this.applyBredcrumbsACLs(breadcrumbs);
        
        return breadcrumbs;
    },
    
    applyBredcrumbsACLs: function (breadcrumbs) {
        var level = breadcrumbs;
        while (1) {
            if (level.linkACL != undefined && !Wat.C.checkACL(level.linkACL)) {
                delete level.link;
            }
            
            if (level.next != undefined) {
                level = level.next;
            }
            else {
                break;
            }
        }
    },
    
    showAll: function () {
        var firstLoad = $('.wrapper').css('visibility') == 'hidden';

        this.showContent();

        if (firstLoad) {
            $('.wrapper').css('visibility','visible').hide().fadeIn('fast');
            $('.menu').css('visibility','visible');
            $('.header-wrapper').css('visibility','visible').hide().fadeIn('fast');
            $('.js-content').css('visibility','visible').hide().fadeIn('fast');
            $('.breadcrumbs').css('visibility','visible').hide().fadeIn('fast');
            $('.menu-corner').css('visibility','visible');
            $('.related-doc').css('visibility','visible');                
            $('.loading').show();
        }
    },
    
    showContent: function () {
        this.adaptSideSize();

        $('.breadcrumbs').css('visibility','visible').hide().show();
        $('.js-content').css('visibility','visible').hide().show();
        $('.footer').css('visibility','visible').hide().show();
        $('.loading').hide();
        $('.related-doc').css('visibility','visible').hide().show();
    },

    showLoading: function () {
        var firstLoad = $('.wrapper').css('visibility') == 'hidden';

        if (!firstLoad) {
            $('.breadcrumbs').hide();
            $('.js-content').hide();
            $('.footer').hide();
            $('.loading').show();
            $('.related-doc').hide();
        }
    },
    
    // Adapt size of the side layer to the content to show separator line from top to bottom
    adaptSideSize: function () {
        // Set to the side box the same height of the content box
        $('.js-side').css('min-height', $('.list-block').height());
    },
    
    addSortIcons: function (cid) {
        $('.' + cid + ' th.sortable').prepend(HTML_SORT_ICON);
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

            context.find('th.sortable i.sort-icon').removeClass(sortClassDefault + ' ' + sortClassAsc + ' ' + sortClassDesc);
            context.find('th.sortable i.sort-icon').addClass(sortClassDefault);

            if (view.sortedBy != '') {
                context.find('[data-sortby="' + view.sortedBy + '"]').addClass('sorted');
                context.find('[data-sortby="' + view.sortedBy + '"] i').removeClass(sortClassDefault);
                context.find('[data-sortby="' + view.sortedBy + '"] i').addClass(sortClassSorted);
            }
    },
    
    enableDataPickers: function () {
        $('.datetimepicker').datetimepicker({
            dayOfWeekStart: 1,
            lang: Wat.C.language,
            format:'Y-m-d H:i',
            minDate: 0
        });
        
        $('.datepicker-past').datetimepicker({
            dayOfWeekStart: 1,
            lang: Wat.C.language,
            format:'Y-m-d',
            maxDate: 0,
            timepicker: false,
            onSelectDate: function (content, target) {
                $(target).trigger('input');
            },
            closeOnDateSelect: true
        });
    },
    
    chosenConfiguration: function () {
        // Convert the filter selects to library chosen style
            var chosenOptions = {};
            chosenOptions.no_results_text = i18n.t('No results match');
            chosenOptions.placeholder_text_single = i18n.t('Loading');
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
                                
        if ($(selector).find('option').length == 0) {
            $(selector + '+.chosen-container span').html($.i18n.t('Empty'));
        }

    },
    
    // Set specific menu section as selected
    setMenuOpt: function (opt) {
        // Set as selected the menu option
        $('.menu-option').removeClass('menu-option--selected');
        $('.menu-option[data-target="' + opt + '"]').addClass('menu-option--selected');
        
        // Change styles on corner menu current option
        var menu = $('.menu-option[data-target="' + opt + '"]').attr('data-menu');
        
        $('.js-menu-corner .menu-option').removeClass('menu-option-current');
        $('.js-menu-corner .js-menu-option-' + menu).addClass('menu-option-current');
        
        if (opt == 'home' || !opt) {
            var menu = 'platform';
        }
        $('.menu').hide();
        $('.js-' + menu + '-menu').show();
    },
    
    renderMain: function () { 
        var that = this;
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.main, {
                loggedIn: Wat.C.loggedIn,
                cornerMenu: this.cornerMenu
            });
        
        $('.bb-super-wrapper').html(template);
        
        if (Wat.C.loggedIn) {
            this.renderMenu();
        }
        else {
            $('.menu-corner').hide();
        }
        
        this.updateLoginOnMenu();
    },
    
    renderMenu: function () {
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.menu, {
                userMenu: Wat.I.userMenu,
                helpMenu: Wat.I.helpMenu,
                configMenu: Wat.I.configMenu,
                setupMenu: Wat.I.setupMenu,
                menu: Wat.I.menu,
                mobileMenu: Wat.I.mobileMenu
            });

        $('.bb-menu').html(template);
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
            },
            open: function (event, ui) {
                $(ui.tooltip).parent().mouseleave(function() {
                    $(ui.tooltip).hide();
                });
            },
            hide: false
        }
                             );
    },
    
    tagsInputConfiguration: function () {
        $('[name="tags"]').tagsInput({
            'defaultText': i18n.t('Add a tag')
        });
    },
    
    dialog: function (dialogConf, that) {
        var div = document.createElement("DIV");
        $(div).addClass('dialog-container');
        $(div).addClass('js-dialog-container');
        document.body.appendChild(div);
        
        $(div).dialog({
            dialogClass: "loadingScreenWindow",
            resizable: false,
            resize: true,
            dialogClass: 'no-close',
            collision: 'fit',
            modal: true,
            buttons: dialogConf.buttons,
            open: function(e) {
                // Empty dialog content
                    $(e.target).html('');

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
                    dialogConf.fillCallback($(this), that);
                
                // Translate dialog strings
                    Wat.T.translateElement($(this).find('[data-i18n]'));
                
                // Focus on first text input
                    $(this).find('input[type="text"]').eq(0).trigger('focus');
                
                // Disable scrolling in window to improve dialog experience
                    $('html, body').css({
                        'overflow': 'hidden',
                        'height': '100%'
                    });
            },
            
            close: function () {
                // Enable scrolling in window when close
                    $('html, body').attr('style', '');
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
        
        var summaryMessage = '<summary>' + $.i18n.t(msg.message) + '</summary>';
        
        $('.message').html(expandIcon + summaryMessage + expandedMessage);
        
        Wat.T.translate();

        $('.message-container').hide().slideDown(500);
        $('.message-container').removeClass('success error info warning');
        $('.message-container').addClass(msg.messageType);
        
        // Success and info messages will be hidden automatically
        if (msg.messageType != 'error' && msg.messageType != 'warning') {
            this.messageTimeout = setTimeout(function() { 
                Wat.I.closeMessage();
            },3000);
        }
    },

    getTextFromFailures: function (failures) {
        // Group failures by text
        var failuresByText = {};
        $.each(failures, function(id, text) {
            failuresByText[text.message] = failuresByText[text.message] || [];
            failuresByText[text.message].push(id);
        });
        
        // Get class from the icon of the selected item from menu to use it in list
        var elementClass = $('.menu-option--selected').find('i').attr('class');
        
        var failuresList = '<ul>';
        $.each(failuresByText, function(text, ids) {
            failuresList += '<li>';
            failuresList += '<i class="fa fa-angle-double-right strong" data-i18n="' + text + '"></i>';
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
        var listFields = this.listFields[qvdObj]
        var head = '<tr><th data-i18n="Column">' + i18n.t('Column') + '</th><th data-i18n="Show">' + i18n.t('Show') + '</th></tr>';
        var selector = '.js-customize-columns table';
        $(selector + ' tr').remove();
        $(selector).append(head);

        $.each(listFields, function (fName, field) {
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
        
        var anySelectedControls = $('[data-any-selected]');
        $.each(anySelectedControls, function (iAny, any) {
            if (!$(any).val()) {
                $(any).parent().find('.chosen-single').addClass('not_valid');
                $(any).parent().find('.validation-message').remove();
                $(any).parent().append('<div class="second_row--error validation-message">' + i18n.t('No value is selected') + '</div>');
                returnFalse = true;
            }
        });
        
        if (returnFalse) {
            return false;
        }
        
        return true;
    },
    
    
    // Update the indicator of selected intems situated under the list table
    updateSelectedItems: function (selectedItems) { 
        $('.elements-selected').html(selectedItems);
    },
    
    confirm: function (templateName, successCallback, that, loadingBlock) {        
        var dialogConf = {
            title: '<i class="fa fa-question"></i>',
            buttons : {
                "Cancel": function () {
                    Wat.I.closeDialog($(this));
                },
                "Accept": function () {
                    Wat.I.closeDialog($(this));
                    if (loadingBlock) {
                        Wat.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
                    }
                    successCallback(that);
                }
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-check',
            fillCallback : function(target) {                
                var templates = {
                    confirmTemplate: {
                        name: templateName,
                        cache: false
                    }
                }

                Wat.A.getTemplates(templates, Wat.A.fillTemplate, {
                    target: target,
                    templateName: 'confirmTemplate'
                });
            }
        }
        
        $("html, body").animate({ scrollTop: 0 }, 200);
        this.dialog(dialogConf);
    },
    
    loadingBlock: function (message) {
        $('.loading-big-message').html(message);
        $('.loading-big').show();
        $('html, body').css({
            'overflow': 'hidden',
            'height': '100%'
        });
    },
    
    loadingUnblock: function () {
        $('.loading-big').hide();
        $('html, body').attr('style', '');
    },
    
    loadDialogDoc: function (guideSection) {
        var dialogConf = {};

        dialogConf.title = $.i18n.t("Documentation");

        dialogConf.buttons = {
            "Read full documentation": function (e) {
                Wat.I.closeDialog($(this));
                window.location = '#documentation/' + guideSection[0].guide;
            },
            Close: function (e) {
                Wat.I.closeDialog($(this));
            }
        };

        dialogConf.button1Class = 'fa fa-book';
        dialogConf.button2Class = 'fa fa-check';

        dialogConf.fillCallback = function (target, that) {
            // Back scroll of the div to top position
            target.html('');
            $('.js-dialog-container').animate({scrollTop:0});

            // Fill div with section documentation
            $.each (guideSection, function (iGS, gS) {
                Wat.A.fillDocSection(gS.guide, gS.section, undefined, undefined, target);
            });
        };


        Wat.I.dialog(dialogConf, this);
    },
    
    getFilterStartingOptions: function (options) {
        if (!options) {
            return undefined;
        }
        
        var returnedOptions = {};
        
        $.each (options, function (iOption, option) {
            returnedOptions[option.value] = option.text;
        });
        
        return returnedOptions;
    },
    
    getFilterSelectedId: function (options) {
        if (!options) {
            return undefined;
        }
        
        var selectedId = -1;
        
        $.each (options, function (iOption, option) {
            if (option.selected) {
                selectedId = option.value;
                return false;
            }
        });
        
        return selectedId;
    },
    
    goTop: function () {
        $('html,body').animate({
            scrollTop: 0
        }, 'fast');
    },
    
    getRealView: function (that) {
        var realView = null;
        
        if (Wat.CurrentView.cid == that.cid) {
            realView = Wat.CurrentView;
        }
        else {
            $.each (Wat.CurrentView.sideViews, function (iV, view) {
                if (view != undefined && view.cid == that.cid) {
                    realView = view;
                }
            });
        }
        
        return realView;
    },
    
    // Get first view among current and side views with a determinate function
    getUsefulView: function (qvdObj, functionName) {
        var usefulView = null;
        
        if (typeof Wat.CurrentView[functionName] == 'function' && Wat.CurrentView.qvdObj == qvdObj) {
            usefulView = Wat.CurrentView;
        }
        else {
            $.each (Wat.CurrentView.sideViews, function (iV, view) {
                if (view != undefined && typeof view[functionName] == 'function' && view.qvdObj == qvdObj) {
                    usefulView = view;
                }
            });
        }
        
        return usefulView;
    },
    
    closeDialog: function (dialog) {
        dialog.dialog('close').remove();
        delete Wat.CurrentView.dialog;
    }
}