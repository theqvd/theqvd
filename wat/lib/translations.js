"use strict";

$( window ).load(function() {
    translate();
});

function translate () {

}

function translateElementContain (element) {
    var translated = i18n.t($(element).html());
    $(element).html(translated);
}

function translateElement (element) {
   element.i18n();
}
