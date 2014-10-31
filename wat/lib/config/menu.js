// Corner menu configuration values
Wat.I.cornerMenuOriginal = {
        help: {
            text: 'Help',
            link: '#/help',
            iconClass: 'fa fa-support',
            subMenu: {
                documentation: {
                    text: 'Documentation',
                    link: 'http://docs.theqvd.com/',
                    iconClass: 'fa fa-book' 
                },
                about: {
                    text: 'About',
                    link: '#/help/about',
                    iconClass: 'fa fa-asterisk' 
                }
            }
        },
        
        setup: {
            text: 'Setup',
            link: '#/setup',
            iconClass: 'fa fa-wrench',
            subMenu: {
                admins: {
                    text: 'Administrators',
                    link: '#/setup/admins',
                    iconClass: 'fa fa-suitcase' 
                },
                roles: {
                    text: 'Roles',
                    link: '#/setup/roles',
                    iconClass: 'fa fa-graduation-cap' 
                },
                tenants: {
                    text: 'Tenants',
                    link: '#/setup/tenants',
                    iconClass: 'fa fa-building' 
                },
                config: {
                    text: 'Config',
                    link: '#/setup/config',
                    iconClass: 'fa fa-sliders' 
                },
                customize: {
                    text: 'Default views',
                    link: '#/setup/customize',
                    iconClass: 'fa fa-columns' 
                }
            }
        },
        
        user: {
            text: '',
            link: 'javascript:',
            iconClass: 'fa fa-user',
            textClass: 'js-login',
            subMenu: {
                my_area: {
                    text: 'Personal area',
                    link: '#/profile',
                    iconClass: 'fa fa-archive' 
                },
                logout: {
                    text: 'Log-out',
                    link: '#/logout',
                    iconClass: 'fa fa-power-off' 
                }
            }
        }
};

Wat.I.menuOriginal = {
    users: {
        icon: CLASS_ICON_USERS,
        text: 'Users'
    },
    vms: {
        icon: CLASS_ICON_VMS,
        text: 'Virtual machines'
    },
    hosts: {
        icon: CLASS_ICON_HOSTS,
        text: 'Nodes'
    },
    osfs: {
        icon: CLASS_ICON_OSFS,
        text: 'OS Flavours'
    },
    dis: {
        icon: CLASS_ICON_DIS,
        text: 'Disk images'
    }
};

Wat.I.mobileMenuOriginal = _.extend({}, Wat.I.menuOriginal);

Wat.I.mobileMenuOriginal.logout = {
    icon: CLASS_ICON_LOGOUT,
    text: 'Logout'
}