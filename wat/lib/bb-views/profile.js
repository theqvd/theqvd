Wat.Views.ProfileView = Wat.Views.DetailsView.extend({  
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
        
        params.id = Wat.C.adminID;
        this.id = Wat.C.adminID;
        
        this.model = new Wat.Models.Admin(params);
        
        this.editorTemplateName = 'editor-profile',
            
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
        
        // Extend the common events
        this.extendEvents(this.eventsDetails);
    },
    
    openEditElementDialog: function(e) {        
        this.dialogConf.title = $.i18n.t('Edit Profile');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
    },
    
    updateElement: function (dialog) {
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var filters = {"id": this.id};
        var arguments = {};
        
        var context = $('.' + this.cid + '.editor-container');

        if (Wat.C.checkACL('administrator.update.password')) {
            // If change password is checked
            if (context.find('input.js-change-password').is(':checked')) {
                var password = context.find('input[name="password"]').val();
                var password2 = context.find('input[name="password2"]').val();
                if (password && password2 && password == password2) {
                    arguments['password'] = password;
                }
            }
        }
        
        this.updateModel(arguments, filters, this.fetchDetails);
    },
});