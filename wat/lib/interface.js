// Pure interface utilities
Wat.I = {
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
    
    addSortIcons: function (view) {
        // If not view is passed, use currentView
            if (view === undefined) {
                view = Wat.CurrentView;
            }
        
        // Get the context to the view
            var context = $('.' + view.cid);

        // Add sort icons to the table headers
            var sortIconHtml = '<i class="fa fa-sort sort-icon"></i>';

            if (view.sortedBy != '') {
                switch(view.sortedOrder) {
                    case '': 
                        var sortIconHtmlSorted = sortIconHtml;
                        break;
                    case '-asc':            
                        var sortIconHtmlSorted = '<i class="fa fa-sort-asc sort-icon"></i>';
                        break;
                    case '-desc':
                        var sortIconHtmlSorted = '<i class="fa fa-sort-desc sort-icon"></i>';
                        break;
                }
            }

            if (view.sortedBy != '') {
                context.find('[data-sortby="' + view.sortedBy + '"]').addClass('sorted');
            }

            $.each(context.find('th.sortable'), function(index, cell) {        
                var headerCont = $(cell).html();
                if (view.sortedBy == '' || view.sortedBy != $(cell).attr('data-sortby')) {
                    $(cell).html(headerCont + sortIconHtml);
                }
                else {
                    $(cell).html(headerCont + sortIconHtmlSorted);
                }
            });

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
            chosenOptions.search_contains = true;

            var chosenOptionsSingle = jQuery.extend({}, chosenOptions);
            chosenOptionsSingle.disable_search = true;
            chosenOptionsSingle.width = "150px";

            var chosenOptionsSingle100 = jQuery.extend({}, chosenOptionsSingle);
            chosenOptionsSingle100.width = "100%"; 

            var chosenOptionsAdvanced100 = jQuery.extend({}, chosenOptions);
            chosenOptionsAdvanced100.width = "100%";

            $('.filter-control select.chosen-advanced').chosen(chosenOptionsAdvanced100);
            $('.filter-control select.chosen-single').chosen(chosenOptionsSingle100);
            $('select.chosen-single').chosen(chosenOptionsSingle);
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
                
                
                // Disable scroll on body to improve user experience with dialog scroll
                    //$('body').css('overflow-y', 'hidden');

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
                // Re-enable scroll on body disabled when open dialog
                //$('body').css('overflow-y', 'auto');
            }
        });     
    },
    
    showMessage: function (msg) {
        $('.message').html(msg.message);
        $('.message-container').slideDown(500);
        $('.message-container').removeClass('success error info warning');
        $('.message-container').addClass(msg.messageType);
        
        // Success messages will be hidden automatically
        if (msg.messageType == 'success') {
            messageTimeout = setTimeout(function() { 
                $('.message-close').trigger('click');
            },3000);
        }
    }
}