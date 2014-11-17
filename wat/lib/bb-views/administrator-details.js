Wat.Views.AdminDetailsView = Wat.Views.DetailsView.extend({  
    setupCommonTemplateName: 'setup-common',
    setupOption: 'admins',
    secondaryContainer: '.bb-setup',
    qvdObj: 'administrator',

    initialize: function (params) {
        this.model = new Wat.Models.Admin(params);
                
        this.setBreadCrumbs();
       
        // Clean previous item name
        this.breadcrumbs.next.next.next.screen="";
        
        
        this.params = params;
        
        this.renderSetupCommon();
    },
    
    render: function () {
        Wat.Views.DetailsView.prototype.render.apply(this);

        this.renderManagerRoles();
        
        this.aclPatterns = $.extend(ACL_SECTIONS_PATTERNS, ACL_ACTIONS_PATTERNS);
        var aclPatternsArray = _.toArray(this.aclPatterns);
        
        Wat.A.performAction('number_of_acls_in_admin', {}, {"admin_id": this.id, "acl_pattern": aclPatternsArray}, {}, this.renderACLsTree, this);
    },
    
    renderACLsTree: function (that) {
        var branchStats = that.retrievedData;
        // If acl list is not visible, we destroy div and increase the details layer to fill the gap
        if (!Wat.C.checkACL('administrator.see.acl-list')) { 
            $('.js-details-side').remove();
            $('.details-block').addClass('col-width-100');
            return;
        }
        
        var aclsAdminsTemplate = Wat.A.getTemplate('details-administrator-acls-tree');
        
        // Fill the html with the template and the model
        that.template = _.template(
            aclsAdminsTemplate, {
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
        $.each(that.retrievedData.rows, function (iACL, acl) {
            var subbranch = '';
            subbranch += '<div class="subbranch hidden" data-acl-id="' + acl.id + '">';
                subbranch += '<span class="subbranch-piece">';
                    subbranch += ACLS[acl.name];
                subbranch += '</span>';
                if (Wat.C.checkACL('administrator.see.acl-list-roles')) {
                    subbranch += '<span class="subbranch-piece">';
                        subbranch += '<i class="fa fa-graduation-cap acl-inheritance hidden" data-acl-id="' + acl.id + '" title=""></i>';
                    subbranch += '</span>';
                }
            subbranch += '</div>';
            that.currentBranchDiv.append(subbranch);
        });
        
        switch (that.currentTreeKind) {
            case 'actions':
                filters = {'acl_name': '%.' + that.currentBranch + '.%', 'admin_id': that.id};
                break;
            case 'sections':
                filters = {'acl_name': that.currentBranch + '.%', 'admin_id': that.id};
                break;
        }
        
        Wat.A.performAction('get_acls_in_admins', {}, filters, {}, that.fillEffectiveBranch, that);
    },
    
    // Set as checked the effective roles and added the inherit icon with inherited roles title
    fillEffectiveBranch: function (that) {
        $.each(that.retrievedData.rows, function (iACL, acl) {
            that.currentBranchDiv.find('div.subbranch[data-acl-id="' + acl.id + '"]').show();
            
            if (Object.keys(acl.roles).length > 0) {
                that.currentBranchDiv.find('i[data-acl-id="' + acl.id + '"].acl-inheritance').show();
                
                var roles = [];
                $.each(acl.roles, function (iRole, role) {
                    roles.push(role); 
                });
                var titleRole = $.i18n.t('Defined on roles') + ':<br/><br/>&raquo;' + roles.join('<br/><br/>&raquo;');
                that.currentBranchDiv.find('i[data-acl-id="' + acl.id + '"].acl-inheritance').attr('title', titleRole);
            }
        });
        
        that.currentBranchDiv.find('.mini-loading').hide();
    },
    
    
    renderManagerRoles: function () {
        if (!Wat.C.checkACL('administrator.see.roles')) { 
            return;
        }

        var inheritedRolesTemplate = Wat.A.getTemplate('details-administrator-roles');
        // Fill the html with the template and the model
        this.template = _.template(
            inheritedRolesTemplate, {
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
            }
        };

        Wat.A.fillSelect(params);
        
        $.each(this.model.get('roles'), function (iRole, role) {
            $('select[name="role"] option[value="' + iRole + '"]').remove();
        });
        
        Wat.I.chosenConfiguration();
        
        // Hack to avoid delays
        setTimeout(function(){
            Wat.I.chosenElement('[name="role"]', 'advanced');
        }, 100);
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
        
        // Virtual machine form include a date time picker control, so we need enable it
        Wat.I.enableDataPickers();
                
        var params = {
            'action': 'role_tiny_list',
            'selectedId': '',
            'controlName': 'role',
            'filters': {
            }
        };

        Wat.A.fillSelect(params);
        
        $.each(this.model.get('roles'), function (iRole, role) {
            $('select[name="role"] option[value="' + iRole + '"]').remove();
        });
        
        Wat.I.chosenElement('[name="role"]', 'single100');
    },
    
    renderSide: function () {
/*        if (this.checkSide({'administrator.see.acl-list': '.js-side-component1'}) === false) {
            return;
        }
        
        var sideContainer = '.' + this.cid + ' .bb-details-side1';

        // Render ACLs list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer;
        params.forceListColumns = {name: true};
        // If Administrator has permission and more than one role assigned, show origin of ACLs
        if (Wat.C.checkACL('administrator.see.acl-list-roles')) {
            params.forceListColumns.roles = true;
        }
        params.forceSelectedActions = {};
        params.forceListActionButton = null;
        params.block = 10;
        params.filters = {"admin_id": this.elementId};
        params.action = 'get_acls_in_admins';
        
        this.sideView = new Wat.Views.ACLListView(params);*/
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