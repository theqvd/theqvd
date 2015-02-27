Wat.Views.ProfileView = Wat.Views.DetailsView.extend({  
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
            'screen': 'Profile'
        }
    },
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        params.id = Wat.C.adminID;
        this.id = Wat.C.adminID;
        
        this.model = new Wat.Models.Admin(params);
        
        // Extend the common events
        this.extendEvents(this.eventsDetails);
        
        var templates = {
            editor: {
                name: 'editor-' + this.qvdObj
            }
        }
        
        Wat.A.getTemplates(templates, this.render, this); 
    },
    
    render: function () {        
        this.template = _.template(
            Wat.TPL.setupCommon, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: this.sideMenu
            }
        );

        $('.bb-content').html(this.template);
                
        this.template = _.template(
            Wat.TPL.profile, {
                login: Wat.C.login,
                language: Wat.C.language,
                block: Wat.C.block,
                tenantLanguage: Wat.C.tenantLanguage,
                tenantBlock: Wat.C.tenantBlock
            }
        );

        $('.bb-setup').html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        this.renderRelatedDocs();

        Wat.T.translate();

        // Extend the common events
        this.extendEvents(this.eventsDetails);
    },
    
    openEditElementDialog: function(e) {        
        this.dialogConf.title = $.i18n.t('Edit Profile');
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);

        Wat.I.chosenConfiguration();
        Wat.I.chosenElement('select[name="language"]', 'single100');
        Wat.I.chosenElement('select[name="block"]', 'single100');
    },
    
    updateElement: function (dialog) {
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var filters = {"id": this.id};
        var arguments = {};
        
        var context = $('.' + this.cid + '.editor-container');

        // If change password is checked
        if (context.find('input.js-change-password').is(':checked')) {
            var password = context.find('input[name="password"]').val();
            var password2 = context.find('input[name="password2"]').val();
            if (password && password2 && password == password2) {
                arguments['password'] = password;
            }
        }
        
        // Set language
        var language = context.find('select[name="language"]').val();
        arguments['language'] = language;  
        
        // Set block size
        var block = context.find('select[name="block"]').val();
        arguments['block'] = block;
        
        // Store new language to make things after update
        this.newLanguage = language;
        this.newBlock = block;
        
        this.updateModel(arguments, filters, this.afterUpdateElement);
    },
    
    afterUpdateElement: function (that) {
        // If change is made succesfully check new language to ender again and translate
        if (that.retrievedData.status == STATUS_SUCCESS) {
            if (Wat.C.language != that.newLanguage) {
                Wat.C.language = that.newLanguage;
            }
            if (Wat.C.block != that.newBlock) {
                Wat.C.block = that.newBlock;
            }
            that.render();
            Wat.T.initTranslate();
        }
    }
});