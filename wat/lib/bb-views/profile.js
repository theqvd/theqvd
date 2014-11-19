Wat.Views.ProfileView = Wat.Views.MainView.extend({
    setupCommonTemplateName: 'setup-common',
    setupOption: 'admins',
    secondaryContainer: '.bb-setup',
    qvdObj: 'profile',
    
    setupOption: 'profile',
    
    limitByACLs: true,
    
    setAction: 'admin_view_set',
    
    viewKind: 'admin',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Personal area',
            'link': '#/profile',
            'next': {
                'screen': 'Profile'
            }
        }
    },
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        // Get side menu
        this.sideMenu = {
            'profile': {
                icon: 'fa fa-user',
                link: '#profile',
                text: 'Profile'
            },
            'views': {
                icon: 'fa fa-columns',
                link: '#myviews',
                text: 'Customize views'
            }
        };
        
        this.render();
    },
    
    render: function () {
        this.templateProfile = Wat.A.getTemplate(this.setupCommonTemplateName);
        
        this.template = _.template(
            this.templateProfile, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: this.sideMenu
            }
        );

        $('.bb-content').html(this.template);
        
        this.templateProfile = Wat.A.getTemplate('profile');
        
        this.template = _.template(
            this.templateProfile, {
                login: Wat.C.login
            }
        );

        $('.bb-setup').html(this.template);
        Wat.T.translate();
        
        this.printBreadcrumbs(this.breadcrumbs, '');
    }
});