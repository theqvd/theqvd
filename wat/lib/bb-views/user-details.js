Wat.Views.UserDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'user',

    initialize: function (params) {
        this.model = new Wat.Models.User(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        if (this.checkSide({'user.see.vm-list': '.js-side-component1'}) === false) {
            return;
        }
        
        var sideContainer = '.' + this.cid + ' .bb-details-side1';
        
        // Render Virtual Machines list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer;
        params.forceListColumns = {info: true, name: true};
        params.forceSelectedActions = {};
        params.block = 5;
        params.filters = {"user_id": this.elementId};

        this.sideView = new Wat.Views.VMListView(params);
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
    }
});