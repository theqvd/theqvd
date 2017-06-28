Wat.Views.TenantListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'tenants',
    selectedSection: 'user',
    qvdObj: 'tenant',
    
    initialize: function (params) {
        this.collection = new Wat.Collections.Tenants(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    applyDelete: function (that) {
        var auxModel = new that.collection.model();  
        that.resetSelectedItems ();
        that.deleteModel(that.applyFilters, that.fetchList, auxModel);
    },
});