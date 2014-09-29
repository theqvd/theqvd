Wat.Views.OSFListView = Wat.Views.ListView.extend({
    qvdObj: 'osf',

    initialize: function (params) {
        this.collection = new Wat.Collections.OSFs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {},
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.OSF();
        this.dialogConf.title = $.i18n.t('New OS Flavour');

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

        var name = context.find('input[name="name"]').val();        
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        
        arguments = {
            __properties__: properties.set,
            name: name,
            memory: memory || 256,
            user_storage: user_storage
        };
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            arguments["name"] = name;
        }
                        
        this.createModel(arguments);
    },
    
    updateMassiveElement: function (dialog, id) {
        var valid = Wat.Views.ListView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
        
        var arguments = {
            '__properties_changes__' : properties
        };
        
        var context = $('.' + this.cid + '.editor-container');
        
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        
        var filters = {"id": id};
        
        if (memory != '') {
            arguments["memory"] = memory;
        }
        
        if (user_storage != '') {
            arguments["user_storage"] = user_storage;
        }
        
        this.resetSelectedItems();
        
        var auxModel = new Wat.Models.OSF();
        this.updateModel(arguments, filters, this.fetchList, auxModel);
    },
});