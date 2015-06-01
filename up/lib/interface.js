// Pure interface utilities
Wat.I = {
    renderMain: function () { 
        var that = this;
        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.main, {
                loggedIn: Wat.C.loggedIn,
                cornerMenu: this.cornerMenu
            });
        
        $('.bb-super-wrapper').html(template);
        
        if (!Wat.C.loggedIn) {
            $('.menu-corner').hide();
        }
        
        this.updateLoginOnMenu();
    },
    
    updateLoginOnMenu: function () {
        $('.js-menu-corner').find('.js-login').html(Wat.C.login);
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
            }
        });
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
    
    // Adapt size of the side layer to the content to show separator line from top to bottom
    adaptSideSize: function () {
        // Set to the side box the same height of the content box
        $('.js-side').css('min-height', $('.list-block').height());
    },
    
    updateChosenControls: function (selector) {
        var selector = selector || 'select.chosen-advanced, select.chosen-single';
        $(selector).trigger('chosen:updated');
                                
        if ($(selector).find('option').length == 0) {
            $(selector + '+.chosen-container span').html($.i18n.t('Empty'));
        }

    },
}