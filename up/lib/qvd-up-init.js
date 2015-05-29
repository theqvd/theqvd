"use strict";

var Wat = {
    // Backbone components: Models, Collections, Views and Router
    Models: {
        // Common model with connection method
        Model: {},
        
        // Models
        User: {},
        VM: {},
    },
    Collections: {
        // Common collection with connection method
        Collection: {},
        
        // Collections
        VMs: {},
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
            VMListView: {},
        
        // Details views
        DetailsView: {},
            UserDetailsView: {},
            VMDetailsView: {},
    },
    Router: {},
    
    // Common functions used from two or more views
    Common: {
        BySection: {
            vm: {},
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

