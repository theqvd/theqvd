"use strict";

var Wat = {
    // Backbone components: Models, Collections, Views and Router
    Models: {
        // Common model with connection method
        Model: {},
        
        // Models
        User: {},
        VM: {},
        Node: {}
    },
    Collections: {
        // Common collection with connection method
        Collection: {},
        
        // Collections
        Users: {},
        VMs: {},
        Nodes: {}
    },
    Views: {
        // Common view with menu and breadcrumbs
        MainView: {},
        
        //Home
        HomeView: {},
        
        // List views
        ListView: {},
        UserListView: {},
        VMListView: {},
        NodeListView: {},
        
        // Details views
        DetailsView: {},
        UserDetailsView: {},
        VMDetailsView: {},
        HostDetailsView: {},
        
        // Setup
        ConfigCustomizeView: {}
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
	$(doc).ready(function() {
        // Interface onfiguration
        Wat.I.renderMain();
        Wat.I.cornerMenuEvents();
        Wat.I.tooltipConfiguration();
        Wat.I.mobileMenuConfiguration();
        Wat.I.updateLoginOnMenu();
        Wat.I.setCustomizationFields();
        
        // Instantiate the router
        var app_router = new Wat.Router;

        // ------- List sections ------- //
        app_router.on('route:listVM', function (field, value) {            
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
                        
            app_router.performRoute('vms', Wat.Views.VMListView, params);
        });        
        
        app_router.on('route:listUser', function () {
            app_router.performRoute('users', Wat.Views.UserListView);
        });       
        
        app_router.on('route:listNode', function () {
            app_router.performRoute('hosts', Wat.Views.NodeListView);
        });      
        
        app_router.on('route:listOSF', function () {
            app_router.performRoute('osfs', Wat.Views.OSFListView);
        });    
        
        app_router.on('route:listDI', function (field, value) {
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
            
            app_router.performRoute('dis', Wat.Views.DIListView, params);
        });
        
        
        
        // ------- Details sections ------- //
        app_router.on('route:detailsUser', function (id) {
            app_router.performRoute('users', Wat.Views.UserDetailsView, {"id": id});
        });
        
        app_router.on('route:detailsVM', function (id) {
            app_router.performRoute('vms', Wat.Views.VMDetailsView, {"id": id});
        });
        
        app_router.on('route:detailsNode', function (id) {
            app_router.performRoute('hosts', Wat.Views.HostDetailsView, {"id": id});
        });
        
        app_router.on('route:detailsOSF', function (id) {
            app_router.performRoute('osfs', Wat.Views.OSFDetailsView, {"id": id});
        });
        
        app_router.on('route:detailsDI', function (id) {
            app_router.performRoute('dis', Wat.Views.DIDetailsView, {"id": id});
        });
        
        
        
        // ------- Configuration sections ------- //
        app_router.on('route:setupCustomize', function (actions) {
            app_router.performRoute('', Wat.Views.ConfigCustomizeView);
        });
        
        
        
        // ------- Default load ------- //
        app_router.on('route:defaultRoute', function (actions) {
            app_router.performRoute('', Wat.Views.HomeView);
        });

        // Start Backbone history
        Backbone.history.start();
	});
})(window, document, jQuery)
