Wat.I.menuUserOriginal = {
    profile: {
        text: 'Profile',
        link: '#/profile',
        icon: CLASS_ICON_PERSONALAREA 
    },
    myviews: {
        text: 'Customize views',
        link: '#/myviews',
        icon: CLASS_ICON_VIEWS 
    },
    logout: {
        text: 'Log-out',
        link: '#/logout',
        icon: CLASS_ICON_LOGOUT 
    }
};

Wat.I.menuConfigOriginal = {
    config: {
        text: 'QVD Config',
        link: '#/config',
        icon: CLASS_ICON_CONFIG
    }
};

Wat.I.menuHelpOriginal = {
    about: {
        text: 'About',
        link: '#/about',
        icon: 'fa fa-asterisk' 
    },
    documentation: {
        text: 'Documentation',
        link: '#/documentation',
        icon: 'fa fa-book' 
    }
};

Wat.I.menuSetupOriginal = {
    admins: {
        text: 'Administrators',
        link: '#/admins',
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
        text: 'Default views',
        link: '#/views',
        icon: CLASS_ICON_VIEWS
    }
};

Wat.I.menuOriginal = {
    users: {
        icon: CLASS_ICON_USERS,
        text: 'Users',
        link: '#/users',
    },
    vms: {
        icon: CLASS_ICON_VMS,
        text: 'Virtual machines',
        link: '#/vms',
    },
    hosts: {
        icon: CLASS_ICON_HOSTS,
        text: 'Nodes',
        link: '#/hosts',
    },
    osfs: {
        icon: CLASS_ICON_OSFS,
        text: 'OS Flavours',
        link: '#/osfs',
    },
    dis: {
        icon: CLASS_ICON_DIS,
        text: 'Disk images',
        link: '#/dis',
    }
};

Wat.I.mobileMenuOriginal = _.extend({}, Wat.I.menuOriginal);

Wat.I.mobileMenuOriginal.logout = {
    icon: CLASS_ICON_LOGOUT,
    text: 'Logout'
}

// Corner menu configuration values
Wat.I.cornerMenuOriginal = {
        help: {
            text: 'Help',
            link: '#/about',
            icon: CLASS_ICON_HELP,
            subMenu: _.extend({}, Wat.I.menuHelpOriginal)
        },
        
        platform: {
            text: 'Platform',
            link: '#',
            icon: CLASS_ICON_PLATFORM,
            subMenu: _.extend({}, Wat.I.menuOriginal)
        },
    
        setup: {
            text: 'WAT Management',
            link: '#/setup',
            icon: CLASS_ICON_WATMANAGE,
            subMenu: _.extend({}, Wat.I.menuSetupOriginal)
        },
    
        config: {
            text: 'QVD Config',
            link: '#/config',
            icon: CLASS_ICON_CONFIG,
            subMenu: {}
        },
        
        user: {
            text: '',
            link: '#/profile',
            icon: CLASS_ICON_USER,
            textClass: 'js-login',
            subMenu: _.extend({}, Wat.I.menuUserOriginal)
        }
};