Wat.Views.LogListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'log',
    qvdObj: 'log',

    
    initialize: function (params) {
        
        params.sort = {
            "field": "id",
            "order": "-desc"
        }
        
        this.collection = new Wat.Collections.Logs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    events: {
    },
});