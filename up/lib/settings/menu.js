Up.I.menuOriginal = {
    desktops: {
        icon: CLASS_ICON_VIRTUAL_DESKTOP,
        text: 'Virtual desktops',
        link: '#/desktops',
    },
    settings: {
        icon: CLASS_ICON_CONF_SETTINGS,
        text: 'Settings',
        link: '#/settings',
    },
    downloads: {
        icon: CLASS_ICON_CLIENT_DOWNLOAD,
        text: 'Clients download',
        link: '#/downloads',
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

Up.I.cornerMenuOriginal = {
        welcome: {
            text: '',
            textClass: 'js-login-welcome login-welcome',
            liClass: 'desktop',
            subMenu: _.extend({}, Up.I.menuUserOriginal)
        },      
    
        profile: {
            text: '',
            link: '#/profile',
            icon: CLASS_ICON_USER,
            textClass: 'js-login',
            liClass: 'icon-circle',
            subMenu: _.extend({}, Up.I.menuUserOriginal)
        },
};