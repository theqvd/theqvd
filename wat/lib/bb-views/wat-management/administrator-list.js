Wat.Views.AdminListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'administrators',
    qvdObj: 'administrator',
    
    initialize: function (params) {
        this.collection = new Wat.Collections.Admins(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
});