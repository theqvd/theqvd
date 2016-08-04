Up.Views.ProfileView = Up.Views.MainView.extend({  
    setupOption: 'administrators',
    secondaryContainer: '.bb-setup',
    qvdObj: 'profile',
    
    setupOption: 'profile',
    
    limitByACLs: true,
    
    setActionAttribute: 'admin_attribute_view_set',
    setActionProperty: 'admin_property_view_set',
    
    viewKind: 'admin',
    
    initialize: function (params) {
        Up.Views.MainView.prototype.initialize.apply(this, [params]);
                
        Up.I.chosenConfiguration();
        
        params.id = Up.C.adminID;
        this.id = Up.C.adminID;
        
        this.model = new Up.Models.User(params);
        
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
                language: Up.C.language
            }
        );

        $('.bb-content').html(this.template);
                
        Up.I.chosenElement($('select[name="language"]'), 'single100');

        Up.T.translateAndShow();
    }
});
