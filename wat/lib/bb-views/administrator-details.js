Wat.Views.AdminDetailsView = Wat.Views.DetailsView.extend({  
    setupOption: 'administrators',
    secondaryContainer: '.bb-setup',
    qvdObj: 'administrator',
    
    relatedDoc: {
        permissions_introduction: "Permissions introduction",
        permissions_guide: "Permissions guide",
        permissions_guide_multitenant: "Permissions guide (multitenant)"
    },

    initialize: function (params) {
        this.model = new Wat.Models.Admin(params);
                
        this.setBreadCrumbs();
       
        // Clean previous item name
        this.breadcrumbs.next.next.next.screen="";
        
        // Extend the common events
        this.extendEvents(this.eventsDetails);
        
        this.params = params;
                
        var templates = {
            aclsAdmins: {
                name: 'details-administrator-acls-tree'
            },
            inheritedRoles: {
                name: 'details-administrator-roles'
            },
            setupCommon: {
                name: 'setup-common'
            }
        }
        
        Wat.A.getTemplates(templates, this.renderSetupCommon, this); 
    },
    
    render: function () {
        Wat.Views.DetailsView.prototype.render.apply(this);

        this.renderManagerRoles();
        
        this.aclPatterns = $.extend({}, ACL_SECTIONS_PATTERNS, ACL_ACTIONS_PATTERNS);
        
        var aclPatternsArray = _.toArray(this.aclPatterns);
        
        Wat.A.performAction('number_of_acls_in_admin', {}, {"admin_id": this.id, "acl_pattern": aclPatternsArray}, {}, this.renderACLsTree, this);
        
        Wat.T.translate();
    },
    
    renderACLsTree: function (that) {
        var branchStats = that.retrievedData;
        // If acl list is not visible, we destroy div and increase the details layer to fill the gap
        if (!Wat.C.checkACL('administrator.see.acl-list')) { 
            $('.js-details-side').remove();
            $('.details-block').addClass('col-width-100');
            return;
        }

        // Fill the html with the template and the model
        that.template = _.template(
            Wat.TPL.aclsAdmins, {
                sections: ACL_SECTIONS,
                actions: ACL_ACTIONS,
                aclPatterns: that.aclPatterns,
                branchStats: branchStats
            }
        );
        
        $('.bb-details-side1').html(that.template);
        
        Wat.I.chosenElement('select.js-acl-tree-selector', 'single100');

        Wat.T.translate();
    },
    
    renderSide: function () {
        // No side rendered
        if (this.checkSide({'administrator.see.acl-list': '.js-side-component1', 'administrator.see.log': '.js-side-component2'}) === false) {
            return;
        }
        
        var sideContainer = '.' + this.cid + ' .bb-details-side2';

        // Render Related log list on side
        var params = this.getSideLogParams(sideContainer);

        this.sideView = new Wat.Views.LogListView(params);
        
        this.renderLogGraph(params);
    },
    
    events: {
        'click .js-branch-button': 'toggleBranch',
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
                    filters = {'acl_name': { '~' : '%.' + branch + '.%' }, 'admin_id': this.id};
                    break;
                case 'sections':
                    filters = {'acl_name': { '~' : branch + '.%' }, 'admin_id': this.id};
                    break;
            }
            
            this.currentBranchDiv.append(HTML_MINI_LOADING);

            Wat.A.performAction('get_acls_in_admins', {}, filters, {}, this.fillBranch, this);
        }
    },
    
    // Fill branch with retreived ACLs from API
    fillBranch: function (that) {
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
                return;
            }
            
            // Number of roles where the acl is inherited from
            var inheritedRoles = Object.keys(acl.roles).length;
            
            var subbranch = '';
            subbranch += '<div class="subbranch ' + disabledClass + '" data-acl="' + acl.name + '" data-acl-id="' + acl.id + '">';
                // Name of the ACL
                subbranch += '<span class="subbranch-piece" data-i18n="' + acl.description + '"></span>';
            
                // Inheritence procendence indicator
                if (Wat.C.checkACL('administrator.see.acl-list-roles') && inheritedRoles) {
                    var roles = [];
                    $.each(acl.roles, function (iRole, role) {
                        roles.push(role); 
                    });
                    var titleRole = $.i18n.t('Inherited from roles') + ':<br/><br/>&raquo;' + roles.join('<br/><br/>&raquo;');
                    subbranch += '<span class="subbranch-piece">';
                        subbranch += '<i class="' + CLASS_ICON_ROLES + ' acl-inheritance" data-acl-id="' + acl.id + '" title="' + titleRole + '"></i>';
                    subbranch += '</span>';
                }
            
            subbranch += '</div>';
            that.currentBranchDiv.append(subbranch);
        });
                
        that.currentBranchDiv.find('.mini-loading').hide();

        Wat.T.translate();
    },
    
    renderManagerRoles: function () {
        if (!Wat.C.checkACL('administrator.see.roles')) { 
            return;
        }
        
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.inheritedRoles, {
                model: this.model
            }
        );
        $('.bb-admin-roles').html(this.template);
        
        var params = {
            'action': 'role_tiny_list',
            'selectedId': '',
            'controlName': 'role',
            'filters': {
                'internal': false
            },
            'chosenType': 'advanced100'
        };
        
        var that = this;
        
        Wat.A.fillSelect(params, function () {
            $.each(that.model.get('roles'), function (iRole, role) {
                $('select[name="role"] option[value="' + iRole + '"]').remove();
            });
        });
    },    
    
    renderSetupCommon: function (that) {
        var that = that || this;
        
        var cornerMenu = Wat.I.getCornerMenu();
        
        // Fill the html with the template and the model
        that.template = _.template(
            Wat.TPL.setupCommon, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: null,
                //setupMenu: cornerMenu.wat.subMenu
            }
        );
        
        $(that.el).html(that.template);
        
        that.printBreadcrumbs(this.breadcrumbs, '');

        // After render the side menu, embed the content of the view in secondary container
        that.embedContent();
    },
    
    embedContent: function () {
        $(this.secondaryContainer).html('<div class="bb-content-secondary"></div>');

        this.el = '.bb-content-secondary';
        Wat.Views.DetailsView.prototype.initialize.apply(this, [this.params]);
    },
    
    afterUpdateRoles: function () {
        this.render();
    },
    
    openEditElementDialog: function(e) {
        this.dialogConf.title = $.i18n.t('Edit Administrator') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        Wat.I.chosenElement('[name="language"]', 'single');
    },
    
    updateElement: function (dialog) {
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var filters = {"id": this.id};
        var arguments = {};
        
        var context = $('.' + this.cid + '.editor-container');

        if (Wat.C.checkACL('administrator.update.password')) {
            // If change password is checked
            if (context.find('input.js-change-password').is(':checked')) {
                var password = context.find('input[name="password"]').val();
                var password2 = context.find('input[name="password2"]').val();
                if (password && password2 && password == password2) {
                    arguments['password'] = password;
                }
            }
        }
        
        if (Wat.C.checkACL('administrator.update.language')) {
            var language = context.find('select[name="language"]').val();
            arguments['language'] = language;
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