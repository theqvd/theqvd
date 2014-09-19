// Corner menu configuration values
Wat.I.cornerMenu = {
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
                    iconClass: 'fa fa-file-text-o' 
                },
                customize: {
                    text: 'Customize',
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
                logout: {
                    text: 'Log-out',
                    link: '#/logout',
                    iconClass: 'fa fa-power-off' 
                }
            }
        }
};