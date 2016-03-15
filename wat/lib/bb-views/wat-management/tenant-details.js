Wat.Views.TenantDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'tenant',
    
    // vm_tiny_list
    // user_tiny_list
    // di_tiny_list
    // osf_tiny_list
    // role_tiny_list
    // administrator_tiny_list
    // property_get_list
    // config_get
    
    // vm_delete
    // user_delete
    // di_delete
    // osf_delete
    // role_delete
    // administrator_delete
    // property_delete
    // config_delete
    
    cascadeTenantElements: {
            'vm': {
                elementName: 'Virtual machines',
                nextObj: 'user'
             },
            'user': {
                elementName: 'Users',
                nextObj: 'di'
             },
            'di': {
                elementName: 'Disk images',
                nameField: 'disk_image',
                nextObj: 'osf'
             },
            'osf': {
                elementName: 'OS Flavours',
                nextObj: 'role'
             },
            'role': {
                elementName: 'Roles',
                nextObj: 'administrator'
             },
            'administrator': {
                elementName: 'Administrators',
                nextObj: 'property'
             },
            'property': {
                elementName: 'Properties',
                nameField: 'key',
                retrievingAction: 'property_get_list',
                nextObj: 'config'
             },
            'config': {
                elementName: 'Configuration tokens',
                nameField: 'key',
                idField: 'key',
                retrievingAction: 'config_get'
             }
    },

    initialize: function (params) {
        this.model = new Wat.Models.Tenant(params);
        
        this.setBreadCrumbs();
       
        // Clean previous item name
        this.breadcrumbs.next.next.next.screen="";
            
        var templates = Wat.I.T.getTemplateList('tenantDetails');
        
        Wat.A.getTemplates(templates, function () {}); 
        
        // Bind tenant events
        Wat.B.bindTenantEvents();
        
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    events: {
        'click .js-button-purge': 'openPurgeDialog',
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
    
    openPurgeDialog: function () {    
        var that = this;
        
        var dialogConf = {
            title: $.i18n.t('Tenant purgation'),
            buttons : {
                "Close": function () {                    
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
                
                Wat.CurrentView.getCascadeElements();
            }
        }

        that.dialog = Wat.I.dialog(dialogConf);        
    },
                            
    getCascadeElements: function (qvdObj, forward, errors) {
        var qvdObj = qvdObj || 'vm';
        var forward = typeof(forward) == "undefined" ? true : forward;
        var errors = errors || false;
        
        var that = this;
        
        var retrievingAction = that.cascadeTenantElements[qvdObj]['retrievingAction'] || qvdObj + '_tiny_list';
        
        Wat.A.performAction(retrievingAction, {}, {
            tenant_id: that.elementId
            }, {}, function (that) {
                // If purge indicator is enabled, disable
                that.disablePurgeIndicator(qvdObj);

                var template = _.template(
                    Wat.TPL.deleteTenantDialogElements, {
                        elementQvdObj: qvdObj,
                        elementName: that.cascadeTenantElements[qvdObj]['elementName'],
                        registers: that.retrievedData.rows,
                        nameField: that.cascadeTenantElements[qvdObj]['nameField'] || 'name',
                        idField: that.cascadeTenantElements[qvdObj]['idField'] || 'id',
                        errors: errors
                    }
                );
                
                $('.bb-tenant-delete-' + qvdObj).html(template);
                Wat.T.translate();
            
                if (forward) {
                    if (that.cascadeTenantElements[qvdObj]['nextObj']) {
                        that.getCascadeElements(that.cascadeTenantElements[qvdObj]['nextObj']);
                        return;
                    }

                    var count = that.getTotalElementsCount();

                    if (count == 0) {
                        that.afterPurgeTenant();
                    }
                    else {
                        // After finish counting, show delete all button
                        $('.ui-dialog-buttonset .button').eq(1).show(); 
                    }
                }
            }, that);
    },
    
    getTotalElementsCount: function () {
        // Count total elements to know if is necesary delete some dependences
        var count = 0;
        $.each($('.js-counter'), function (iCounter, counter) {
            count+=parseInt($(counter).html());
        });
        
        return count;
    },
    
    enablePurgeIndicator: function (qvdObj) {
        $('[data-qvd-obj="' + qvdObj + '"].js-counter').addClass('fa fa-eraser');
    }, 
    
    disablePurgeIndicator: function (qvdObj) {
        $('[data-qvd-obj="' + qvdObj + '"].js-counter').removeClass('fa fa-eraser');
    },
    
    applyCascadeDelete: function (qvdObj, forward) {
        var qvdObj = qvdObj || 'vm';
        var forward = typeof(forward) == "undefined" ? true : forward;
        var that = this;
        
        var nElements = parseInt($('[data-qvd-obj="' + qvdObj + '"].js-counter').html());
        
        if (!nElements) {   
            if (forward) {
                if (that.cascadeTenantElements[qvdObj]['nextObj']) {
                    that.applyCascadeDelete(that.cascadeTenantElements[qvdObj]['nextObj']);
                    return;
                }
                
                var count = that.getTotalElementsCount();
                if (count == 0) {
                    that.afterPurgeTenant();
                }
                
                // Hide delete all button until all data were retrieved
                $('.ui-dialog-buttonset').show();
            }
            return;
        }
        
        var elements = $('ul[data-qvd-obj="' + qvdObj + '"] li');
        var elementIds = [];
        $.each(elements, function (iElement, element) {
            elementIds.push($(element).attr('data-id'));
        });
        
        // Build filters with element id
        var idField = that.cascadeTenantElements[qvdObj]['idField'] || 'id';
        var filters = {};
        filters[idField] = elementIds;

        that.enablePurgeIndicator(qvdObj);
        
        Wat.A.performAction(qvdObj + '_delete', {}, filters, {}, function (res) {
                var that = Wat.CurrentView;
                            
                if (res.retrievedData.status == STATUS_SUCCESS) {
                    $('[data-qvd-obj="' + qvdObj + '"].js-counter').html('0')
                    $('ul[data-qvd-obj="' + qvdObj + '"] li').remove();
                    that.disablePurgeIndicator(qvdObj);
                }
                else {
                    that.getCascadeElements(qvdObj, false, res.retrievedData.failures);
                }

                if (forward && that.cascadeTenantElements[qvdObj]['nextObj']) {
                    that.applyCascadeDelete(that.cascadeTenantElements[qvdObj]['nextObj']);
                    return;
                }
                
                var count = that.getTotalElementsCount();

                if (count == 0) {
                    that.afterPurgeTenant();
                }
            }, that);
    },
    
    afterPurgeTenant: function () {
        var template = _.template(
            Wat.TPL.deleteTenantDialogEmpty, {}
        );
        
        $(this.dialog).html(template);
        Wat.T.translate();

        // Hide delete all button
        $('.ui-dialog-buttonset .button').eq(1).hide();
    },
    
    applyDeleteElement: function (qvdObj, elementId) {
        var that = this;
        // Build filters with element id
        var idField = this.cascadeTenantElements[qvdObj]['idField'] || 'id';
        var filters = {};
        filters[idField] = elementId;
        
        Wat.A.performAction(qvdObj + '_delete', {}, filters, {}, function (that) {                            
                if (that.retrievedData.status == STATUS_SUCCESS) {
                    var count = parseInt($('[data-qvd-obj="' + qvdObj + '"].js-counter').html());
                    $('[data-qvd-obj="' + qvdObj + '"].js-counter').html(count-1)
                    $('ul[data-qvd-obj="' + qvdObj + '"] li[data-id="' + elementId + '"]').remove();
                }
                else {
                    that.getCascadeElements(qvdObj, false, that.retrievedData.failures);
                }
                
                var count = that.getTotalElementsCount();

                if (count == 0) {
                    that.afterPurgeTenant();
                }
            }, that);
    }
});