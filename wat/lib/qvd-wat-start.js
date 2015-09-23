"use strict";

(function (win, doc, $) {
    // Extend jQuery with pseudo selector :blank
    (function($) {
        $.extend($.expr[":"], {
            // http://docs.jquery.com/Plugins/Validation/blank
            blank: function(a) {
                return !$.trim(a.value);
            },
        });
    })(jQuery);
    
	$(doc).ready(function() {
        // If desktop mode is forced, change viewport's meta tag
        if ($.cookie('forceDesktop')) {
            $('meta[name="viewport"]').prop('content', 'width=1024, initial-scale=1, maximum-scale=1');
        }
        
        // Hide customizer to show only if is necessary
        Wat.I.C.hideCustomizer();
        
        // Attach fast click events to separate tap from click
        Wat.I.attachFastClick();
        
        // Setup ajax calls queue
        Wat.C.setupAjaxQueue();
        
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
        
        var templates = {
            main: {
                name: 'main'
            },
            menu: {
                name: 'menu'
            },
            editorCommon: {
                name: 'editor/common'
            },
            editorCommonProperties: {
                name: 'editor/common-properties'
            },
            relatedDoc: {
                name: 'doc/related-links'
            },
            viewCustomize: {
                name: 'view/customize'
            },
            viewCustomizerTool: {
                name: 'config/customizer-tool'
            },
            viewFormCustomize: {
                name: 'view/customize-form'
            }
        }

        // Get templates and after that read config file
        Wat.A.getTemplates(templates, readConfigFile);
	});
})(window, document, jQuery)
