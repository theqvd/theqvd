// Pure interface utilities
Wat.I = {
    cornerMenu : {},
    
    listColumns: {
        vm: [],
        user: [],
        node: [],
        osf: [],
        di: []
    },
    
    formFilters: {
        vm: [],
        user: [],
        node: [],
        osf: [],
        di: []
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
            format:'Y-m-d h:i'
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

            var chosenOptionsAdvanced100 = jQuery.extend({}, chosenOptions);
            chosenOptionsAdvanced100.width = "100%";
        
            // Store options to be retrieved in dinamic loads
            this.chosenOptions = {
                'single': chosenOptionsSingle,
                'single100': chosenOptionsSingle100,
                'advanced100': chosenOptionsAdvanced100
            };

            $('.filter-control select.chosen-advanced').chosen(chosenOptionsAdvanced100);
            $('.filter-control select.chosen-single').chosen(chosenOptionsSingle100);
            $('select.chosen-single').chosen(chosenOptionsSingle);
    },
    
    chosenElement: function (selector, type) {
        $(selector).chosen(this.chosenOptions[type]);
    },
    
    updateChosenControls: function (selector) {
        var selector = selector || 'select.chosen-advanced, select.chosen-single';
        $(selector).trigger('chosen:updated');
    },
    
    mobileMenuConfiguration: function () {
        $('.js-mobile-menu').click(function () {
            $('.menu').slideToggle();
        });
        
        $('.menu .menu-option').click(function () {
            if ($('.js-mobile-menu').css('display') != 'none') {
                $('.menu').slideUp();
            }
        });
    },
    
    cornerMenuEvents: function () {
       // Show/hide the corner menu
       $('.js-menu-corner li:has(ul)').hover(
          function(e)
          {
             $(this).find('ul').css({display: "block"});
          },
          function(e)
          {
             $(this).find('ul').css({display: "none"});
          }
       );
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
            title: dialogConf.title,
            resizable: false,
            dialogClass: 'no-close',
            collision: 'fit',
            modal: true,
            buttons: dialogConf.buttons,
            open: function(e) {                
                // Close message if open
                    $('.message-close').trigger('click');

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
    
    updateLoginOnMenu: function (login) {
        $('.js-menu-corner').find('.login').html(login);
    },
    
    // Messages
    showMessage: function (msg, response) {
        // Process message to set expanded message if proceeds
        msg = this.processMessage (msg, response);
        
        this.clearMessageTimeout();
        
        $("html, body").animate({ scrollTop: 0 }, 200);

        if (msg.expandedMessage) {
            var expandIcon = '<i class="fa fa-plus-square-o expand-message js-expand-message" title="' + i18n.t('See more') + '..."></i>';
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
    
    fillCustomizeOptions: function (that) {
        var customizeOptions = that.retrievedData.result.rows;
        console.log(customizeOptions);
        
        var customizeOptionsTable;
        
        var head = '<tr><th>Field</th><th>List</th><th>Details</th><th>List filters</th></td>';
        $('.js-customize-options table').append(head);

        $.each(customizeOptions, function (iOption, option) {
            var row = '<tr><td>' + option.name + '</td><td>' + Wat.I.controls.CheckBox({checked: option.get_list}) + '</td><td>' + Wat.I.controls.CheckBox({checked: option.get_details}) + '</td><td>' + Wat.I.controls.CheckBox({checked: option.filter_list}) + '</td></td>';
            
            $('.js-customize-options table').append(row);
            console.log(option);
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
    }
    
}