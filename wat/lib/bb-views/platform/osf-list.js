Wat.Views.OSFListView = Wat.Views.ListView.extend({
    qvdObj: 'osf',
    liveFields: ['number_of_vms', 'number_of_dis'],

    initialize: function (params) {
        this.collection = new Wat.Collections.OSFs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {},
});