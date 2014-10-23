Wat.Views.ACLListView = Wat.Views.ListView.extend({
    setupCommonTemplateName: 'setup-common',
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    qvdObj: 'acl',
    
    initialize: function (params) {
        params.whatRender = 'list';
        
        this.collection = new Wat.Collections.ACLs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    events: {
    },
    
    applyDeleteACL: function (that) {
        var auxModel = new that.collection.model();
        
        var context = $('.' + that.cid);

        var arguments = {
            __acls_changes__: {
                unassign_acls: that.selectedItems
            }
        };

        that.updateModel(arguments, {id: Wat.CurrentView.id}, Wat.CurrentView.fetchDetails, Wat.CurrentView.model);
    }
});