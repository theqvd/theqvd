function languageDocTest() {
    module( "Documentation tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });
    
        test("Screens Info modal doc", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            
            assertions += Object.keys(Wat.I.docSections[DOC_DEFAULT_LANGUAGE]).length * DOC_AVAILABLE_LANGUAGES.length;

            expect(assertions);
            
            $.each(DOC_AVAILABLE_LANGUAGES, function (iLan, lan) {
                $.each (Wat.I.docSections[lan], function (qvdObj, section) {
                    var docHTML = Wat.A.getDocSection(section.guide, section.section, false, '../');
                    notEqual(docHTML, null, 'Documentation section "' + section.section + '" was found in guide "' + section.guide + '"');
                });
            });
        });
}