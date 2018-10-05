// Translation setup and utilities
Up.T = {
    defaultLan: 'en',
    lan: '',
    loaded: false,
    
    // Translation configuration and actions to be done when language file is loaded
    initTranslate: function(lan) {        
        lan = lan || Up.C.account.language;
        
        lan = this.getLanguage(lan);
        var that = this;
        $.i18n.init({
            ns: {
                namespaces: [
                    'main',
                    'api-responses',
                    'progress'
                ],
                defaultNs: 'main',
                fallbackNs: 'main'
            },
            resGetPath: APP_PATH + 'lib/translations/dictionaries/' + lan + '/__ns__.json',
            useLocalStorage: false,
            debug: false,
            fallbackLng: this.defaultLan,
        }, function () {
            that.loaded = true;
        });
        
        this.lan = lan;
    },
    
    getLanguage: function (lan) {
        if (lan == 'auto') {
            lan = navigator.language;
        }
        
        // If language is not among the WAT supported languages, set default
        if ($.inArray(lan, Object.keys(UP_LANGUAGES)) == -1) {
            lan = this.defaultLan;
        }

        return lan;
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
        
        Up.T.translateXDays();
        Up.T.translateXMonths();
        Up.T.translateXYears();
        
        // Translatable buttons
        $.each($('.js-traductable_button'), function(index, button) {
            var translation = i18n.t(i18n.t($(button).html().trim()));
            $(button).html(translation);
        });
        
        // Configure different chosen controls (advanced jquery select controls)
        Up.I.Chosen.configuration();
        
        // Process tooltips
        Up.I.tooltipBind();
        
        // Update all the chosen select controls
        $('select').trigger('chosen:updated');  
        
        // The selects that were in loading process, will be tagged as loading
        $('[data-loading]+.chosen-container span').html($.i18n.t('Loading'));
    },
    
    // Translate and show all
    translateAndShow: function () {
        Up.T.translate();
        
        // When all is translated and loaded, hide loading spinner and show content
        Up.I.showAll(); 
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
