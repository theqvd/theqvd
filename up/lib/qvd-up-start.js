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


                // ------- Details sections ------- //
                Wat.Router.app_router.on('route:detailsUser', function (id) {
                    Wat.Router.app_router.performRoute('users', Wat.Views.UserDetailsView, {"id": id});
                });

                Wat.Router.app_router.on('route:detailsVM', function (id) {
                    Wat.Router.app_router.performRoute('vms', Wat.Views.VMDetailsView, {"id": id});
                });
                

                // ------- Help sections ------- //
                Wat.Router.app_router.on('route:about', function (actions) {
                    Wat.Router.app_router.performRoute('about', Wat.Views.AboutView);
                });
                Wat.Router.app_router.on('route:documentation', function (actions) {
                    Wat.Router.app_router.performRoute('documentation', Wat.Views.DocView);
                });
                Wat.Router.app_router.on('route:documentationGuide', function (guide, section) {
                    Wat.Router.app_router.performRoute('documentation', Wat.Views.DocView, {
                        "guide": guide,
                        "section": section
                    });
                });
                Wat.Router.app_router.on('route:documentationSearch', function (searchKey) {
                    Wat.Router.app_router.performRoute('documentation', Wat.Views.DocView, {
                        "searchKey": searchKey
                    });
                });



                 // ------- Current administrator ------- //
                Wat.Router.app_router.on('route:logout', function (actions) {
                    Wat.C.logOut();

                    Wat.C.configureVisibility();
                    Wat.I.renderMain();

                    Wat.Router.app_router.performRoute();
                });          
                Wat.Router.app_router.on('route:profile', function (actions) {
                    Wat.Router.app_router.performRoute('profile', Wat.Views.ProfileView);
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
