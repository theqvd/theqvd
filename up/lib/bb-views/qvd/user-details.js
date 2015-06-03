Wat.Views.UserDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'user',
    liveFields: ['number_of_vms_connected', 'number_of_vms'],
    
    eventsDetails: {
        'click .js-change-password': 'openChangePasswordDialog'
    },

    initialize: function (params) {
        this.model = new Wat.Models.User(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    openChangePasswordDialog: function (e) {        
        var dialogConf = {
            title: 'Change password',
            buttons : {
                "Save": function () {
                    $(this).dialog('close');
                }
            },
            button1Class : 'fa fa-save',
            fillCallback : this.fillChangePasswordDialog
        }
                
        Wat.I.dialog(dialogConf, this); 
    },
    
    fillChangePasswordDialog: function (dialog, that) {        
        // Fill the html with the template and the collection
        var template = _.template(
            Wat.TPL.changePassword, {
            });
        
        $(dialog).html(template);
    },
});