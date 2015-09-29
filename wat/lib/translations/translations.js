// Translation setup and utilities
Wat.T = {
    lan: '',
    // Translation configuration and actions to be done when language file is loaded
    initTranslate: function(lan) {        
        lan = lan || Wat.C.language;
        
        // If language is not among the WAT supported languages, check the tenant language
        if ($.inArray(lan, Object.keys(WAT_LANGUAGES)) == -1) {
            // If language is default, check if tenant language is among the WAT supported languages
            if (lan == 'default' && $.inArray(Wat.C.tenantLanguage, Object.keys(WAT_LANGUAGES)) != -1) {
                lan = Wat.C.tenantLanguage;
            }
            else {
                // If language is not supported, set auto mode to detect it from browser
                lan = '__lng__';
            }
        }

        $.i18n.init({
            resGetPath: APP_PATH + 'lib/translations/dictionaries/' + lan + '.json',
            useLocalStorage: false,
            debug: false,
            fallbackLng: 'en',
        }, this.translateAndShow);
        
        this.lan = lan;
    },
    
    // After all the translations do custom actions that need to have the content translated
    translate: function () {
        // If i18n is not a function, womething went wrong, not translate. Its possible that session expired or something
        if (!$.isFunction($('[data-i18n]').i18n)) {
            return;
        }
        
        // Translate all the elements with attribute 'data-i18n'
        $('[data-i18n]').i18n();

        // Force chosen to selects that contain any option with data-i18n attribute
        $('select[data-contain-i18n]').trigger('chosen:updated');
        
        Wat.T.translateXDays();
        Wat.T.translateXMonths();
        Wat.T.translateXYears();

        // Other chains
        $('.footer').html(i18n.t('QVD Web Administration Tool, by %s',  $('.footer').attr('data-link')));

        // Translatable buttons
        $.each($('.js-traductable_button'), function(index, button) {
            var translation = i18n.t(i18n.t($(button).html().trim()));
            $(button).html(translation);
        });
        
        // Configure different chosen controls (advanced jquery select controls)
        Wat.I.chosenConfiguration();

        // Add sort icons to header
        Wat.I.updateSortIcons();
        
        // Update all the chosen select controls
        $('select').trigger('chosen:updated');  
    },
    
    // Translate and show all
    translateAndShow: function () {
        Wat.T.translate();
        
        // When all is translated and loaded, hide loading spinner and show content
        Wat.I.showAll(); 
    },
    
    // Translate the content of an element passing the selector
    translateElementContain: function(selector) {
        var translated = i18n.t($(selector).html());
        $(selector).html(translated);
    },

    // Translate an element with i18n standard function
    translateElement: function(element) {
       element.i18n();
    },
    
    translateXDays: function() {
        // Translate the "X days" strings
        $.each($('[data-days]'), function (iDays, days) {
            var daysTranslated = i18n.t('__count__ days', {'count': $(days).attr('data-days')});
            $(days).html(daysTranslated);
        });
    },
    
    translateXMonths: function() {
        // Translate the "X months" strings
        $.each($('[data-months]'), function (iMonths, months) {
            var monthsTranslated = i18n.t('__count__ months', {'count': $(months).attr('data-months')});
            $(months).html(monthsTranslated);
        });
    },
        
    translateXYears: function() {
        // Translate the "X years" strings
        $.each($('[data-years]'), function (iYears, years) {
            var yearsTranslated = i18n.t('__count__ years', {'count': $(years).attr('data-years')});
            $(years).html(yearsTranslated);
        });
    }
}
