Wat.Views.LogDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'log',

    initialize: function (params) {
        this.model = new Wat.Models.Log(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        if (this.checkSide({'log.see-details.': '.js-side-component1'}) === false) {
            return;
        }
        var sideContainer = '.' + this.cid + ' .bb-details-side1';

        // Render Virtual Machines list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer;
        params.forceListColumns = {
            see_details: true, 
            action: true, 
            datetime: true
        };
        
        params.forceSelectedActions = {};
        params.block = 5;
        params.filters = {
            qvd_object: this.model.get('qvd_object'), 
            object_id: this.model.get('object_id')
        };

        this.sideView = new Wat.Views.LogListView(params);
    },
});