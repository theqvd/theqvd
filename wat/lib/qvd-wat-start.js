"use strict";

(function (win, doc, $) {
	$(doc).ready(function() {
        // Force desktop Mode if is necessary
        Wat.I.forceDesktop();     
        
        // Setup JS libraries
        Wat.C.setupLibraries(); 
        
        // Setup jquery addons
        Wat.C.setupJQuery();       

        var templates = Wat.I.T.getTemplateList('starting');

        // Get templates and after that read config file
        Wat.A.getTemplates(templates, Wat.C.readConfigFile);
	});
})(window, document, jQuery)
