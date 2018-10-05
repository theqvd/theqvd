// Pure interface utilities
Up.I = {
    // Styles Customizer Tool (interface-customize.js)
    C: {},
    // Chosen controls (interface-chosen.js)
    Chosen: {},
    // Graphs (interface-graphs.js)
    G: {},
    // Templates (interface-templates.js)
    T: {},
    // Messages (interface-messages.js)
    M: {},
    
    menu : {},
    mobileMenu : {},
    cornerMenu : {},
    
    fixedFilters: {},
    
    getCornerMenu: function () {
        return $.extend(true, [], this.cornerMenu);
    },

    docSections: {
    },
    
    showAll: function () {
        this.showContent();

        $('.wrapper').css('visibility','visible').hide().fadeIn('fast');
        $('.js-header-wrapper').css('visibility','visible');
        if (!Up.I.isMobile()) {
            $('.js-menu-lat').css('visibility','visible');
        }
        $('.js-menu-corner').css('visibility','visible');
        $('.js-mobile-menu-hamburger').css('visibility','visible');
        $('.js-server-datetime-wrapper').css('visibility','visible');
        $('.related-doc').css('visibility','visible');       
        $('.js-force-desktop, .js-unforce-desktop').css('visibility','visible').hide().fadeIn('fast');
        
        $('.loading').hide();
    },
    
    showContent: function () {
        $('.js-content').css('visibility','visible').hide().show();
        $('.footer').css('visibility','visible').hide().show();
        $('.loading').hide();
        $('.related-doc').css('visibility','visible').hide().show();
    },

    showLoading: function () {
        var firstLoad = $('.wrapper').css('visibility') == 'hidden';

        if (!firstLoad) {
            $('.js-content').hide();
            $('.footer').hide();
            $('.loading').show();
            $('.related-doc').hide();
        }
    },
    
    renderMain: function () { 
        var that = this;
        
        var template = _.template(
            Up.TPL.main, {
                forceDesktop: $.cookie('forceDesktop')
            });
        
        $('.bb-super-wrapper').html(template);

        this.renderHeader();
                
        Up.I.updateLoginOnMenu();

        if (Up.L.loggedIn) {
            this.renderMenu();
        }
        else {
            $('.js-menu-corner').hide();
            $('.js-mobile-menu-hamburger').hide();
            $('.js-server-datetime-wrapper').hide();
        }
    },
    
    renderHeader: function () {
        var template = _.template(
            Up.TPL.header, {
                cornerMenu: this.cornerMenu
            });
        
        $('.bb-header').html(template);
        
        Up.I.showAll();
    },  
    
    renderHeaderMobile: function (section, subTitle) {
        var template = _.template(
            Up.TPL.headerMobile, {
                sectionTitle: Up.I.menuOriginal[section] ? Up.I.menuOriginal[section].text : 'Profile',
                sectionSubTitle: subTitle,
                cornerMenu: this.cornerMenu,
                section: section
            });
        
        $('.bb-header').html(template);
        
        Up.T.translate();
        Up.I.showAll();
    },
    
    renderMenu: function () {
        var footerLinks = {
            'copyright': 'http://qindel.com/',
            'terms': 'http://qindel.com/',
            'policy': 'http://qindel.com/',
            'contact': 'javascript:',
        };
        
        var currentLan = window.i18n.lng() == '__lng__' ? window.navigator.language : window.i18n.lng();
        switch (currentLan) {
            case 'es':
                footerLinks.contact = "http://theqvd.com/es/contacto";
                break;
            default:
                footerLinks.contact = "http://theqvd.com/contact";
                break;
        }
        
        // Fill the html with the template and the collection
        var template = _.template(
            Up.TPL.menu, {
                userMenu: Up.I.userMenu || {},
                helpMenu: Up.I.helpMenu || {},
                configMenu: Up.I.configMenu || {},
                setupMenu: Up.I.setupMenu || {},
                menu: Up.I.menu || {},
                mobileMenu: Up.I.mobileMenu || {},
                footerLinks: footerLinks,
                qvdObj: this.qvdObj
            });
        $('.bb-menu-lat').html(template);   
    },
    
    tooltipBind: function () {
        $('[title]').qtip({
            position: { 
                target: 'mouse', // Track the mouse as the positioning target
                adjust: { x: 5, y: 5 }, // Offset it slightly from under the mouse
                viewport: $(window)
            },
            adjust: {
                method: 'flip'
        }
        });
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
        
        var dialog = $(div).dialog({
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
                    
                    // Delete jQuery UI default classes
                    buttons.attr("class", "");
                    // Add our button class
                    buttons.addClass("button");
                
                    $.each(buttons, function (iButton, button) {
                        Up.T.translateElementContain($(button).find('span'));
                        $(button).addClass(dialogConf.buttonClasses[iButton]);
                    });
                
                // Call to the callback function that will fill the dialog
                    dialogConf.fillCallback($(this), that);
                
                // Translate dialog strings
                    Up.T.translateElement($(this).find('[data-i18n]'));
                
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
        
        Up.CurrentView.dialogs.push(dialog);
        
        Up.I.Mobile.afterOpenDialog();
    },
    
    updateLoginOnMenu: function () {
        var loop = setInterval(function () {
            if (Up.T.loaded) {
                $('.js-menu-corner').find('.js-login-welcome').html($.i18n.t('Welcome, __name__', {name: Up.C.account.username}));
                clearInterval(loop);
            }
        }, 100);
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
        
        if (selectedItems == 0) {
            this.hideSelectedItemsMenu();
        }
        else {
            this.showSelectedItemsMenu();
                this.checkVisibilityConditions();
                
            if (selectedItems == 1) {
                $('.js-only-one').show();
                $('.js-only-massive').hide();
            }
            else {
                $('.js-only-massive').show();
                $('.js-only-one').hide();
            }
        }
    },
    
    checkVisibilityConditions: function () {
        if ($('[data-visibility-conditioned]').length > 0) {
            $.each($('[data-visibility-conditioned]'), function (i, element) {
                var conditionType = $(element).attr('data-visibility-cond-type');
                var conditionField = $(element).attr('data-visibility-cond-field');
                var conditionValue = $(element).attr('data-visibility-cond-value');
                    
                // Process AND/OR clauses

                // For single and OR clauses, necessary matches will be just one
                var necessaryMatches = 1;
                
                // AND
                if (conditionValue.indexOf(' AND ') != -1) {
                    var conditionValues = conditionValue.split(' AND ');
                    var necessaryMatches = conditionValues.length;
                }
                // OR
                else if (conditionValue.indexOf(' OR ') != -1) {
                    var conditionValues = conditionValue.split(' OR ');
                }
                // Single
                else {
                    var conditionValues = [conditionValue];
                }
                
                $(element).hide();
                
                var positiveItems = 0;
                $.each(Up.CurrentView.selectedItems, function (i, selectedId) {
                    var selectedModel = Up.CurrentView.collection.where({id: selectedId})[0];      
                    
                    // If any item is out of view (other page), all options will be shown
                    if (selectedModel == undefined) {
                        $(element).show();
                        return false;
                    }
                    
                    var matches = 0;
                    $.each(conditionValues, function (iVal, conditionValue) {     
                        switch(conditionType) {
                            case 'eq':
                                    if (selectedModel.get(conditionField) == conditionValue) {
                                            matches++;   
                                    }
                                break;
                            case 'ne':
                                    if (selectedModel.get(conditionField) != conditionValue) {
                                            matches++;     
                                    }
                                break;
                        }
                    });
                    
                    if (matches >= necessaryMatches) {
                        positiveItems++;
                    }
                });
                
                // If any item was positive in check, show the conditioned option
                if (positiveItems > 0) {
                    $(element).show();
                }
            });
        }
    },

    hideSelectedItemsMenu: function () {
        $('.js-pagination,.js-list,.js-shown-elements').animate({ 'marginRight': '0px' }, 200);
        $('.js-action-selected').hide( "slide" );
    },
    
    showSelectedItemsMenu: function () {
        $('.js-pagination,.js-list,.js-shown-elements').animate({ 'marginRight': $('.js-action-selected').css('width') }, 200);
        $('.js-action-selected').show( "slide" );
    },
    
    confirm: function (templateName, successCallback, that, loadingBlock) {        
        var dialogConf = {
            title: '<i class="fa fa-question"></i>',
            buttons : {
                "Cancel": function () {
                    Up.I.closeDialog($(this));
                },
                "Accept": function () {
                    Up.I.closeDialog($(this));
                    if (loadingBlock) {
                        Up.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
                    }
                    successCallback(that);
                }
            },
            buttonClasses : [CLASS_ICON_CANCEL + ' js-button-cancel', CLASS_ICON_ACCEPT + ' js-button-accept'],
            fillCallback : function(target) { 
                var templates = Up.I.T.getTemplateList('confirm', {templateName: templateName});

                Up.A.getTemplates(templates, Up.I.fillTemplate, {
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
                Up.I.closeDialog($(this));
                window.location = '#documentation/' + guideSection[0].guide;
            },
            Close: function (e) {
                Up.I.closeDialog($(this));
            }
        };

        dialogConf.buttonClasses = [CLASS_ICON_DOC + ' js-button-read-full-doc', CLASS_ICON_CLOSE + ' js-button-close'];

        dialogConf.fillCallback = function (target, that) {
            // Back scroll of the div to top position
            target.html('');
            $('.js-dialog-container').animate({scrollTop:0});

            // Fill div with section documentation
            $.each (guideSection, function (iGS, gS) {
                Up.D.fillDocSection(gS.guide, gS.section, undefined, undefined, target);
            });
        };


        Up.I.dialog(dialogConf, this);
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
        
        var selectedId = FILTER_ALL;
        
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
        
        if (Up.CurrentView.cid == that.cid) {
            realView = Up.CurrentView;
        }
        else {
            $.each (Up.CurrentView.sideViews, function (iV, view) {
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
        
        if (typeof Up.CurrentView[functionName] == 'function' && Up.CurrentView.qvdObj == qvdObj) {
            usefulView = Up.CurrentView;
        }
        else {
            $.each (Up.CurrentView.sideViews, function (iV, view) {
                if (view != undefined && typeof view[functionName] == 'function' && view.qvdObj == qvdObj) {
                    usefulView = view;
                }
            });
        }
        
        return usefulView;
    },
    
    closeDialog: function (dialog) {
        dialog.dialog('close').remove();
        Up.CurrentView.dialogs.pop();
    },
    
    closeLastDialog: function () {
        var nDialogs = Up.CurrentView.dialogs.length;
        
        this.closeDialog(Up.CurrentView.dialogs[nDialogs-1]);
    },
    
    addOddEvenRowClass: function (listContainer) {
        $.each($(listContainer).find('table.list tr'), function (i, row) {
            if ($(row).children().eq(0).prop("tagName") != 'TD') {
                return;
            }
            
            var type = 'odd';
            if (i % 2 == 0) {
                type = 'even';
            }
            
            $(row).find('td.cell-link').addClass(type);
        });
    },
    
    startServerClock: function () {
        if (Up.C.serverTimeUpdater == undefined && Up.C.serverDatetime) {
            // Get timestamp from configuration and print on interface
            var d = new Date (Up.C.serverDatetime);
            var date = d.toString().slice(0, 15);
            var time = d.toString().slice(16, 24);
            $('.js-server-date').html(date);
            $('.js-server-time').html(time);
        
            // Create a loop to update timestamp every second
            Up.C.serverTimeUpdater = setInterval(function(){
                var currentDatetime = $('.js-server-date').html() + ' ' + $('.js-server-time').html();
                var currentUnixTimestamp = Math.round(new Date(currentDatetime).getTime()/1000);
                currentUnixTimestamp++;
                var d = new Date (currentUnixTimestamp*1000);
                var date = d.toString().slice(0, 15);
                var time = d.toString().slice(16, 24);
                $('.js-server-date').html(date);
                $('.js-server-time').html(time);
            }, 1000);
        }
    },
    
    stopServerClock: function () {
        $('.js-server-datetime-wrapper').hide();
        clearInterval(Up.C.serverTimeUpdater);
        delete Up.C.serverTimeUpdater;
        delete Up.C.serverDatetime;
    },
    
    attachFastClick: function () {
        // Items with class "needsclick" will be ignored
        FastClick.attach(document.body);
    },
    
    // If desktop mode is forced, change viewport's meta tag
    forceDesktop: function () {
        if ($.cookie('forceDesktop')) {
            $('meta[name="viewport"]').prop('content', 'width=1024, initial-scale=1, maximum-scale=1');
        }
    },
    
    
    // Fill template given target and templateName
    fillTemplate: function (element) {
        element.target.html(Up.TPL[element.templateName]);
        
        Up.T.translate();
    },

    // When change a filter, check fussion notes to delete the associated filter if is necessary
    solveFilterDependences: function (name, field) {        
        $.each(FUSSION_NOTES, function (fNKey, fNote) {
            var fName = '';
            
            if (fNote.qvdObj != Up.CurrentView.qvdObj) {
                return;
            }
            
            if (fNote.label == name) {
                fName = fNote.value;
            }
            
            if (fNote.value == name) {
                fName = fNote.label;
            }
            
            if (fName != '') {
                Up.I.cleanFussionFilter(fName);
            }
        });
    },
    
    // Clean list filter checking if is used in control or not
    cleanFussionFilter: function (fName) {
        // If not exist in filters use name directly
        if (!$('[name="' + fName + '"]').length) {
            Up.CurrentView.cleanFilter(fName);
        }
        else {
            Up.CurrentView.cleanFilter($('[name="' + fName + '"]').attr('data-filter-field'));

            switch($('[name="' + fName + '"]').prop('tagName')) {
                case 'INPUT':
                    $('[name="' + fName + '"]').val('');
                    break;
                case 'SELECT':
                    $('[name="' + fName + '"]').val(FILTER_ALL);
                    $('[name="' + fName + '"]').trigger('chosen:updated');
                    break;
            }
        }
    },  
    
    isMobile: function () {
        return !$('.js-header-logo-desktop').length || $('.js-header-logo-desktop').css('display') == 'none';
    },
    
    
    parseForm: function (context) {
        var params = {};

        $.each($(context).find('.js-form-field'), function (iField, field) {
            var fieldName = $(field).attr('name');
            var fieldType = $(field).attr('type');
            
            switch (fieldType) {
                case 'checkbox':
                    var fieldValue = $(field).is(':checked') ? 1 : 0;
                    break;
                default:
                    if ($(field).prop("tagName") == "TEXTAREA") {
                        if ($(field).val()) {
                            var fieldValue = $(field).val().split(/\n/);
                        }
                        else {
                            var fieldValue = [];
                        }
                    }
                    else {
                        var fieldValue = $(field).val();
                    }
                    break;
            }
            
            if ($(field).attr('data-subfield')) {
                var subfield = $(field).attr('data-subfield');
                var fieldType = 'value';
                
                // If element is list of another
                if ($(field).attr('data-listof')) {
                    fieldName = $(field).attr('data-listof');
                    fieldType = 'list';
                }

                if (!params[subfield]) {
                    params[subfield] = {};
                }
                
                if (!params[subfield][fieldName]) {
                    params[subfield][fieldName] = {
                        value: "",
                        list: []
                    };
                }
                
                params[subfield][fieldName][fieldType] = fieldValue;
            }
            else {
                params[fieldName] = fieldValue;
            }
        })
        
        return params;
    },
    
    setMenuOptionSelected: function (dataTarget) {
        $('.menu-option').removeClass('menu-option--current');
        $('[data-target="' + dataTarget + '"]').addClass('menu-option--current');
    },
    
    // Render edition
    renderEditionMode: function (model, target) {
        Up.CurrentView.modelInEdition = model.clone();
        
        var canBeDisabled = typeof model.get('settings_enabled') != 'undefined';
        
        // List of settings
        var template = _.template(
            Up.TPL.settingsEditor, {
                model: model,
                canBeDisabled: canBeDisabled,
                cid: Up.CurrentView.cid
            }
        );
        
        target.html(template);
        
        this.renderEditionModeParameters(model, !canBeDisabled || model.get('settings_enabled'));
    },
    
    renderEditionModeParameters: function (model, settingsEnabled) {
        var settings = model.get('settings');
        
        // Active workspace
        if (Up.CurrentView.wsCollection && !settingsEnabled) {
            var activatedWorkspace = Up.CurrentView.wsCollection.findWhere({'active': 1});
            var settings = activatedWorkspace.get('settings');
        }
        
        var template = _.template(
            Up.TPL.settingsEditorParameters, {
                settings: settings,
                settingsEnabled: settingsEnabled
            }
        );
        
        $('.bb-editor-parameters').html(template);
        
        var client = settings.client.value;

        $('[data-client-mode]').hide();
        $('[data-client-mode="both"]').show();
        $('[data-client-mode="' + client + '"]').show();
        
        Up.I.Chosen.element($('select[name="connection"]'), 'single100');
        Up.I.Chosen.element($('select[name="client"]'), 'single100');
        
        Up.T.translate();
    },
    
    getDesktopTitleString: function (state, blocked) {
        if (blocked) {
            return "Blocked";
        }
        else if (state == 'disconnected') {
            return "Connect";
        }
        else if (state == 'connected') {
            return "Reconnect";
        }
        
        return "";
    },
    
    getStateString: function (state) {
        switch (state) {
            case 'connected':
                var stateString = 'Connected';
                break;
            case 'disconnected':
                var stateString = 'Disconnected';
                break;
            case 'connecting':
                var stateString = 'Connecting';
                break;
            case 'reconnecting':
                var stateString = 'Reconnecting';
                break;
        }
        
        return stateString;
    },
    
    isDialogOpen: function () {
        return Up.CurrentView.dialogs.length ? true : false;
    },
    
    updateProgressMessage: function (text, awIcon) {
        $('.loading-little-message').html($.i18n.t('progress:' + text )+ '...');
        $('.loading-little-message').attr('class', 'loading-little-message fa fa-' + awIcon);
        
        Up.T.translate();
    },
    
    stopProgress: function () {
        clearInterval(this.progressInterval);
    }
}