Wat.Views.ProfileView = Wat.Views.DetailsView.extend({
    setupOption: 'administrators',
    secondaryContainer: '.bb-setup',
    qvdObj: 'profile',
    editorViewClass: Wat.Views.ProfileEditorView,
    
    setupOption: 'profile',
    
    limitByACLs: true,
    
    setActionAttribute: 'admin_attribute_view_set',
    setActionProperty: 'admin_property_view_set',
    
    viewKind: 'admin',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Profile'
        }
    },
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        params.id = Wat.C.adminID;
        this.id = Wat.C.adminID;
        
        this.model = new Wat.Models.Admin(params);
        
        // The profile action to update current admin data is 'myadmin_update'
        this.model.setActionPrefix('myadmin');
        
        // Extend the common events
        this.extendEvents(this.eventsDetails);
        
        var templates = Wat.I.T.getTemplateList('profile', {qvdObj: this.qvdObj});
        
        Wat.A.getTemplates(templates, this.render, this); 
    },
    
    render: function () {
        this.template = _.template(
            Wat.TPL.profile, {
                cid: this.cid,
                login: Wat.C.login,
                language: Wat.C.language,
                block: Wat.C.block,
                tenantLanguage: Wat.C.tenantLanguage,
                tenantBlock: Wat.C.tenantBlock,
                tenantName: Wat.C.tenantName
            }
        );

        $('.bb-content').html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        Wat.T.translateAndShow();
    },
    
    openEditElementDialog: function(e) {     
        this.dialogConf.title = $.i18n.t('Edit profile');
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);

        Wat.I.chosenConfiguration();
        Wat.I.chosenElement('select[name="language"]', 'single100');
        Wat.I.chosenElement('select[name="block"]', 'single100');
    }
});
