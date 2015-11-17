Wat.Views.UserListView = Wat.Views.ListView.extend({
    qvdObj: 'user',
    liveFields: ['number_of_vms_connected', 'number_of_vms'],

    initialize: function (params) {
        this.collection = new Wat.Collections.Users(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
        
    // This events will be added to view events
    listEvents: {},
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.User();
        this.dialogConf.title = $.i18n.t('New User');
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
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('user.create.properties')) {
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
        
        var password = context.find('input[name="password"]').val();
        var password2 = context.find('input[name="password2"]').val();
        if (password && password2 && password == password2) {
            arguments['password'] = password;
        }
        
        if (Wat.C.isSuperadmin()) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            arguments['tenant_id'] = tenant_id;
        }
                        
        this.createModel(arguments, this.fetchList);
    },
    
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