Wat.Views.HostListView = Wat.Views.ListView.extend({
    qvdObj: 'host',
    
    initialize: function (params) { 
        this.collection = new Wat.Collections.Hosts(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {},
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.Host();
        this.dialogConf.title = $.i18n.t('New host');
        
        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');

        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        
        var arguments = {
            "blocked": blocked ? 1 : 0
        };
        
        if (!$.isEmptyObject(properties.set)) {
            arguments["__properties__"] = properties.set;
        }
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            arguments["name"] = name;
        }     
        
        var address = context.find('input[name="address"]').val();
        if (name) {
            arguments["address"] = address;
        }
                        
        this.createModel(arguments, this.fetchList);
    },
    
    renderList: function () {
        Wat.Views.ListView.prototype.renderList.apply(this);
            
        var fields = ['state', 'number_of_vms_connected'];

        Wat.WS.openListWebsockets(this.qvdObj, this.collection.models, fields);
    }
});