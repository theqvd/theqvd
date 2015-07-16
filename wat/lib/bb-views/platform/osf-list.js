Wat.Views.OSFListView = Wat.Views.ListView.extend({
    qvdObj: 'osf',
    liveFields: ['number_of_vms', 'number_of_dis'],

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
            name: name,
            memory: DEFAULT_OSF_MEMORY
        };
        
        if (memory && Wat.C.checkACL('osf.create.memory')) {
            arguments['memory'] = memory;
        }  
        
        if (Wat.C.checkACL('osf.create.user-storage')) {
            arguments['user_storage'] = user_storage;
        }
        
        if (!$.isEmptyObject(properties.set)) {
            arguments["__properties__"] = properties.set;
        }
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            arguments["name"] = name;
        }
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            arguments["description"] = description;
        }
                 
        if (Wat.C.isSuperadmin) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            arguments['tenant_id'] = tenant_id;
        }
        
        this.createModel(arguments, this.fetchList);
    },
    
    updateMassiveElement: function (dialog, id) {
        var valid = Wat.Views.ListView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
        
        var arguments = {};
        
        if (properties.delete.length > 0 || !$.isEmptyObject(properties.set)) {
            arguments["__properties_changes__"] = properties;
        }
        
        var context = $('.' + this.cid + '.editor-container');
        
        var description = context.find('textarea[name="description"]').val();
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        
        var filters = {"id": id};
        
        
        if (description != '' && Wat.C.checkACL(this.qvdObj + '.update-massive.description')) {
            arguments["description"] = description;
        }
        
        if (memory != '' && Wat.C.checkACL('osf.update-massive.memory')) {
            arguments["memory"] = memory;
        }
        
        if (user_storage != '' && Wat.C.checkACL('osf.update-massive.user-storage')) {
            arguments["user_storage"] = user_storage;
        }
        
        this.resetSelectedItems();
        
        var auxModel = new Wat.Models.OSF();
        this.updateModel(arguments, filters, this.fetchList, auxModel);
    }
});