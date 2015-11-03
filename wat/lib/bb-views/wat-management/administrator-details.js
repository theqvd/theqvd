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
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        // Add specific templates for this view
        this.addSpecificTemplates();
        
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    addSpecificTemplates: function () {
        var templates = Wat.I.T.getTemplateList('detailsAdministrator');
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    renderACLsTree: function (that) {
        // If data gathering is aborted due view switch or any other reason, abort rendering
        if (that.retrievedData.statusText == 'abort') {
            return;
        }
        
        var branchStats = that.retrievedData;
        
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
        var sideCheck = this.checkSide({'administrator.see.acl-list': '.js-side-component1', 'administrator.see.log': '.js-side-component2'});
        if (sideCheck === false) {
            return;
        }
        
        if (sideCheck['administrator.see.log']) {
            var sideContainer = '.' + this.cid + ' .bb-details-side2';
            
            // Render Related log list on side
            var params = this.getSideLogParams(sideContainer);
            
            this.sideViews.push(new Wat.Views.LogListView(params));
            
            this.renderLogGraph(params);
        }
        
        if (sideCheck['administrator.see.acl-list']) {
            this.aclPatterns = $.extend({}, ACL_SECTIONS_PATTERNS, ACL_ACTIONS_PATTERNS);
            
            var aclPatternsArray = _.toArray(this.aclPatterns);
            
            Wat.A.performAction('number_of_acls_in_admin', {}, {"admin_id": this.id, "acl_pattern": aclPatternsArray}, {}, this.renderACLsTree, this);
        }
    },
    
    events: {
        'click .js-branch-button': 'toggleBranch',
        'click .js-branch-text': 'triggerToggleBranch',
        'change .js-acl-tree-selector': 'toggleTree',
        'click .js-tools-roles-btn': 'openRoleToolsDialog',
    },
    
    openRoleToolsDialog: function () {
        var that = this;
        
        var dialogConf = {
            title: 'Assign roles',
            buttons : {
                "Close": function () {
                    Wat.I.closeDialog($(this));
                }
            },
            button1Class : 'fa fa-check js-button-close',
            fillCallback : function(target) {
                $(target).html(HTML_MID_LOADING);
                $(target).css('padding', '0px');

                Wat.A.performAction('role_tiny_list', {}, {
                        internal: "0",
                        "-or": [
                            "tenant_id",
                            that.model.get('tenant_id'), 
                            "tenant_id",
                            COMMON_TENANT_ID,    
                        ]
                    }, {}, function (that) {
                    
                    var currentRoles = that.model.get('roles');
                    var roles = that.retrievedData.rows;

                    // Add inherted flag to roles object 
                    $.each (roles, function (i, role) {
                        if (currentRoles[role.id]) {
                            roles[i].inherited = 1;   
                        }
                        else {
                            roles[i].inherited = 0;   
                        }
                    });                

                    // Render template and fill dialog
                    var template = _.template(
                        Wat.TPL.inheritanceToolsRoles, {
                            model: this.model,
                            roles: roles
                        }
                    );
                    
                    $(target).html(template);
                    
                    $('.role-template-tools').tableScroll({
                        height: 400
                    });
                    
                    Wat.I.fixTableScrollStyles();
                    
                    Wat.T.translate();

                }, that);
            }
        }
        
        $("html, body").animate({ scrollTop: 0 }, 200);
        Wat.I.dialog(dialogConf);
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
    
    // Show-Hide ACL branch when click on branch name too
    triggerToggleBranch: function (e) {
        $(e.target).parent().find('.js-branch-button').trigger('click');
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
    
    afterUpdateRoles: function () {
        this.render();
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