Wat.Views.SetupACLsView = Wat.Views.ListView.extend({
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
});