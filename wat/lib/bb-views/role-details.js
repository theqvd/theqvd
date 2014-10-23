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
            
            Wat.A.performAction('acl_tiny_list', {}, filters, {}, this.fillBranch, this);
        }
    },
    
    // Fill branch with retreived ACLs from API
    fillBranch: function (that) {
        $.each(that.retrievedData.result.rows, function (iACL, acl) {
            var subbranch = '';
            subbranch += '<div class="subbranch">';
                subbranch += '<span class="subbranch-piece">';
                    subbranch += '<input type="checkbox" class="js-acl-check acl-check" data-acl="' + acl.name + '" data-acl-id="' + acl.id + '"/>';
                subbranch += '</span>';
                subbranch += '<span class="subbranch-piece">';
                    subbranch += acl.name;
                subbranch += '</span>';
                subbranch += '<span class="subbranch-piece">';
                    subbranch += '<i class="fa fa-sitemap acl-inheritance hidden" data-acl-id="' + acl.id + '" title=""></i>';
                subbranch += '</span>';
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
        $.each(that.retrievedData.result.rows, function (iACL, acl) {
            that.currentBranchDiv.find('input[data-acl-id="' + acl.id + '"]').prop('checked', true);
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
    },
    
    // Check all the acls of a branch triggered when check branch
    checkBranch: function (e) {
        var checked = $(e.target).is(':checked');
        
        $(e.target).parent().find('input').prop('checked', checked);
        
        var branch = $(e.target).attr('data-branch');
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
        
        if (checked) {
            this.applyChangeACL({
                assign_acls: [$(e.target).attr('data-acl')]
            });
        }
        else {
            this.applyChangeACL({
                unassign_acls: [$(e.target).attr('data-acl')]
            });
        }
    },
    
    // Unpdate ACL changs on Model
    applyChangeACL: function (aclChange) {
        var that = this;
        
        var context = $('.' + that.cid);

        var arguments = {
            __acls_changes__: aclChange
        };

        that.updateModel(arguments, {id: that.id}, function () {});
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
        
        this.renderACLsTree();
        
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
    
    renderACLsTree: function () {
        var aclsRolesTemplate = Wat.A.getTemplate('details-role-acls-tree');
        
        // Fill the html with the template and the model
        this.template = _.template(
            aclsRolesTemplate, {
                sections: ACL_SECTIONS,
                actions: ACL_ACTIONS
            }
        );
        
        $('.bb-details-side1').html(this.template);
        
        Wat.I.chosenElement('select.js-acl-tree-selector', 'single');
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
        var arguments = {
            "name": name
        };
        
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