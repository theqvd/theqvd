Wat.Views.RoleDetailsView = Wat.Views.DetailsView.extend({  
    setupOption: 'roles',
    secondaryContainer: '.bb-setup',
    qvdObj: 'role',
    
    filterSection: '-1',
    filterAction: '-1',
    
    relatedDoc: {
        permissions_introduction: "Permissions introduction",
        permissions_guide: "Permissions guide"
    },

    initialize: function (params) {
        this.model = new Wat.Models.Role(params);
        
        this.setBreadCrumbs();
       
        // Clean previous 
        this.breadcrumbs.next.next.next.screen="";

        this.params = params;
        
        // Extend the common events
        this.extendEvents(this.eventsDetails);
        
        Wat.I.chosenConfiguration();
    
        // Add specific templates for this view
        this.addSpecificTemplates();
        
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    addSpecificTemplates: function () {
        var templates = {
            inheritanceToolsRoles: {
                name: 'details/role-inheritance-tools-roles'
            },
            inheritanceToolsTemplates: {
                name: 'details/role-inheritance-tools-templates'
            },
            inheritanceList: {
                name: 'details/role-inheritance-list'
            },
            aclsRoles: {
                name: 'details/role-acls-tree'
            }
        }
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    events: {
        'click .js-branch-button': 'toggleBranch',
        'change .js-branch-check': 'checkBranch',
        'change .js-acl-check': 'checkACL',
        'change .js-acl-tree-selector': 'toggleTree',
        'change .js-role-inherit-mode': 'toggleInheritModes',
        'click .js-role-inherit-mode': 'inheritTemplate'
    },
    
    toggleInheritModes: function (e) {
        switch ($(e.target).val()) {
            case 'role':
                $('.inherit-role').show();
                $('.inherit-template').hide();
                break;
            case 'template':
                $('.inherit-role').hide();
                $('.inherit-template').show();
                break;

        }
    },
    
    toggleTree: function (e) {
        // Hide all trees
        $('.js-acls-tree').hide();
        
        // Close all branches
        $('.js-branch-button').attr('data-open',1);
        $('.js-branch-button').trigger('click');
        
        // Show selected tree
        switch ($(e.target).val()) {
            case 'sections':
                $('.js-sections-tree').show();
                break;
            case 'actions':
                $('.js-actions-tree').show();
                break;
        }
    },
    
    // Show-Hide ACL branch
    toggleBranch: function (e) {
        var branch = $(e.target).attr('data-branch');
        var treeKind = $(e.target).attr('data-tree-kind');
        
        //branchDiv.append('<div class="subbranch">' + branch + '</div>');
        this.currentBranchDiv = $(e.target).parent();
        this.currentTreeKind = treeKind;
        this.currentBranch = branch;
        
        if ($(e.target).attr('data-open') == '1') {
            $(e.target).addClass('fa-plus-square-o');
            $(e.target).removeClass('fa-minus-square-o');
            $(e.target).attr('data-open', 0);
            this.currentBranchDiv.find('.subbranch').remove();
        }
        else {
            $(e.target).addClass('fa-minus-square-o');
            $(e.target).removeClass('fa-plus-square-o');
            $(e.target).attr('data-open', 1);
            
            var filters = {};
            switch (treeKind) {
                case 'actions':
                    filters = {'acl_name': { '~' : '%.' + branch + '.%' }, 'role_id': this.id};
                    break;
                case 'sections':
                    filters = {'acl_name': { '~' : branch + '.%' }, 'role_id': this.id};
                    break;
            }
            
            this.currentBranchDiv.append(HTML_MINI_LOADING);

            Wat.A.performAction('get_acls_in_roles', {}, filters, {}, this.fillBranch, this);
        }
    },
    
    // Fill branch with retreived ACLs from API
    fillBranch: function (that) {
        var showNotVisibleAcls = Wat.C.checkACL('role.update.assign-acl');

        // Sort acls
        var sortedAcls = Wat.U.sortTranslatedACLs(that.retrievedData.rows);
        
        $.each(sortedAcls, function (iACL, acl) {
            var disabledClass = 'disabled-branch';
            var checkedAttr = '';
            
            if (acl.operative) {
                var disabledClass = '';
                var checkedAttr = 'checked';
            }
            else {
                if (!showNotVisibleAcls) {
                    return;
                }
                
                var disabledClass = 'disabled-branch';
                var checkedAttr = '';
            }
            
            // Number of roles where the acl is inherited from
            var inheritedRoles = Object.keys(acl.roles).length;
            
            var subbranch = '';
            subbranch += '<div class="subbranch ' + disabledClass + '" data-acl="' + acl.name + '" data-acl-id="' + acl.id + '">';
            
                // Assignation checkbox
                if (Wat.C.checkACL('role.update.assign-acl') && (!that.model.get('fixed') || !RESTRICT_TEMPLATES)) {
                    subbranch += '<span class="subbranch-piece">';
                        subbranch += '<input type="checkbox" class="js-acl-check acl-check" data-acl="' + acl.name + '" data-acl-id="' + acl.id + '" ' + checkedAttr + '/>';
                    subbranch += '</span>';
                }
            
                // Inheritence procendence indicator
                if (Wat.C.checkACL('role.see.acl-list-roles') && inheritedRoles) {
                    var roles = [];
                    $.each(acl.roles, function (iRole, role) {
                        roles.push(role); 
                    });
                    var titleRole = $.i18n.t('Inherited from roles') + ':<br/><br/>&raquo;' + roles.join('<br/><br/>&raquo;');
                    subbranch += '<span class="subbranch-piece">';
                        subbranch += '<i class="' + CLASS_ICON_ROLES + ' acl-inheritance" data-acl-id="' + acl.id + '" title="' + titleRole + '"></i>';
                    subbranch += '</span>';
                }
            
                // Name of the ACL
                subbranch += '<span class="subbranch-piece" data-i18n="' + acl.description + '"></span>';
            
            subbranch += '</div>';
            that.currentBranchDiv.append(subbranch);
        });
                
        that.currentBranchDiv.find('.mini-loading').hide();

        Wat.T.translate();
    },
    
    // Check all the acls of a branch triggered when check branch
    checkBranch: function (e) {
        var checked = $(e.target).is(':checked');
        
        $(e.target).parent().find('input').prop('checked', checked);
        
        var branch = $(e.target).attr('data-branch');
        this.checkedBranch = branch;
        
        var treeKind = $(e.target).attr('data-tree-kind');
        
        this.groupACLChecked = checked;
                
        switch (treeKind) {
            case 'actions':
                filters = {'name': {'~': '%.' + branch + '.%'}};
                break;
            case 'sections':
                filters = {'name': {'~': branch + '.%'}};
                break;
        }
                
        // Retrieve acls of a branch to change them
        Wat.A.performAction('acl_tiny_list', {}, filters, {}, this.performACLGroupCheck, this);
    },
    
    // Assign-unassign acls of a branch
    performACLGroupCheck: function (that) {        
        var branchACLs = that.retrievedData.rows;
        
        var acls = [];
        $.each(branchACLs, function (iACL, acl) {
            acls.push(acl.name);
        });
               
        if (that.groupACLChecked) {
            that.applyChangeACL({
                assign_acls: acls
            });
        }
        else {
            that.applyChangeACL({
                unassign_acls: acls
            });
        }
    },
    
    // Assign-unassign ACL triggered when check an ACL
    checkACL: function (e) {
        var checked = $(e.target).is(':checked');
        var aclName = $(e.target).attr('data-acl');
        var currentSubBranch = $(e.target).parent().parent();
        this.checkedBranch = this.currentBranch;
        
        if (checked) {
            this.applyChangeACL({
                assign_acls: [ aclName]
            });
            currentSubBranch.removeClass('disabled-branch');

        }
        else {
            this.applyChangeACL({
                unassign_acls: [ aclName]
            });
            currentSubBranch.addClass('disabled-branch');
        }
    },
    
    // Unpdate ACL changs on Model
    applyChangeACL: function (aclChange) {        
        var context = $('.' + this.cid);

        var arguments = {
            __acls_changes__: aclChange
        };

        this.updateModel(arguments, {id: this.id}, this.getBranchStats);
    },
    
    getBranchStats: function (that) {
        var treeKind = $('.js-acl-tree-selector').val();

        var aclPattern = '';
        switch(treeKind) {
            case 'sections':
                aclPattern = that.checkedBranch + '.%';
                break;
            case 'actions':
                aclPattern = '%.' + that.checkedBranch + '.%';
                break;
        }

        Wat.A.performAction('number_of_acls_in_role', {}, {"role_id": that.id, "acl_pattern": [aclPattern]}, {}, that.updateBranchStats, that);
    },
    
    updateBranchStats: function (that) {
        var treeKind = $('.js-acl-tree-selector').val();
        
        var aclPattern = '';
        switch(treeKind) {
            case 'sections':
                aclPattern = that.checkedBranch + '.%';
                break;
            case 'actions':
                aclPattern = '%.' + that.checkedBranch + '.%';
                break;
        }
        
        var effectiveACLs = that.retrievedData[aclPattern].effective;
        var totalACLs = that.retrievedData[aclPattern].total;
        
        $('span.js-effective-count[data-branch="' + that.checkedBranch + '"]').html(effectiveACLs);
        
        if (totalACLs == effectiveACLs) {
            $('input.js-branch-check[data-branch="' + that.checkedBranch + '"]').prop('checked', true);
            $('div.js-acls-branch[data-branch="' + that.checkedBranch + '"]').find('div.subbranch').removeClass('disabled-branch');
        }
        else {
            $('input.js-branch-check[data-branch="' + that.checkedBranch + '"]').prop('checked', false);
        }

        if (effectiveACLs == 0) {
            $('div.js-acls-branch[data-branch="' + that.checkedBranch + '"]').addClass('disabled-branch');
            $('div.js-acls-branch[data-branch="' + that.checkedBranch + '"]').find('div.subbranch').addClass('disabled-branch');
        }
        else {
            $('div.js-acls-branch[data-branch="' + that.checkedBranch + '"]').removeClass('disabled-branch');
        }
    },
    
    renderSide: function () {
        var sideCheck = this.checkSide({'role.see.acl-list': '.js-side-component1', 'role.see.log': '.js-side-component2'});
        if (sideCheck === false) {
            return;
        }
        
        if (sideCheck['role.see.log']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side2';
            
            // Render Related log list on side
            var params = this.getSideLogParams(sideContainer);
            
            this.sideViews.push(new Wat.Views.LogListView(params));
            
            this.renderLogGraph(params);
        }
        
        if (sideCheck['role.see.acl-list']) { 
            this.aclPatterns = $.extend(ACL_SECTIONS_PATTERNS, ACL_ACTIONS_PATTERNS);
            var aclPatternsArray = _.toArray(this.aclPatterns);
            
            Wat.A.performAction('number_of_acls_in_role', {}, {"role_id": this.id, "acl_pattern": aclPatternsArray}, {}, this.renderACLsTree, this);
        }
    },
    
    render: function () {
        Wat.Views.DetailsView.prototype.render.apply(this);
        
        if (Wat.C.checkACL('role.see.inherited-roles')) {
            this.renderManagerInheritedList();   
            this.renderManagerInheritedRoles();   
        }
        else {
            $('.js-menu-roles').hide();
        }
        
        Wat.T.translate();
    },
    
    renderManagerInheritedList: function () {
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.inheritanceList, {
                model: this.model,
                inheritFilter: 'roles'
            }
        );
        $('.bb-role-inherited-list').html(this.template);
        
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.inheritanceList, {
                model: this.model,
                inheritFilter: 'templates'
            }
        );
        $('.bb-template-inherited-list').html(this.template);
    },
    
    renderManagerInheritedRoles: function () {
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.inheritanceToolsRoles, {
                model: this.model
            }
        );
        $('.bb-role-inherited-tools-roles').html(this.template);
        
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.inheritanceToolsTemplates, {
                model: this.model
            }
        );
        $('.bb-role-inherited-tools-templates').html(this.template);
        
        Wat.I.chosenElement('select[name="role-inherit-mode"]', 'single100');
        
        this.fillInheritedRolesSelect();
        this.fillInheritedTemplatesMatrix();
        
    },
    
    fillInheritedRolesSelect: function () {
        // Fill roles select
        var params = {
            'action': 'role_tiny_list',
            'selectedId': '',
            'controlName': 'role',
            'filters': {
                "internal": false
            },
            'order_by': {
                "field": ["internal","name"],
                "order": "-asc"
            },
            'chosenType': 'advanced100'
        };
        
        var that = this;
        $('select[name="role"] option').remove();
        Wat.A.fillSelect(params, function () {
            // Remove from inherited roles selector, current role and already inherited ones (for standard roles)
            $('select[name="role"] option[value="' + that.elementId + '"]').remove();

            $.each(that.model.get('roles'), function (iRole, role) {
                $('select[name="role"] option[value="' + iRole + '"]').remove();
            });
            
            Wat.T.translate();
        });
        
    },
    
    fillInheritedTemplatesMatrix: function () {
        // Fill templates matrix
        Wat.A.performAction('role_tiny_list', {}, {internal: "1"}, {}, function (that) {
            var currentRoles = that.model.get('roles');
            
            $.each(that.retrievedData.rows, function (iTemplate, template) {
                var checkbox = $('td[data-role-template-cell="' + template.name + '"]>input');
                
                checkbox.removeClass('invisible');

                checkbox.attr('data-role-template-id', template.id);
                
                if (currentRoles[template.id] != undefined) {
                    checkbox.attr('checked', 'checked');
                }
                else {
                    checkbox.removeAttr('checked');
                }
            });
        }, this);
    },    
    
    renderACLsTree: function (that) {
        var branchStats = that.retrievedData;
        
        // Fill the html with the template and the model
        that.template = _.template(
            Wat.TPL.aclsRoles, {
                sections: ACL_SECTIONS,
                actions: ACL_ACTIONS,
                aclPatterns: that.aclPatterns,
                branchStats: branchStats,
                model: that.model
            }
        );
        
        $('.bb-details-side1').html(that.template);
        
        Wat.I.chosenElement('select.js-acl-tree-selector', 'single100');
        
        Wat.T.translate();
    },
    
    afterUpdateRoles: function (performedAction) {
        this.renderSide();
        this.renderManagerInheritedList(); 
        
        switch (performedAction) {
            case 'add_role':
            case 'delete_role':
                this.fillInheritedRolesSelect();
                break;
            case 'delete_template':
                this.fillInheritedTemplatesMatrix();
                break;
        }
        
    },
    
    afterUpdateAcls: function () {
        this.renderManagerInheritedRoles();
        $('.bb-details-side1').html(HTML_MINI_LOADING);
        this.renderSide();
        var selectedSubmenuOption = $('.js-submenu-option.menu-option--selected').attr('data-show-submenu');
        $('.acls-management').hide();
        $('.' + selectedSubmenuOption).show();
    },
    
    openEditElementDialog: function(e) {
        this.dialogConf.title = $.i18n.t('Edit Role') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
    },
    
    updateElement: function (dialog) {
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        
        var filters = {"id": this.id};
        var arguments = {};
        
        if (Wat.C.checkACL('role.update.name')) {
            arguments['name'] = name;
        }
        
        this.updateModel(arguments, filters, this.fetchDetails);
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
        
        // Toggle controls for new password
        this.bindEvent('change', 'input[name="change_password"]', this.vmEditorBinds.toggleNewPassword);
    },
    
    vmEditorBinds: {
        toggleNewPassword: function () {
            $('.new_password_row').toggle();
        }
    }
});