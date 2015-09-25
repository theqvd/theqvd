"use strict";

var Wat = {
    // Backbone components: Models, Collections, Views and Router
    Models: {
        // Common model with connection method
        Model: {},
        
        // Models
        User: {},
        VM: {},
        Host: {},
        OSF: {},
        DI: {},
        Admin: {},
        Log: {},
        Property: {},
        Role: {},
        Tenant: {},
    },
    Collections: {
        // Common collection with connection method
        Collection: {},
        
        // Collections
        Users: {},
        VMs: {},
        Hosts: {},
        OSFs: {},
        DIs: {},
        Admins: {},
        Logs: {},
        Properties: {},
        Roles: {},
        Tenants: {},
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
    // Backbone router (lib/bb-router.js)
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
    
    // Actions (lib/actions.js)
    A: {},
    
    // Translation utilities (lib/translations.js)
    T: {}, 
    
    // Interface utilities (lib/interface.js)
    I: {
        // Styles Customizer Tool (lib/interface-customize.js)
        C: {},
        // Graphs (lib/interface-graphs.js)
        G: {},
        // Templates (lib/interface-templates.js)
        T: {},
        // Messages (lib/interface-messages.js)
        M: {},
    },
    
    // Configuration (lib/config.js)
    C: {}, 
    
    // Login utilities (lib/login.js)
    L: {}, 
    
    // Events binds that cant be done in backbone views (lib/binds.js)
    B: {},
    
    // Utilities (lib/utilities.js)
    U: {},
    
    // Web Sockets (lib/websockets/websockets.js)
    WS: {
        websockets: [],
        debug: false,
        openWebsocket: function () {},
        closeAllWebsockets: function () {},
        openStatsWebsockets: function () {},
        openListWebsockets: function () {},    
        openDetailsWebsockets: function () {},
        changeWebsocket: function () {},
        // Web Sockets for Hosts (lib/websockets/websockets.host.js)
        changeWebsocketHost: function () {},
        // Web Sockets for OSFs (lib/websockets/websockets.osf.js)
        changeWebsocketOsf: function () {},
        // Web Sockets for Home page s  tats (lib/websockets/websockets.stats.js)
        changeWebsocketStats: function () {},
        // Web Sockets for Users (lib/websockets/websockets.user.js)
        changeWebsocketUser: function () {},
        // Web Sockets for VMs (lib/websockets/websockets.vm.js)
        changeWebsocketVm: function () {},
    },
    
    // Templates storage
    TPL: {},
};

