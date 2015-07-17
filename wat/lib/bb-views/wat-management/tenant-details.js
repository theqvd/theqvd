Wat.Views.TenantDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'tenant',

    initialize: function (params) {
        this.model = new Wat.Models.Tenant(params);
        
        this.setBreadCrumbs();
       
        // Clean previous item name
        this.breadcrumbs.next.next.next.screen="";
        
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
});