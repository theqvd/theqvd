Wat.Views.UserDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'user',
    liveFields: ['number_of_vms_connected', 'number_of_vms'],

    initialize: function (params) {
        this.model = new Wat.Models.User(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    
});