Wat.Views.RoleDetailsView = Wat.Views.DetailsView.extend({  
    setupCommonTemplateName: 'setup-common',
    setupOption: 'roles',
    secondaryContainer: '.bb-setup',
    qvdObj: 'role',
    
    filterSection: '-1',
    filterAction: '-1',

    initialize: function (params) {
        this.model = new Wat.Models.Role(params);
        
        this.setBreadCrumbs();
       
        // Clean previous 
        this.breadcrumbs.next.next.next.screen="";

        this.params = params;
        
        Wat.I.chosenConfiguration();
        
        this.renderSetupCommon();
    },
    
    events: {
        'click .js-branch-button': 'toggleBranch',
        'change .js-branch-check': 'checkBranch',
        'change .js-acl-check': 'checkACL',
        'change .js-acl-tree-selector': 'toggleTree',
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
                    filters = {'name': '%.' + branch + '.%'};
                    break;
                case 'sections':
                    filters = {'name': branch + '.%'};
                    break;
            }
                        
            this.currentBranchDiv.append(HTML_MINI_LOADING);
            
            Wat.A.performAction('acl_tiny_list', {}, filters, {}, this.fillBranch, this);
        }
    },
    
    // Fill branch with retreived ACLs from API
    fillBranch: function (that) {
        $.each(that.retrievedData.result.rows, function (iACL, acl) {
            var subbranch = '';
            subbranch += '<div class="subbranch disabled-branch hidden" data-acl="' + acl.name + '" data-acl-id="' + acl.id + '">';
                if (Wat.C.checkACL('role.update.assign-acl')) {
                    subbranch += '<span class="subbranch-piece">';
                        subbranch += '<input type="checkbox" class="js-acl-check acl-check" data-acl="' + acl.name + '" data-acl-id="' + acl.id + '"/>';
                    subbranch += '</span>';
                }
                subbranch += '<span class="subbranch-piece">';
                    subbranch += ACLS[acl.name];
                subbranch += '</span>';
                if (Wat.C.checkACL('role.see.acl-list-roles')) {
                    subbranch += '<span class="subbranch-piece">';
                        subbranch += '<i class="fa fa-sitemap acl-inheritance hidden" data-acl-id="' + acl.id + '" title=""></i>';
                    subbranch += '</span>';
                }
            subbranch += '</div>';
            that.currentBranchDiv.append(subbranch);
        });
                
        switch (that.currentTreeKind) {
            case 'actions':
                filters = {'acl_name': '%.' + that.currentBranch + '.%', 'role_id': that.id};
                break;
            case 'sections':
                filters = {'acl_name': that.currentBranch + '.%', 'role_id': that.id};
                break;
        }
        
        Wat.A.performAction('get_acls_in_roles', {}, filters, {}, that.fillEffectiveBranch, that);
    },
    
    // Set as checked the effective roles and added the inherit icon with inherited roles title
    fillEffectiveBranch: function (that) {
        // If we cant update acls, we only show effective acls
        var showNotVisibleAcls = Wat.C.checkACL('role.update.assign-acl');
        
        $.each(that.retrievedData.result.rows, function (iACL, acl) {
            that.currentBranchDiv.find('input[data-acl-id="' + acl.id + '"]').prop('checked', true);
            that.currentBranchDiv.find('div.subbranch[data-acl-id="' + acl.id + '"]').removeClass('disabled-branch');
            
            if (!showNotVisibleAcls) {
                that.currentBranchDiv.find('div.subbranch[data-acl-id="' + acl.id + '"]').show();
            }

            delete acl.roles[that.id];

            if (Object.keys(acl.roles).length > 0) {
                that.currentBranchDiv.find('i[data-acl-id="' + acl.id + '"].acl-inheritance').show();
                
                var roles = [];
                $.each(acl.roles, function (iRole, role) {
                    roles.push(role); 
                });
                var titleRole = $.i18n.t('Inherited from roles') + ':<br/><br/>&raquo;' + roles.join('<br/><br/>&raquo;');
                that.currentBranchDiv.find('i[data-acl-id="' + acl.id + '"].acl-inheritance').attr('title', titleRole);
            }
        });
        
        if (showNotVisibleAcls) {
            // We check if any of the acls of this branch is in negative acls to draw roles procedence
            $.each(that.currentBranchDiv.find('.subbranch'), function (iBranch, branch) {
                var aclName = $(branch).attr('data-acl');
                var aclId = $(branch).attr('data-acl-id');
                var negativeACLs = that.model.attributes.acls.negative;
                var inheritedRoles = that.model.attributes.roles;

                if ($.inArray(aclName, negativeACLs) != -1) { 

                    that.currentBranchDiv.find('i[data-acl-id="' + aclId + '"].acl-inheritance').show();

                    var roles = [];
                    $.each(inheritedRoles, function (iRole, role) {
                        if ($.inArray(aclName, role.acls) != -1) { 
                            roles.push(role.name); 
                        }
                    });

                    var titleRole = $.i18n.t('Inherited from roles') + ':<br/><br/>&raquo;' + roles.join('<br/><br/>&raquo;');
                    that.currentBranchDiv.find('i[data-acl-id="' + aclId + '"].acl-inheritance').attr('title', titleRole);                
                }
            });
        }
        
        // Only if we can update acls, not effective acls are shown
        if (showNotVisibleAcls) {
            that.currentBranchDiv.find('.subbranch').fadeIn();
        }
        that.currentBranchDiv.find('.mini-loading').hide();
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
                filters = {'name': '%.' + branch + '.%'};
                break;
            case 'sections':
                filters = {'name': branch + '.%'};
                break;
        }
        
        // Retrieve acls of a branch to change them
        Wat.A.performAction('acl_tiny_list', {}, filters, {}, this.performACLGroupCheck, this);
    },
    
    // Assign-unassign acls of a branch
    performACLGroupCheck: function (that) {        
        var branchACLs = that.retrievedData.result.rows;
        
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
        
        var effectiveACLs = that.retrievedData.result[aclPattern].effective;
        var totalACLs = that.retrievedData.result[aclPattern].total;
        
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
    
    renderSetupCommon: function () {

        this.templateSetupCommon = Wat.A.getTemplate(this.setupCommonTemplateName);
        var cornerMenu = Wat.I.getCornerMenu();
        
        // Fill the html with the template and the model
        this.template = _.template(
            this.templateSetupCommon, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: cornerMenu.setup.subMenu
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');

        // After render the side menu, embed the content of the view in secondary container
        this.embedContent();
    },
    
    renderSide: function () {
    },
    
    render: function () {
        Wat.Views.DetailsView.prototype.render.apply(this);
        
        if (Wat.C.checkACL('role.see.inherited-roles')) {
            this.renderManagerInheritedRoles();   
        }
        else {
            $('.js-menu-roles').hide();
        }
        
        this.aclPatterns = $.extend(ACL_SECTIONS_PATTERNS, ACL_ACTIONS_PATTERNS);
        var aclPatternsArray = _.toArray(this.aclPatterns);
        
        Wat.A.performAction('number_of_acls_in_role', {}, {"role_id": this.id, "acl_pattern": aclPatternsArray}, {}, this.renderACLsTree, this);
        
        // Trigger click on first menu option by default
        $('[data-show-submenu="acls-management-acls"]').trigger('click');
    },
    
    renderManagerInheritedRoles: function () {
        var inheritedRolesTemplate = Wat.A.getTemplate('details-role-inherited-roles');
        // Fill the html with the template and the model
        this.template = _.template(
            inheritedRolesTemplate, {
                model: this.model
            }
        );
        $('.bb-role-inherited-roles').html(this.template);
        
        var params = {
            'action': 'role_tiny_list',
            'selectedId': '',
            'controlName': 'role',
            'filters': {
            }
        };

        Wat.A.fillSelect(params);
        
        // Remove from inherited roles selector, current role and already inherited ones
        $('select[name="role"] option[value="' + this.elementId + '"]').remove();
 
        $.each(this.model.get('roles'), function (iRole, role) {
            $('select[name="role"] option[value="' + iRole + '"]').remove();
        });
        
        // Hack to avoid delays
        setTimeout(function(){
            Wat.I.chosenElement('[name="role"]', 'advanced');
        }, 100);
    },    
    
    renderACLsTree: function (that) {
        var branchStats = that.retrievedData.result;

        // If acl list is not visible, we destroy div and increase the details layer to fill the gap
        if (!Wat.C.checkACL('role.see.acl-list')) { 
            $('.js-details-side').remove();
            $('.details-block').addClass('col-width-100');
            return;
        }

        var aclsRolesTemplate = Wat.A.getTemplate('details-role-acls-tree');
        
        // Fill the html with the template and the model
        that.template = _.template(
            aclsRolesTemplate, {
                sections: ACL_SECTIONS,
                actions: ACL_ACTIONS,
                aclPatterns: that.aclPatterns,
                branchStats: branchStats
            }
        );
        
        $('.bb-details-side1').html(that.template);
        
        Wat.I.chosenElement('select.js-acl-tree-selector', 'single');
        
        Wat.T.translate();
    },
    
    afterUpdateRoles: function () {
        this.render();
    },
    
    afterUpdateAcls: function () {
        this.renderManagerInheritedRoles();
        $('.bb-details-side1').html(HTML_MINI_LOADING);
        this.renderSide();
        var selectedSubmenuOption = $('.js-submenu-option.menu-option--selected').attr('data-show-submenu');
        $('.acls-management').hide();
        $('.' + selectedSubmenuOption).show();
    },
    
    embedContent: function () {
        $(this.secondaryContainer).html('<div class="bb-content-secondary"></div>');

        this.el = '.bb-content-secondary';
        Wat.Views.DetailsView.prototype.initialize.apply(this, [this.params]);        
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