function languageDocTest() {
    module( "Documentation tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });
    
        asyncTest("Screens Info modal doc", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            
            assertions += Object.keys(Wat.I.docSections[DOC_DEFAULT_LANGUAGE]).length * DOC_AVAILABLE_LANGUAGES.length;

            expect(assertions);
            
            stop(assertions-1);
            
            $.each(DOC_AVAILABLE_LANGUAGES, function (iLan, lan) {
                $.each (Wat.I.docSections[lan], function (qvdObj, section) {
                    Wat.A.fillTemplateString = function (string, target, toc, section) {
                        notEqual(string, null, 'Documentation section "' + section + '" was found in guide "' + section.guide + '"');
                        start();
                    };
                    
                    Wat.A.fillDocSection(section.guide, section.section + '', false, '../');
                });
            });
        });
}