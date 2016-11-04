// Common lib for Administrator and Role views (list and details)
Wat.Common.BySection.administratorRole = {
    // Fetch roles from API and render the editor control to add/remove roles from an Administrator
    fetchAndRenderRoles: function (options) {
        $('.bb-assign-roles').html(HTML_LOADING);
        
        var options = options || {};
        
        var forcedTenantId = options.forcedTenantId;
        var avoidRoleId = options.avoidRoleId;
            
        var that = Wat.CurrentView;
            
        var currentRoles = {};

        if (forcedTenantId) {
            var roleListConditions = [
                "tenant_id",
                forcedTenantId, 
                "tenant_id",
                COMMON_TENANT_ID,    
            ];
        }
        else if (!that.model || (Wat.CurrentView.selectedItems && Wat.CurrentView.selectedItems.length > 1)) {         
            // If we are in list view, we check tenant of the selected elements
            
            var selectedTenants = [];
                        
            $.each(Wat.CurrentView.selectedItems, function (i, selectedId) {
                var elementTenant = Wat.CurrentView.collection.where({id: selectedId})[0].get('tenant_id');
                
                if ($.inArray(elementTenant, selectedTenants) == -1) {
                    selectedTenants.push(elementTenant);
                }
            });
            
            if (selectedTenants.length == 1) {
                // If all the selected elements belong to the same tenant, got the roles of this tenant and common ones
                var selectedTenant = selectedTenants[0];
                
                var roleListConditions = [
                    "tenant_id",
                    selectedTenant, 
                    "tenant_id",
                    COMMON_TENANT_ID,    
                ];
            }
            else {
                // If there are selected elements from more than one tenant, got the common roles
                var roleListConditions = [
                    "tenant_id",
                    COMMON_TENANT_ID,    
                ];
            }
        }
        else {
            // If we are editing one element, get roles of the element's tenant and common ones
            var roleListConditions = [
                "tenant_id",
                that.model.get('tenant_id'), 
                "tenant_id",
                COMMON_TENANT_ID,    
            ];
            
            // Store administrator roles to fill editor
            var currentRoles = that.model.get('roles');
        }
        
        var filter = {
            internal: "0"
        }
        
        if (Wat.C.isSuperadmin()) {
            filter["-or"] = roleListConditions;
        }
        
        Wat.A.performAction('role_get_list', {}, filter, {}, function (that) {
            that.editorRoles = that.retrievedData.rows;
            
            // If avoid tenant is defined, delete it
            if (typeof avoidRoleId != "undefined") {
                $.each (that.editorRoles, function (i, role) {
                    if (role.id == avoidRoleId) {
                        that.editorRoles.splice(i, 1);
                        return false;
                    }
                });
            }
            
            // Add inherted flag to roles object 
            $.each (that.editorRoles, function (i, role) {
                if (currentRoles && currentRoles[role.id]) {
                    that.editorRoles[i].inherited = 1;   
                }
                else {
                    that.editorRoles[i].inherited = 0;   
                }
            });                
            
            // Create structure to store editor variables
            that.assignRoles = [];
            that.unassignRoles = [];
            
            that.renderRoles();
        }, that, ['id', 'name']);
    },
    
    renderRoles: function () {
        // Render template and fill dialog
        var template = _.template(
            Wat.TPL.inheritanceToolsRoles, {
                roles: this.editorRoles
            }
        );

        $('.bb-assign-roles').html(template);
        
        if (this.editorRoles.length == this.countInheritedRoles) {
            $('.js-assign-role-control').hide();
        }
        else {
            $('.js-assign-role-control').show();
        }
        
        Wat.I.chosenElement('select[name="role_to_be_assigned"]', 'advanced100');
        
        Wat.T.translate();
    },
    
    editorAssignRole: function (roleId) {
        var that = this;
        
        // If role was previously unassigned, delete from unassign array
        var unassignPos = $.inArray(roleId, this.unassignRoles);
        
        if (unassignPos != -1) {
            this.unassignRoles.splice(unassignPos, 1);
        }
        else {
            // Add to assign array
            this.assignRoles.push(roleId);
        }
        
        // Set as inherited on data structure used to render editor
        this.countInheritedRoles = 0;
        
        $.each(this.editorRoles, function (iRole, role) {
            if (role.id == roleId) {
                that.editorRoles[iRole].inherited = 1;
            }
            
            if (that.editorRoles[iRole].inherited) {
                that.countInheritedRoles++;
            }
        });
        
        this.renderRoles();
    },
    
    editorDeleteRole: function (roleId) {
        var that = this;
        
        // If role was previously assigned, delete from assign array
        var assignPos = $.inArray(roleId, this.assignRoles);
        
        if (assignPos != -1) {
            this.assignRoles.splice(assignPos, 1);
        }
        else {        
            // Add to unassign array
            this.unassignRoles.push(roleId);
        }
        
        // Set as inherited on data structure used to render editor
        this.countInheritedRoles = 0;
        
        // Set as inherited on data structure used to render editor
        $.each(this.editorRoles, function (iRole, role) {
            if (role.id == roleId) {
                that.editorRoles[iRole].inherited = 0;
            }
            
            if (that.editorRoles[iRole].inherited) {
                that.countInheritedRoles++;
            }
        });
        
        this.renderRoles();
    }
}