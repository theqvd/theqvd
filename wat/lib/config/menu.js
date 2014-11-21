Wat.I.menuConfigOriginal = {
    config: {
        text: 'QVD Config',
        link: '#/config',
        icon: CLASS_ICON_CONFIG
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
            link: '#/help',
            icon: 'fa fa-support',
            subMenu: {
                documentation: {
                    text: 'Documentation',
                    link: 'http://docs.theqvd.com/',
                    icon: 'fa fa-book' 
                },
                about: {
                    text: 'About',
                    link: '#/help/about',
                    icon: 'fa fa-asterisk' 
                }
            }
        },
        
        platform: {
            text: 'Platform',
            link: '#',
            icon: 'fa fa-bug',
            subMenu: _.extend({}, Wat.I.menuOriginal)
        },
    
        setup: {
            text: 'WAT Management',
            link: '#/setup',
            icon: 'fa fa-wrench',
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
            link: 'javascript:',
            icon: 'fa fa-user',
            textClass: 'js-login',
            subMenu: {
                my_area: {
                    text: 'Personal area',
                    link: '#/profile',
                    icon: 'fa fa-archive' 
                },
                logout: {
                    text: 'Log-out',
                    link: '#/logout',
                    icon: 'fa fa-power-off' 
                }
            }
        }
};