Up.Views.ProfileView = Up.Views.DetailsView.extend({  
    setupOption: 'administrators',
    secondaryContainer: '.bb-setup',
    qvdObj: 'profile',
    
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
        Up.Views.MainView.prototype.initialize.apply(this, [params]);
        
        params.id = Up.C.adminID;
        this.id = Up.C.adminID;
        
        this.model = new Up.Models.Admin(params);
        
        // The profile action to update current admin data is 'myadmin_update'
        this.model.setActionPrefix('myadmin');
        
        // Extend the common events
        this.extendEvents(this.eventsDetails);
        
        var templates = Up.I.T.getTemplateList('profile', {qvdObj: this.qvdObj});
        
        Up.A.getTemplates(templates, this.render, this); 
    },
    
    render: function () {        
        this.template = _.template(
            Up.TPL.profile, {
                cid: this.cid,
                login: Up.C.login,
                language: Up.C.language,
                block: Up.C.block,
                tenantLanguage: Up.C.tenantLanguage,
                tenantBlock: Up.C.tenantBlock,
                tenantName: Up.C.tenantName
            }
        );

        $('.bb-content').html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        Up.T.translateAndShow();
    },
    
    openEditElementDialog: function(e) {     
        this.dialogConf.title = $.i18n.t('Edit profile');
        Up.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);

        Up.I.chosenConfiguration();
        Up.I.chosenElement('select[name="language"]', 'single100');
        Up.I.chosenElement('select[name="block"]', 'single100');
    },
    
    updateElement: function (dialog) {
        var valid = Up.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var filters = {};
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
            if (Up.C.language != that.newLanguage) {
                Up.C.language = that.newLanguage;
            }
            if (Up.C.block != that.newBlock) {
                Up.C.block = that.newBlock;
            }
            that.render();
            Up.T.initTranslate();
        }
    }
});
