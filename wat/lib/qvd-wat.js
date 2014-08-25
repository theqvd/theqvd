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
        
        // List views
        ListView: {},
        UserListView: {},
        VMListView: {},
        NodeListView: {},
        
        // Details views
        DetailsView: {},
        UserDetailsView: {},
        VMDetailsView: {},
        NodeDetailsView: {}
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
};


(function (win, doc, $) {
	$(doc).ready(function() {
        // Interface onfiguration
        Wat.I.cornerMenuEvents();
        Wat.I.tooltipConfiguration();
        Wat.I.mobileMenuConfiguration();
        
        // Instantiate the router
        var app_router = new Wat.Router;

        // ------- List sections ------- //
        app_router.on('route:listVM', function (field, value) {
            // Note the variable in the route definition being passed in here
            Wat.I.showLoading();
            setMenuOpt('vms');
            if (!$.isEmptyObject(Wat.CurrentView )) {
                Wat.CurrentView.undelegateEvents();
            }
            
            var params = {};
            if (field !== null) {
                switch(field) {
                    case 'user':
                        params.filters = {"user_id": value};
                        break;
                    case 'node':
                        params.filters = {"host_id": value};
                        break;
                    case 'osf':
                        params.filters = {"osf_id": value};
                        break;;
                    case 'di':
                        params.filters = {"di_id": value};
                        break;
                }
            }
            
            Wat.CurrentView = new Wat.Views.VMListView(params);
        });        
        
        app_router.on('route:listUser', function () {
            Wat.I.showLoading();
            setMenuOpt('users');
            if (!$.isEmptyObject(Wat.CurrentView )) {
                Wat.CurrentView.undelegateEvents();
            }
            
            Wat.CurrentView = new Wat.Views.UserListView();
        });       
        
        app_router.on('route:listNode', function () {
            Wat.I.showLoading();
            setMenuOpt('nodes');
            if (!$.isEmptyObject(Wat.CurrentView )) {
                Wat.CurrentView.undelegateEvents();
            }
            
            Wat.CurrentView = new Wat.Views.NodeListView();
        });      
        
        app_router.on('route:listOSF', function () {
            Wat.I.showLoading();
            setMenuOpt('osfs');
            if (!$.isEmptyObject(Wat.CurrentView )) {
                Wat.CurrentView.undelegateEvents();
            }
            
            Wat.CurrentView = new Wat.Views.OSFListView();
        });    
        
        app_router.on('route:listDI', function (field, value) {
            Wat.I.showLoading();
            setMenuOpt('dis');
            if (!$.isEmptyObject(Wat.CurrentView )) {
                Wat.CurrentView.undelegateEvents();
            }
            
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
            
            Wat.CurrentView = new Wat.Views.DIListView(params);
        });
        
        
        
        // ------- Details sections ------- //
        app_router.on('route:detailsUser', function (id) {
            Wat.I.showLoading();
            setMenuOpt('users');
            if (!$.isEmptyObject(Wat.CurrentView )) {
                Wat.CurrentView.undelegateEvents();
            }
            Wat.CurrentView = new Wat.Views.UserDetailsView({"id": id});
        });
        
        app_router.on('route:detailsVM', function (id) {
            Wat.I.showLoading();
            setMenuOpt('vms');
            if (!$.isEmptyObject(Wat.CurrentView )) {
                Wat.CurrentView.undelegateEvents();
            }
            Wat.CurrentView = new Wat.Views.VMDetailsView({"id": id});
        });
        
        app_router.on('route:detailsNode', function (id) {
            Wat.I.showLoading();
            setMenuOpt('nodes');
            if (!$.isEmptyObject(Wat.CurrentView )) {
                Wat.CurrentView.undelegateEvents();
            }
            Wat.CurrentView = new Wat.Views.NodeDetailsView({"id": id});
        });
        
        app_router.on('route:detailsOSF', function (id) {
            Wat.I.showLoading();
            setMenuOpt('osfs');
            if (!$.isEmptyObject(Wat.CurrentView )) {
                Wat.CurrentView.undelegateEvents();
            }
            Wat.CurrentView = new Wat.Views.OSFDetailsView({"id": id});
        });
        
        app_router.on('route:detailsDI', function (id) {
            Wat.I.showLoading();
            setMenuOpt('dis');
            if (!$.isEmptyObject(Wat.CurrentView )) {
                Wat.CurrentView.undelegateEvents();
            }
            Wat.CurrentView = new Wat.Views.DIDetailsView({"id": id});
        });
        
        
        
        // ------- Default load ------- //
        app_router.on('route:defaultRoute', function (actions) {
            console.info( actions ); 
        });

        // Start Backbone history
        Backbone.history.start();
        
        // When click on a menu option, redirect to this section
        $('.menu-option').click(function() {
            var id = $(this).attr('id');
            win.location = '#/' + id;
        });
        
        // Set specific menu section as selected
        function setMenuOpt (opt) {
            $('.menu-option').removeClass('menu-option--selected');
            $('#' + opt).addClass('menu-option--selected');
        }
        
	});
})(window, document, jQuery)
