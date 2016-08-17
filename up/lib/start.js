"use strict";

(function (win, doc, $) {
	$(doc).ready(function() {
        // Force desktop Mode if is necessary
        Up.I.forceDesktop();     
        
        if (Up.C.setupLibraries) {
            // Setup JS libraries
            Up.C.setupLibraries(); 

            // Setup jquery addons
            Up.C.setupJQuery();       
        }

        // Get list of the necessary templates on starting
        var templates = Up.I.T.getTemplateList('starting');
        
        // Get templates and after that read config file
        Up.A.getTemplates(templates, Up.C.readConfigFile);
	});
})(window, document, jQuery)
