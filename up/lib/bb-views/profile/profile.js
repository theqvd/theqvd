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
        
        this.model = new Up.Models.Profile(params);
        
        // Extend the common events
        this.extendEvents(this.eventsProfiles);
        
        //Add profile Events to view
        this.extendEvents(this.profileEvents);
        
        var templates = Up.I.T.getTemplateList('profile', {qvdObj: this.qvdObj});
        
        Up.A.getTemplates(templates, this.fetchAndRender, this); 
    },
    
    profileEvents: {
        'click .js-save-profile-btn': 'updateProfile'
    },
    
    updateProfile: function (e) {
        var params = Up.I.parseForm($('.content'));
        var model = Up.CurrentView.model;
        
        model.set(params);
                    
        Up.CurrentView.updateModel({}, params, Up.CurrentView.render, model);
    },
    
    fetchAndRender: function (that) {  
        that.model.fetch({      
            complete: function (e) {
                that.render();
            }
        });
    },
    
    render: function () {     
        this.template = _.template(
            Up.TPL.profile, {
                cid: this.cid,
                model: this.model
            }
        );

        $('.bb-content').html(this.template);
                
        Up.I.chosenElement($('select[name="language"]'), 'single100');

        Up.T.translateAndShow();
    }
});
