Wat.Views.HostListView = Wat.Views.ListView.extend({
    qvdObj: 'host',
    liveFields: ['state', 'number_of_vms_connected'],

    initialize: function (params) { 
        this.collection = new Wat.Collections.Hosts(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {},
    
    applyStopAll: function (that) {
        var stopAllFilters = {
            'host_id': that.applyFilters['id']
        };
        
        that.stopVM (stopAllFilters);
        that.resetSelectedItems ();
    }
});