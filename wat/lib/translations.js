// Translation setup and utilities
Wat.T = {
    // Translation configuration and actions to be done when language file is loaded
    translate: function() {
        var that = this;
        
        $.i18n.init({
            //resGetPath: 'lib/languages/__lng__.json',
            resGetPath: APP_PATH + 'lib/languages/en.json',
            useLocalStorage: false,
            debug: false,
            fallbackLng: 'en',
        }, this.afterTranslate);
    },
    
    // After all the translations do custom actions that need to have the content translated
    afterTranslate: function () {
        // Translate all the elements with attribute 'data-i18n'
        
        $('[data-i18n]').i18n();

        // Force chosen to selects that contain any option with data-i18n attribute
        $('select[data-contain-i18n]').trigger('chosen:updated');

        // Translate the "X days" strings
        $.each($('[data-days]'), function (iDays, days) {
            var daysTranslated = i18n.t('__count__ days', {'count': $(days).attr('data-days')});
            $(days).html(daysTranslated);
        });

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
    }    
}
