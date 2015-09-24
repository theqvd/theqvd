"use strict";

(function (win, doc, $) {
	$(doc).ready(function() {
        // If desktop mode is forced, change viewport's meta tag
        if ($.cookie('forceDesktop')) {
            $('meta[name="viewport"]').prop('content', 'width=1024, initial-scale=1, maximum-scale=1');
        }
        
        // Hide customizer to show only if is necessary
        Wat.I.C.hideCustomizer();
        
        // Attach fast click events to separate tap from click
        Wat.I.attachFastClick();      
        
        // Setup jquery addons
        Wat.C.setupJQuery();
        
        Wat.C.afterLogin = function () {
            // Load translation file
            Wat.T.initTranslate();

            // Interface onfiguration
            Wat.I.renderMain();
            
            // If customizer is enabled, show it
            if ((Wat.C.isSuperadmin() || Wat.C.isMultitenant() === 0) && $.cookie('styleCustomizer')) {
                Wat.I.C.initCustomizer();
            }
            else {
                Wat.I.C.hideCustomizer();
            }
            
            // Start server clock
            Wat.I.startServerClock();

            //Wat.I.bindCornerMenuEvents();
            Wat.I.tooltipConfiguration();

            // Binding events manually because backbone doesnt allow bind events to dialogs loaded dinamically
            Wat.B.bindCommonEvents();

            if (Wat.C.isLogged()) {
                Wat.I.setCustomizationFields();
            }
            
            // If the router isnt instantiate, do it
            if (Wat.Router.watRouter == undefined) {          
                // Instantiate the router
                Wat.Router.watRouter = new Wat.Router;
            }
        };
            
        // Read config file "/config.json"
        var readConfigFile = function () {
            //After readl configuration file, continue start
            Wat.C.readConfigFile(continueStart);
        };        
        
        var continueStart = function () {
            // After read configuration file, we will set API address
            Wat.C.initApiAddress();
            
            // Remember login from cookies
            Wat.C.rememberLogin();
        };
        
        var templates = Wat.I.T.getTemplateList('starting');

        // Get templates and after that read config file
        Wat.A.getTemplates(templates, readConfigFile);
	});
})(window, document, jQuery)
