// Corner menu configuration values
Wat.I.cornerMenu = {
        help: {
            text: 'Help',
            link: '#/help',
            iconClass: 'fa fa-support',
            subMenu: {
                documentation: {
                    text: 'Documentation',
                    link: '#/help/documentation',
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
                    text: 'Admins',
                    link: '#/setup/admins',
                    iconClass: 'fa fa-suitcase' 
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
            link: '#/user',
            iconClass: 'fa fa-user',
            subMenu: {
                logout: {
                    text: 'Log-out',
                    link: '#/user/logout',
                    iconClass: 'fa fa-power-off' 
                }
            }
        }
};