Up.I.menuUserOriginal = {
    profile: {
        text: 'Profile',
        link: '#/profile',
        icon: CLASS_ICON_PERSONALAREA 
    },
    logout: {
        text: 'Log-out',
        link: '#/logout',
        icon: CLASS_ICON_LOGOUT 
    }
};

Up.I.menuConfigOriginal = {
    config: {
        text: 'QVD Config',
        link: '#/config',
        icon: CLASS_ICON_QVDCONFIG
    }
};

Up.I.menuHelpOriginal = {
    documentation: {
        text: 'Documentation',
        link: '#/documentation',
        icon: 'fa fa-book' 
    },
    about: {
        text: 'About',
        link: '#/about',
        icon: 'fa fa-asterisk' 
    }
};

Up.I.menuSetupOriginal = {
    watconfig: {
        text: 'WAT Config',
        link: '#/watconfig',
        icon: CLASS_ICON_WATCONFIG
    },
    administrators: {
        text: 'Administrators',
        link: '#/administrators',
        icon: CLASS_ICON_ADMINS
    },
    roles: {
        text: 'Roles',
        link: '#/roles',
        icon: CLASS_ICON_ROLES
    },
    tenants: {
        text: 'Tenants',
        link: '#/tenants',
        icon: CLASS_ICON_TENANTS 
    },
    views: {
        text: 'Views',
        link: '#/views',
        icon: CLASS_ICON_VIEWS
    },
    properties: {
        text: 'Properties',
        link: '#/properties',
        icon: CLASS_ICON_PROPERTIES
    },
    logs: {
        text: 'Log',
        link: '#/logs',
        icon: CLASS_ICON_LOG
    }
};

Up.I.menuOriginal = {
    virtualdesktops: {
        icon: CLASS_ICON_VIRTUAL_DESKTOP,
        text: 'Virtual desktops',
        link: '#/desktops',
    },
    settings: {
        icon: CLASS_ICON_CONF_SETTINGS,
        text: 'Settings',
        link: '#/settings',
    },
    clients: {
        icon: CLASS_ICON_CLIENT_DOWNLOAD,
        text: 'Clients download',
        link: '#/clients',
    },
    info: {
        icon: CLASS_ICON_INFO_CONNECTION,
        text: 'Connection information',
        link: '#/info',
    },
    help: {
        icon: CLASS_ICON_HELP,
        text: 'Help',
        link: '#/help',
    },
};

Up.I.mobileMenuOriginal = _.extend({}, Up.I.menuOriginal);

// Corner menu configuration values
Up.I.cornerMenuOriginal = {/*
        help: {
            text: 'Help',
            link: '#/documentation',
            icon: CLASS_ICON_HELP,
            subMenu: _.extend({}, Up.I.menuHelpOriginal)
        },*/
        
        welcome: {
            text: '',
            textClass: 'js-login-welcome login-welcome',
            subMenu: _.extend({}, Up.I.menuUserOriginal)
        },      
    
        user: {
            text: '',
            link: '#/profile',
            icon: CLASS_ICON_USER,
            textClass: 'js-login',
            liClass: 'icon-circle',
            subMenu: _.extend({}, Up.I.menuUserOriginal)
        },
};