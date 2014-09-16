"use strict";

var Wat = {
    // Backbone components: Models, Collections, Views and Router
    Models: {
        // Common model with connection method
        Model: {},
        
        // Models
        User: {},
        VM: {},
        Host: {}
    },
    Collections: {
        // Common collection with connection method
        Collection: {},
        
        // Collections
        Users: {},
        VMs: {},
        Hosts: {}
    },
    Views: {
        // Common view with menu and breadcrumbs
        MainView: {},
        
        //Login
        LoginView: {},
        
        //Home
        HomeView: {},
        
        // List views
        ListView: {},
        UserListView: {},
        VMListView: {},
        HostListView: {},
        
        // Details views
        DetailsView: {},
        UserDetailsView: {},
        VMDetailsView: {},
        HostDetailsView: {},
        
        // Setup
        ConfigCustomizeView: {},
        
        // Help
        AboutView: {}
    },
    Router: {},
    
    // Current view store
    CurrentView: {},
    
    // Actions
    A: {},
    
    // Translation utilities
    T: {}, 
    
    // Interface utilities
    I: {},
    
    // Configuration
    C: {}, 
    
    // Binds
    B: {},
};


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
        // Remember login from cookies
        Wat.C.rememberLogin();
        // Interface onfiguration
        Wat.I.renderMain();
        //Wat.I.bindCornerMenuEvents();
        Wat.I.tooltipConfiguration();
        
        // Binding events manually because backbone doesnt allow bind events to dialogs loaded dinamically
        Wat.B.bindCommonEvents();
        
        if (Wat.C.isLogged()) {
            Wat.I.setCustomizationFields();
        }

        
        // Instantiate the router
        Wat.Router.app_router = new Wat.Router;

        // ------- List sections ------- //
        Wat.Router.app_router.on('route:listVM', function (field, value) {            
            var params = {};
            if (field !== null) {
                switch(field) {
                    case 'user':
                        params.filters = {"user_id": value};
                        break;
                    case 'host':
                        params.filters = {"host_id": value};
                        break;
                    case 'osf':
                        params.filters = {"osf_id": value};
                        break;
                    case 'di':
                        params.filters = {"di_id": value};
                        break;
                    case 'state':
                        params.filters = {"state": value};
                        break;
                }
            }
                        
            Wat.Router.app_router.performRoute('vms', Wat.Views.VMListView, params);
        });        
        
        Wat.Router.app_router.on('route:listUser', function () {
            Wat.Router.app_router.performRoute('users', Wat.Views.UserListView);
        });       
        
        Wat.Router.app_router.on('route:listHost', function () {
            Wat.Router.app_router.performRoute('hosts', Wat.Views.HostListView);
        });      
        
        Wat.Router.app_router.on('route:listOSF', function () {
            Wat.Router.app_router.performRoute('osfs', Wat.Views.OSFListView);
        });    
        
        Wat.Router.app_router.on('route:listDI', function (field, value) {
            /* 
               NOTE: This view is always filtered by osf. When no osf is passed
               as parameter, this filtering is performed dinamically to the
               first OSF of the filter's combo. Due this feature, the default
               filter will be an osf that doesn't exist: -1. In this way, we avoid
               to charge, unnecessarily, all the DIs for a second before the 
               definitive filter.
            */
            var params = {
                filters: {"osf_id": -1}
            }
            
            if (field !== null) {
                switch(field) {
                    case 'osf':
                        params.filters = {"osf_id": value};
                        break;
                }
            }
            
            Wat.Router.app_router.performRoute('dis', Wat.Views.DIListView, params);
        });
        
        
        
        // ------- Details sections ------- //
        Wat.Router.app_router.on('route:detailsUser', function (id) {
            Wat.Router.app_router.performRoute('users', Wat.Views.UserDetailsView, {"id": id});
        });
        
        Wat.Router.app_router.on('route:detailsVM', function (id) {
            Wat.Router.app_router.performRoute('vms', Wat.Views.VMDetailsView, {"id": id});
        });
        
        Wat.Router.app_router.on('route:detailsHost', function (id) {
            Wat.Router.app_router.performRoute('hosts', Wat.Views.HostDetailsView, {"id": id});
        });
        
        Wat.Router.app_router.on('route:detailsOSF', function (id) {
            Wat.Router.app_router.performRoute('osfs', Wat.Views.OSFDetailsView, {"id": id});
        });
        
        Wat.Router.app_router.on('route:detailsDI', function (id) {
            Wat.Router.app_router.performRoute('dis', Wat.Views.DIDetailsView, {"id": id});
        });
        
        
        
        // ------- Configuration sections ------- //
        Wat.Router.app_router.on('route:setupCustomize', function (actions) {
            Wat.Router.app_router.performRoute('', Wat.Views.ConfigCustomizeView);
        });    
        
        
        // ------- Help sections ------- //
        Wat.Router.app_router.on('route:about', function (actions) {
            Wat.Router.app_router.performRoute('', Wat.Views.AboutView);
        });
        
        
        
         // ------- Log-out ------- //
        Wat.Router.app_router.on('route:logout', function (actions) {
            Wat.C.logOut();
            
            Wat.I.renderMain();
            
            Wat.Router.app_router.performRoute();
        });       
        
        
        // ------- Default load ------- //
        Wat.Router.app_router.on('route:defaultRoute', function (actions) {
            Wat.Router.app_router.performRoute('', Wat.Views.HomeView);
        });

        // Start Backbone history
        Backbone.history.start();
	});
})(window, document, jQuery)
