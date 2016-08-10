"use strict";

var Up = {
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
        // Common view with menu
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
            VMDetailsView: {},
        
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
    // Backbone router (lib/bb-router.js)
    Router: {},
    
    // Common functions used from two or more views
    Common: {
        BySection: {
            vm: {},
            user: {},
        },
        ListDetails: {},
    },
    
    // Current view store
    CurrentView: {},
    
    // Actions with ajax calls including independent API calls (lib/actions/actions.js)
    A: {},
    
    // Events binds that cant be done in backbone views (lib/binds/binds.js)
    B: {},
    
    // Configuration functions (lib/session/config.js)
    C: {
        account: {}
    }, 
    
    // Documentation utilities (lib/doc/doc.js)
    D: {},
    
    // Interface utilities (lib/interface/interface.js)
    I: {
        // Styles Customizer Tool (lib/interface/interface-customize.js)
        C: {},
        // Graphs (lib/interface/interface-graphs.js)
        G: {},
        // Live (lib/interface/interface-live.js)
        L: {},
        // Messages (lib/interface/interface-messages.js)
        M: {},
        // Templates (lib/interface/interface-templates.js)
        T: {},
    },
    
    // Login utilities (lib/session/login.js)
    L: {}, 
    
    // Translation utilities (lib/translations/translations.js)
    T: {}, 
    
    // Miscelanious utilities (lib/util/util.js)
    U: {},    

    
    // Web Sockets (lib/websockets/websockets.js)
    WS: {
        websockets: [],
        debug: false,
        openWebsocket: function () {},
        closeAllWebsockets: function () {},
        openDesktopsWebsockets: function () {},    
        changeWebsocket: function () {},
        // Web Sockets for Desktops (lib/websockets/websockets-desktops.js)
        changeWebsocketDesktops: function () {},
    },
    
    // Templates storage
    TPL: {},
    
    // CRUD functions
    CRUD: {
        workspaces: {},
        desktops: {}
    }
};

