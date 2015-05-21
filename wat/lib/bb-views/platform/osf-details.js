Wat.Views.OSFDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'osf',
    liveFields: ['number_of_vms', 'number_of_dis'],

    initialize: function (params) {
        this.model = new Wat.Models.OSF(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    renderSide: function () {
        var sideCheck = this.checkSide({
            'osf.see.vm-list': '.js-side-component1', 
            'osf.see.di-list': '.js-side-component2', 
            'osf.see.log': '.js-side-component3'
        });

        if (sideCheck === false) {
            return;
        }
        
        if (sideCheck['osf.see.di-list']) { 
            var sideContainer2 = '.' + this.cid + ' .bb-details-side1';

            // Render Disk images list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer2;
            params.forceListColumns = {disk_image: true};
            
            if (Wat.C.checkGroupACL('osfDiEmbeddedInfo')) {
                params.forceListColumns['info'] = true;
            }

            if (Wat.C.checkACL('osf.see.di-list-default-update')) {
                params.forceListColumns.default = true;
            }

            // Check ACLs to show or not info icons in DIs list
            params.forceInfoRestrictions = {};
            if (Wat.C.checkACL('osf.see.di-list-default')) {
                params.forceInfoRestrictions.default = true;
            }
            if (Wat.C.checkACL('osf.see.di-list-head')) {
                params.forceInfoRestrictions.head = true;
            }
            if (Wat.C.checkACL('osf.see.di-list-tags')) {
                params.forceInfoRestrictions.tags = true;
            }
            if (Wat.C.checkACL('osf.see.di-list-block')) {
                params.forceInfoRestrictions.block = true;
            }
            
            params.forceSelectedActions = {};
            params.block = 5;
            params.filters = {"osf_id": this.elementId};
            
            this.sideViews.push(new Wat.Views.DIListView(params));  
        }
        
        if (sideCheck['osf.see.vm-list']) { 
            var sideContainer1 = '.' + this.cid + ' .bb-details-side2';

            // Render Virtual Machines list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer1;
            params.forceListColumns = {name: true, tag: true};
            
            if (Wat.C.checkGroupACL('osfVmEmbeddedInfo')) {
                params.forceListColumns['info'] = true;
            }
                
            // Check ACLs to show or not info icons in OSFs list
            params.forceInfoRestrictions = {};
            if (Wat.C.checkACL('osf.see.vm-list-block')) {
                params.forceInfoRestrictions.block = true;
            }
            if (Wat.C.checkACL('osf.see.vm-list-expiration')) {
                params.forceInfoRestrictions.expiration = true;
            }
            if (Wat.C.checkACL('osf.see.vm-list-state')) {
                params.forceInfoRestrictions.state = true;
            }
            if (Wat.C.checkACL('osf.see.vm-list-user-state')) {
                params.forceInfoRestrictions.user_state = true;
            }
            
            params.forceSelectedActions = {};
            params.forceListActionButton = null;
            params.block = 5;
            params.filters = {"osf_id": this.elementId};
            this.sideViews.push(new Wat.Views.VMListView(params));
        }
        
        
        if (sideCheck['osf.see.log']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side3';

            // Render Related log list on side
            var params = this.getSideLogParams(sideContainer);

            this.sideViews.push(new Wat.Views.LogListView(params));
        
            this.renderLogGraph(params);
        }
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
    }
});