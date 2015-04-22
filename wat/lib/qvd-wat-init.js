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
        SetupCustomizeView: {},
        ConfigQvdView: {},
        TenantListView: {},
        AdminListView: {},
        RoleListView: {},
        
        // Help
        AboutView: {},
        
        // Current administrator
        Profile: {}
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

