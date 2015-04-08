Wat.Views.UserDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'user',
    liveFields: ['number_of_vms_connected', 'number_of_vms'],

    initialize: function (params) {
        this.model = new Wat.Models.User(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        var sideCheck = this.checkSide({'user.see.vm-list': '.js-side-component1', 'user.see.log': '.js-side-component2'});

        if (sideCheck === false) {
            return;
        }
        
        if (sideCheck['user.see.vm-list']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side1';

            // Render Virtual Machines list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer;
            params.forceListColumns = {name: true};

            if (Wat.C.checkGroupACL('userVmEmbeddedInfo')) {
                params.forceListColumns['info'] = true;
            }

            // Check ACLs to show or not info icons in Users list
            params.forceInfoRestrictions = {};
            if (Wat.C.checkACL('user.see.vm-list-block')) {
                params.forceInfoRestrictions.block = true;
            }
            if (Wat.C.checkACL('user.see.vm-list-expiration')) {
                params.forceInfoRestrictions.expiration = true;
            }
            if (Wat.C.checkACL('user.see.vm-list-state')) {
                params.forceInfoRestrictions.state = true;
            }
            if (Wat.C.checkACL('user.see.vm-list-user-state')) {
                params.forceInfoRestrictions.user_state = true;
            }

            params.forceSelectedActions = {};
            params.block = 5;
            params.filters = {"user_id": this.elementId};

            this.sideView = new Wat.Views.VMListView(params);
        }
        
        if (sideCheck['log.see-main.']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side2';

            // Render Related log list on side
            var params = this.getSideLogParams(sideContainer);

            this.sideView = new Wat.Views.LogListView(params);
        }
    },
    
    updateElement: function (dialog) {        
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
        
        var arguments = {'properties' : properties};
        
        var context = $('.' + this.cid + '.editor-container');
                        
        var filters = {"id": this.id};
        var arguments = {};
        
        if (properties.delete.length > 0 || !$.isEmptyObject(properties.set)) {
            arguments["__properties_changes__"] = properties;
        }
        
        if (Wat.C.checkACL('user.update.password')) {
            // If change password is checked
            if (context.find('input.js-change-password').is(':checked')) {
                var password = context.find('input[name="password"]').val();
                var password2 = context.find('input[name="password2"]').val();
                if (password && password2 && password == password2) {
                    arguments['password'] = password;
                }
            }
        }
        
        this.updateModel(arguments, filters, this.fetchDetails);
    },
    
    openEditElementDialog: function(e) {
        this.dialogConf.title = $.i18n.t('Edit user') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
    },
    
    applyDisconnectAll: function () {
        var disconnectAllFilters = {
            'user_id': [this.id]
        };
        
        var messages = {
            'success': 'User successfully disconnected from all VMs',
            'error': 'Error disconnecting user from all VMs'
        };
        
        this.disconnectVMUser (disconnectAllFilters, messages);
    }
});