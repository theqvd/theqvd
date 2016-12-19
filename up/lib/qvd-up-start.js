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
        // Init API address variables
        Wat.C.initApiAddress();
        
        // Setup jQuery ajax to store all requests in a requests queue
        $.ajaxSetup({
            beforeSend: function(jqXHR) {
                Wat.C.requests.push(jqXHR);
            },
            complete: function(jqXHR) {
                var index = $.inArray(jqXHR, Wat.C.requests);
                if (index > -1) {
                    Wat.C.requests.splice(index, 1);
                }
            }
        });
        
        Wat.C.afterLogin = function () {
            // Load translation file
            Wat.T.initTranslate();

            // Interface configuration
            Wat.I.renderMain();

            //Wat.I.bindCornerMenuEvents();
            Wat.I.tooltipConfiguration();

            // Binding events manually because backbone doesnt allow bind events to dialogs loaded dinamically
            //Wat.B.bindCommonEvents();
            
            if (!Wat.C.routerHistoryStarted) {
                // Instantiate the router
                Wat.Router.app_router = new Wat.Router;

                // ------- List sections ------- //
                Wat.Router.app_router.on('route:listVM', function (searchHash) {   
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }
                    Wat.Router.app_router.performRoute('vms', Wat.Views.VMListView, params);
                });
                
                 // ------- Current administrator ------- //
                Wat.Router.app_router.on('route:logout', function (actions) {
                    Wat.C.logOut();

                    Wat.C.configureVisibility();
                    Wat.I.renderMain();

                    Wat.Router.app_router.performRoute();
                });   
                Wat.Router.app_router.on('route:myviews', function (actions) {
                    Wat.Router.app_router.performRoute('myviews', Wat.Views.MyViewsView);
                });       


                // ------- Default load ------- //
                Wat.Router.app_router.on('route:defaultRoute', function (searchHash) {
                    window.location = '#/vms';
                    //Wat.Router.app_router.performRoute('', Wat.Views.HomeView);
                });

                // Start Backbone history
                Backbone.history.start();   
                
                Wat.C.routerHistoryStarted = true;
            }
        
        };
        
        var templates = {
            main: {
                name: 'main'
            },
            menu: {
                name: 'menu'
            },
        }

        Wat.A.getTemplates(templates, Wat.C.rememberLogin);
	});
})(window, document, jQuery)
