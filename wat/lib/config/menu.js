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
        icon: CLASS_ICON_QVDCONFIG
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
    watconfig: {
        text: 'WAT Config',
        link: '#/watconfig',
        icon: CLASS_ICON_WATCONFIG
    },
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
    },
    log: {
        text: 'Log',
        link: '#/log',
        icon: CLASS_ICON_LOG
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
    text: 'Log-out'
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
    
        wat: {
            text: 'WAT Management',
            link: '#',
            icon: CLASS_ICON_WATMANAGE,
            subMenu: _.extend({}, Wat.I.menuSetupOriginal)
        },
    
        config: {
            text: 'QVD Management',
            link: '#/config',
            icon: CLASS_ICON_QVDMANAGE,
            subMenu: _.extend({}, Wat.I.menuConfigOriginal)
        },
        
        user: {
            text: '',
            link: '#/profile',
            icon: CLASS_ICON_USER,
            textClass: 'js-login',
            subMenu: _.extend({}, Wat.I.menuUserOriginal)
        }
};