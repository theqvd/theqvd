Wat.Views.TenantDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'tenant',
    
    cascadeTenantElements: {
            'vm': {
                elementName: 'Virtual machines',
                nameField: 'name',
                templateSelector: '.bb-tenant-delete-vms',
                nextObj: 'user'
             },
            'user': {
                elementName: 'Users',
                nameField: 'name',
                templateSelector: '.bb-tenant-delete-users',
                nextObj: 'di'
             },
            'di': {
                elementName: 'Disk images',
                nameField: 'disk_image',
                templateSelector: '.bb-tenant-delete-dis',
                nextObj: 'osf'
             },
            'osf': {
                elementName: 'OS Flavours',
                nameField: 'name',
                templateSelector: '.bb-tenant-delete-osfs',
                nextObj: 'role'
             },
            'role': {
                elementName: 'Roles',
                nameField: 'name',
                templateSelector: '.bb-tenant-delete-roles',
                nextObj: 'administrator'
             },
            'administrator': {
                elementName: 'Administrators',
                nameField: 'name',
                templateSelector: '.bb-tenant-delete-administrators'
             }
    },

    initialize: function (params) {
        this.model = new Wat.Models.Tenant(params);
        
        this.setBreadCrumbs();
       
        // Clean previous item name
        this.breadcrumbs.next.next.next.screen="";
        
        var templates = Wat.I.T.getTemplateList('tenantDetails');
        
        Wat.A.getTemplates(templates, function () {}); 
        
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        var sideCheck = this.checkSide({'tenant.see.vm-list': '.js-side-component1', 'tenant.see.user-list': '.js-side-component2', 'tenant.see.di-list': '.js-side-component3', 'tenant.see.log': '.js-side-component4'});
        
        if (sideCheck === false) {
            return;
        }
        
        if (sideCheck['tenant.see.vm-list']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side1';

            // Render Virtual Machines list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer;
            params.forceListColumns = {name: true};
            
            if (Wat.C.checkGroupACL('tenantVmEmbeddedInfo')) {
                params.forceListColumns['info'] = true;
            }
            
            // Check ACLs to show or not info icons in Users list
            params.forceInfoRestrictions = {};
            if (Wat.C.checkACL('tenant.see.vm-list-block')) {
                params.forceInfoRestrictions.block = true;
            }
            if (Wat.C.checkACL('tenant.see.vm-list-expiration')) {
                params.forceInfoRestrictions.expiration = true;
            }
            if (Wat.C.checkACL('tenant.see.vm-list-state')) {
                params.forceInfoRestrictions.state = true;
            }
            if (Wat.C.checkACL('tenant.see.vm-list-user-state')) {
                params.forceInfoRestrictions.user_state = true;
            }
            
            params.forceListActionButton = null;

            params.forceSelectedActions = {};
            params.block = 5;
            params.filters = {"tenant_id": this.elementId};

            this.sideViews.push(new Wat.Views.VMListView(params));
        }    
        
        if (sideCheck['tenant.see.user-list']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side2';

            // Render Virtual Machines list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer;
            params.forceListColumns = {name: true};
            
            if (Wat.C.checkGroupACL('tenantUserEmbeddedInfo')) {
                params.forceListColumns['info'] = true;
            }

            // Check ACLs to show or not info icons in Users list
            params.forceInfoRestrictions = {};
            if (Wat.C.checkACL('tenant.see.user-list-block')) {
                params.forceInfoRestrictions.block = true;
            }
            
            params.forceListActionButton = null;

            params.forceSelectedActions = {};
            params.block = 5;
            params.filters = {"tenant_id": this.elementId};

            this.sideViews.push(new Wat.Views.UserListView(params));
        }
        
        if (sideCheck['tenant.see.di-list']) { 
            var sideContainer2 = '.' + this.cid + ' .bb-details-side3';

            // Render Disk images list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer2;
            params.forceListColumns = {disk_image: true};
            
            if (Wat.C.checkGroupACL('tenantDiEmbeddedInfo')) {
                params.forceListColumns['info'] = true;
            }

            if (Wat.C.checkACL('tenant.see.di-list-default-update')) {
                params.forceListColumns.default = true;
            }

            // Check ACLs to show or not info icons in DIs list
            params.forceInfoRestrictions = {};
            if (Wat.C.checkACL('tenant.see.di-list-default')) {
                params.forceInfoRestrictions.default = true;
            }
            if (Wat.C.checkACL('tenant.see.di-list-head')) {
                params.forceInfoRestrictions.head = true;
            }
            if (Wat.C.checkACL('tenant.see.di-list-tags')) {
                params.forceInfoRestrictions.tags = true;
            }
            if (Wat.C.checkACL('tenant.see.di-list-block')) {
                params.forceInfoRestrictions.block = true;
            }
            
            params.forceListActionButton = null;
            
            params.forceSelectedActions = {};
            params.block = 5;
            params.filters = {"tenant_id": this.elementId};
            this.sideViews.push(new Wat.Views.DIListView(params));  
        }
        
        if (sideCheck['tenant.see.log']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side4';

            // Render Related log list on side
            var params = this.getSideLogParams(sideContainer);

            this.sideViews.push(new Wat.Views.LogListView(params));

            this.renderLogGraph(params);
        }
    },
    
    applyDelete: function (that) {
        //that.deleteModel({id: that.elementId}, that.afterDelete, that.model);
        var that = this;
        
        var dialogConf = {
            title: 'Deleting tenant',
            buttons : {
                "Cancel": function () {                    
                    Wat.I.closeDialog($(this));
                },
                "Delete all": function () {
                    var that = Wat.CurrentView;
                    
                    that.dialog = $(this);
                                    
                    // Hide delete all button until all data were retrieved
                    $('.ui-dialog-buttonset').hide();
                    that.applyCascadeDelete();
                }
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-trash',
            
            fillCallback : function (target) {
                // Hide delete all button until all data were retrieved
                $('.ui-dialog-buttonset .button').eq(1).hide();
                
                // Add common parts of editor to dialog
                var template = _.template(
                    Wat.TPL.deleteTenantDialog, {
                    }
                );

                target.html(template);
                
                Wat.CurrentView.getTenantElements();
            }
        }

        Wat.I.dialog(dialogConf);        
    },
                            
    getTenantElements: function (qvdObj) {
        var qvdObj = qvdObj || 'vm';
        var that = this;
        
        Wat.A.performAction(qvdObj + '_tiny_list', {}, {
            tenant_id: that.elementId
            }, {}, function (that) {
                var template = _.template(
                    Wat.TPL.deleteTenantDialogElements, {
                        elementQvdObj: qvdObj,
                        elementName: that.cascadeTenantElements[qvdObj]['elementName'],
                        registers: that.retrievedData.rows,
                        nameField: that.cascadeTenantElements[qvdObj]['nameField'] || 'name'
                    }
                );
                
                $(that.cascadeTenantElements[qvdObj]['templateSelector']).html(template);
                
                if (that.cascadeTenantElements[qvdObj]['nextObj']) {
                    that.getTenantElements(that.cascadeTenantElements[qvdObj]['nextObj']);
                }
                else {
                    // After finish counting, show delete all button
                    $('.ui-dialog-buttonset .button').eq(1).show(); 
                }
            }, that);
    },
    
    applyCascadeDelete: function (qvdObj) {
        var qvdObj = qvdObj || 'vm';
        var that = this;
        
        var nElements = parseInt($('[data-qvd-obj="' + qvdObj + '"].js-counter').html());
        
        if (!nElements) {
            if (that.cascadeTenantElements[qvdObj]['nextObj']) {
                that.applyCascadeDelete(that.cascadeTenantElements[qvdObj]['nextObj']);
            }
            else {
                that.deleteModel({id: that.elementId}, that.afterDelete, that.model);
            }
            return;
        }
        
        var elements = $('ul[data-qvd-obj="' + qvdObj + '"] li');
        var elementIds = [];
        $.each(elements, function (iElement, element) {
            elementIds.push($(element).attr('data-id'));
        });

        Wat.A.performAction(qvdObj + '_delete', {}, {
            id: elementIds
            }, {}, function (res) {
                // TODO: Check (res.retrievedData == STATUS_SUCCESS)
                var that = Wat.CurrentView;
            
                $('[data-qvd-obj="' + qvdObj + '"].js-counter').html('0')
                $('ul[data-qvd-obj="' + qvdObj + '"] li').remove();
            
                if (that.cascadeTenantElements[qvdObj]['nextObj']) {
                    that.applyCascadeDelete(that.cascadeTenantElements[qvdObj]['nextObj']);
                }
                else {
                    Wat.I.closeDialog(that.dialog);
                    that.deleteModel({id: that.elementId}, that.afterDelete, that.model);
                }
            }, that);
    }
});