"use strict";

(function (win, doc, $) {
	$(doc).ready(function() {
        // Force desktop Mode if is necessary
        Wat.I.forceDesktop();     
        
        if (Wat.C) {
        // Setup JS libraries
        Wat.C.setupLibraries(); 
        
        // Setup jquery addons
        Wat.C.setupJQuery();       
        }

        // Get list of the necessary templates on starting
        var templates = Wat.I.T.getTemplateList('starting');

        // Get templates and after that read config file
        Wat.A.getTemplates(templates, Wat.C.readConfigFile);
	});
})(window, document, jQuery)
