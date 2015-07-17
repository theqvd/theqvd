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
            OSFListView: {},
            DIListView: {},
            TenantListView: {},
            AdminListView: {},
            RoleListView: {},
        
        // Details views
        DetailsView: {},
            UserDetailsView: {},
            VMDetailsView: {},
            HostDetailsView: {},
            OSFDetailsView: {},
            DIDetailsView: {},
            TenantDetailsView: {},
            AdminDetailsView: {},
            RoleDetailsView: {},
        
        // Views
        SetupCustomizeView: {},
        MyViewsView: {},
        
        // Setup
        ConfigQvdView: {},
        ConfigWatView: {},
        
        // Help
        AboutView: {},
        
        // Current administrator
        Profile: {}
    },
    Router: {},
    
    // Common functions used from two or more views
    Common: {
        BySection: {
            vm: {},
            user: {},
            host: {},
            osf: {},
            di: {},
            role: {},
            administrator: {},
            tenant: {},
            log: {}
        },
        ListDetails: {},
    },
    
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
    
    // Utilities
    U: {},
    
    // Web Sockets
    WS: {
        websockets: [],
        debug: false,
        openWebsocket: function () {},
        closeAllWebsockets: function () {},
        openStatsWebsockets: function () {},
        openListWebsockets: function () {},    
        openDetailsWebsockets: function () {},
        changeWebsocket: function () {}
    },
    
    // Templates
    TPL: {},
};

//Wat.C.initApiAddress();

