Wat.Views.RoleListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'roles',
    qvdObj: 'role',
    
    initialize: function (params) {        
        if (params.filters == undefined) {
            params.filters = {};
        }
        
        params.filters.internal = false;
        
        this.collection = new Wat.Collections.Roles(params);

        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // Enlarge render list function to load dinamically column of number of ACLs of each role
    renderList: function () {
        Wat.Views.ListView.prototype.renderList.apply(this, []);

        var that = this;
        
        $.each($('.js-role-acls'), function (iCell, cell) {
            var roleID = $(cell).attr('data-id');
            Wat.A.performAction('number_of_acls_in_role', {}, {"role_id": roleID, "acl_pattern": ["%"]}, {}, function (that) {
                var numberOfAcls = that.retrievedData['%']['effective'];
                $(cell).html(numberOfAcls);
            }, that);
        });
    },

    openNewElementDialog: function (e) {
        var that = this;
        
        that.model = new Wat.Models.Role();
        
        that.dialogConf.title = $.i18n.t('New Role');
        Wat.Views.ListView.prototype.openNewElementDialog.apply(that, [e]);
        
        if ($('[name="tenant_id"]').length > 0) {
            // When tenant id is present attach change events. Roles will be filled once the events were triggered
            Wat.B.bindEvent('change', 'select[name="tenant_id"]', function () {
                that.fetchAndRenderRoles({
                    forcedTenantId: $('select[name="tenant_id"]').val()
                });
            });
        }
        else {
            that.fetchAndRenderRoles({
                forcedTenantId: Wat.C.tenantID
            });
        }
    },
    
    fillMassiveEditor: function (target, that) {
        Wat.Views.ListView.prototype.fillMassiveEditor.apply(this, [target, that]);
        that.fetchAndRenderRoles();
        that.fetchAndRenderTemplates();
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
                
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        
        var args = {
            "name": name
        };
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            args["description"] = description;
        }
        
        if (Wat.C.isSuperadmin()) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            args['tenant_id'] = tenant_id;
        }
        
        if (Wat.C.checkACL('role.update.assign-role')) {
            var assignTotal = [];
            
            if (this.assignRoles.length > 0) {
                assignTotal = assignTotal.concat(this.assignRoles);
            }     
            
            if (this.assignTemplates.length > 0) {
                assignTotal = assignTotal.concat(this.assignTemplates);
            }
            
            if (assignTotal.length > 0) {
                args["__roles__"] = assignTotal;
            }
        }
        
        // Go to first page and order by ID desc to got the last created element in first place
        this.collection.sort = {"field": "id", "order": "-desc"};
        $('div.pagination>.first').trigger('click');
                                
        this.createModel(args, this.fetchList);
    },
    
    updateMassiveElement: function (dialog, id) {
        var valid = Wat.Views.ListView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var args = {};
        
        if (Wat.C.checkACL('role.update.description')) { 
            var description = $('textarea[name="description"]').val();
            args["description"] = description;
        }      
        
        if (Wat.C.checkACL('role.update.assign-role')) {
            var assignTotal = [];

            if (this.assignRoles.length > 0) {
                assignTotal = assignTotal.concat(this.assignRoles);
            }
            
            if (this.assignTemplates.length > 0) {
                assignTotal = assignTotal.concat(this.assignTemplates);
            }

            if (assignTotal > 0) {
                args["__roles_changes__"] = {
                    assign_roles: assignTotal
                }
            }
        }
        
        this.resetSelectedItems();
        
        var filters = {id: id};
        
        var auxModel = new Wat.Models.Role();
        
        this.updateModel(args, filters, this.fetchAny, auxModel);
    },
});