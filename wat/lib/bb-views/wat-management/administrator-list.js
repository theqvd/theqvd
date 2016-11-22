Wat.Views.AdminListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'administrators',
    qvdObj: 'administrator',
    
    initialize: function (params) {        
        this.collection = new Wat.Collections.Admins(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    openNewElementDialog: function (e) {
        var that = this;
        
        that.model = new Wat.Models.Admin();
        
        that.dialogConf.title = $.i18n.t('New Administrator');
        Wat.Views.ListView.prototype.openNewElementDialog.apply(that, [e]);
        

        Wat.I.chosenElement('[name="language"]', 'single100');
    },
    
    fillMassiveEditor: function (target, that) {
        Wat.Views.ListView.prototype.fillMassiveEditor.apply(this, [target, that]);
        that.fetchAndRenderRoles();
    },
    
    openMassiveChangesDialog: function (that) {
        Wat.Views.ListView.prototype.openMassiveChangesDialog.apply(this, [that]);
        
        Wat.I.chosenElement('[name="language"]', 'single100');
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
                
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        var password = context.find('input[name="password"]').val();

        var args = {
            "name": name,
            "password": password,
        };
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            args["description"] = description;
        }
        
        if (Wat.C.checkACL('administrator.create.language')) { 
            var language = context.find('select[name="language"]').val();
            args["language"] = language;
        }           
        
        if (Wat.C.isSuperadmin()) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            args['tenant_id'] = tenant_id;
        }
        
        if (Wat.C.checkACL('administrator.update.assign-role')) {
            if (this.assignRoles.length > 0) {
                args["__roles__"] = this.assignRoles;
            }
        }
        
        this.createModel(args, this.fetchList);
    },
    
    updateMassiveElement: function (dialog, id) {
        var valid = Wat.Views.ListView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var args = {};
        
        if (Wat.C.checkACL('administrator.update.description')) { 
            var description = $('textarea[name="description"]').val();
            args["description"] = description;
        }      
        
        if (Wat.C.checkACL('administrator.update.assign-role')) {
            if (this.assignRoles.length > 0) {
                args["__roles_changes__"] = {
                    assign_roles: this.assignRoles
                }
            }
        }
        
        this.resetSelectedItems();
        
        var filters = {id: id};
        
        var auxModel = new Wat.Models.Admin();
        
        this.updateModel(args, filters, this.fetchAny, auxModel);
    },
    
    updateMassiveElement: function (dialog, id) {
        var valid = Wat.Views.ListView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var arguments = {};
        
        var context = $('.' + this.cid + '.editor-container');
        
        var description = context.find('textarea[name="description"]').val();
        var language = context.find('select[name="language"]').val(); 
        
        var filters = {"id": id};
        
        if (Wat.I.isMassiveFieldChanging("description") && Wat.C.checkACL('administrator.update.description')) {
            arguments["description"] = description;
        }
        
        if (Wat.I.isMassiveFieldChanging("language") && Wat.C.checkACL('administrator.update.language')) {
            arguments["language"] = language;
        }
        
        this.resetSelectedItems();
        
        var auxModel = new Wat.Models.Admin();
        this.updateModel(arguments, filters, this.fetchList, auxModel);
    }
});