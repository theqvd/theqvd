Wat.Views.UserListView = Wat.Views.ListView.extend({
    qvdObj: 'user',
    liveFields: ['number_of_vms_connected', 'number_of_vms'],

    initialize: function (params) {
        this.collection = new Wat.Collections.Users(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
        
    // This events will be added to view events
    listEvents: {},
    
    applyDisconnectAll: function (that) {
        var disconnectAllFilters = {
            'user_id': that.applyFilters['id']
        };
        
        var messages = {
            'success': 'User successfully disconnected from all VMs',
            'error': 'Error disconnecting user from all VMs'
        };
        
        that.disconnectVMUser (disconnectAllFilters, messages);
        that.resetSelectedItems ();
    }
});