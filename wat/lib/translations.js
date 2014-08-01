"use strict";

$( window ).load(function() {
    translate();
});

function translate () {
    $.i18n.init({
        //resGetPath: 'lib/languages/__lng__.json',
        resGetPath: 'lib/languages/en.json',
        useLocalStorage: false,
        debug: false,
        fallbackLng: 'en',
    }, function() {        
        // Translate all the elements with attribute 'data-i18n'
        $('[data-i18n]').i18n();
        
        // Other chains
        $('.footer').html(i18n.t('qvd_web_administration_tool_by',  $('.footer').attr('data-link')));
        
        // Translatable buttons
        $.each($('.js-traductable_button'), function(index, button) {
            var translation = i18n.t(i18n.t($(button).html().trim()));
            $(button).html(translation);
        });
        
        // Convert the filter selects to library chosen style
        var chosenOptions = {};
        chosenOptions.no_results_text = i18n.t('tSearch.no_results_match');
        chosenOptions.search_contains = true;
        
        var chosenOptionsSingle = jQuery.extend({}, chosenOptions);
        chosenOptionsSingle.disable_search = true;
        chosenOptionsSingle.width = "200px";
        
        var chosenOptionsSingle100 = jQuery.extend({}, chosenOptionsSingle);
        chosenOptionsSingle100.width = "100%"; 
        
        var chosenOptionsAdvanced100 = jQuery.extend({}, chosenOptions);
        chosenOptionsAdvanced100.width = "100%";
        
        $('.filter-control select.chosen-advanced').chosen(chosenOptionsAdvanced100);
        $('.filter-control select.chosen-single').chosen(chosenOptionsSingle100);
        $('select.chosen-single').chosen(chosenOptionsSingle);
        
        // After all the translations do custom actions that need to have the content translated
        addSortIcons(currentView);
        
        // When all is translated and loaded, hide loading spinner and show content
        showAll();
    });
}

function translateElementContain (element) {
    var translated = i18n.t($(element).html());
    $(element).html(translated);
}

function translateElement (element) {
   element.i18n();
}
