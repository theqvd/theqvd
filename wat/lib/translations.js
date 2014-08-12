// Translation setup and utilities
Wat.T = {
    a: null,
    // Translation configuration and actions to be done when language file is loaded
    translate: function() {
        this.a = $.i18n.init({
            //resGetPath: 'lib/languages/__lng__.json',
            resGetPath: 'lib/languages/en.json',
            useLocalStorage: false,
            debug: false,
            fallbackLng: 'en',
        }, function() {
            // Translate all the elements with attribute 'data-i18n'
            $('[data-i18n]').i18n();

            // Other chains
            $('.footer').html(i18n.t('QVD Web Administration Tool, by %s',  $('.footer').attr('data-link')));

            // Translatable buttons
            $.each($('.js-traductable_button'), function(index, button) {
                var translation = i18n.t(i18n.t($(button).html().trim()));
                $(button).html(translation);
            });

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

            // After all the translations do custom actions that need to have the content translated
            Wat.I.addSortIcons();

            // When all is translated and loaded, hide loading spinner and show content
            Wat.I.showAll();
        });
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
