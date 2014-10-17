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
        
        this.renderSetupCommon();
    },
    
    events: {
        'change select[name="section"]': 'changeSectionFilter',
        'change select[name="action"]': 'changeActionFilter',
    },
    
    changeActionFilter: function (e) {
        this.filterAction = $(e.target).val();
        this.fillACLCombos();
    },   
    
    changeSectionFilter: function (e) {
        this.filterSection = $(e.target).val();
        this.fillACLCombos();
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
        if (this.checkSide({'role.see.acl-list': '.js-side-component1'}) === false) {
            return;
        }
        
        var sideContainer = '.' + this.cid + ' .bb-details-side1';
        
        // Render ACLs list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer;
        params.forceListColumns = {name: true};
        // If Administrator has permission show origin of ACLs
        if (Wat.C.checkACL('role.see.acl-list-roles')) {
            params.forceListColumns.roles = true;
        }
        params.forceSelectedActions = {};
        params.forceListActionButton = null;
        params.block = 20;
        params.filters = {"role_id": this.elementId};
        params.action = 'get_acls_in_roles';
        
        this.sideView = new Wat.Views.ACLListView(params);
    },
    
    render: function () {
        Wat.Views.DetailsView.prototype.render.apply(this);

        this.renderManagerInheritedRoles();   
        this.renderManagerACLs();
        
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
        
        Wat.I.chosenConfiguration();
        
        Wat.I.chosenElement('[name="role"]', 'advanced100');
    },    
    
    renderManagerACLs: function () {
        var aclsRolesTemplate = Wat.A.getTemplate('details-role-acls');
        
        // Fill the html with the template and the model
        this.template = _.template(
            aclsRolesTemplate, {}
        );
        
        $('.bb-role-acls').html(this.template);
        
        this.fillACLCombos();
    },
    
    fillACLCombos: function () {
        $('select[name="acl_available"] option').remove();
        $('select[name="acl_positive_on_role"] option').remove();
        $('select[name="acl_negative_on_role"] option').remove();
        
        var params = {
            'action': 'acl_tiny_list',
            'selectedId': '',
            'controlName': 'acl_available',
            'filters': {
            },
            'nameAsId': true
        };
        
        if (this.filterSection != '-1' && this.filterAction != '-1') {
            params.filters.name = this.filterSection + '.' + this.filterAction + '.%';
        }
        else if (this.filterSection != '-1') {
            params.filters.name = this.filterSection + '.%';
        }
        else if (this.filterAction != '-1') {
            params.filters.name = '%.' + this.filterAction + '.%';
        }

        Wat.A.fillSelect(params);
        
        this.fillACLsFilters();
        
        // Set selected acls on acl list and delete it from available side
        $.each(this.model.get('acls').positive, function (iAcl, acl) {
            if ($('select[name="acl_available"] option[value="' + acl + '"]').val() != undefined) {
                $('select[name="acl_available"] option[value="' + acl + '"]').remove();
                $('select[name="acl_positive_on_role"]').append('<option value="' + acl + '">' + acl + '</option>');
            }
        });   
        
        // Enable delete button when select any element of list
        Wat.B.bindEvent('change', 'select[name="acl_positive_on_role"]', function () { 
            $('.js-delete-positive-acl-button').removeClass('disabled');
        });
        
        // Set selected acls on excluded list and delete it from available side
        $.each(this.model.get('acls').negative, function (iAcl, acl) {
            if ($('select[name="acl_available"] option[value="' + acl + '"]').val() != undefined) {
                $('select[name="acl_available"] option[value="' + acl + '"]').remove();
                $('select[name="acl_negative_on_role"]').append('<option value="' + acl + '">' + acl + '</option>');
            }
        });
        
        // Enable delete button when select any element of list
        Wat.B.bindEvent('change', 'select[name="acl_negative_on_role"]', function () { 
            $('.js-delete-negative-acl-button').removeClass('disabled');
        });
        
        // Remove acls that exist in positive mode
        $.each(this.model.get('acls').positive, function (iAcl, acl) {
            $('select[name="acl_available"] option[value="' + acl + '"]').remove();
        });
        
    },
    
    fillACLsFilters: function () {
        // Fill filter selects
        var aclCat1 = {'-1': 'All'};
        var aclCat2 = {'-1': 'All'};
        $.each($('select[name="acl_available"] option'), function (i,v) {
            var cat1 = $(v).val().split('.')[0];
            var cat2 = $(v).val().split('.')[1];
            
            if ($.inArray(cat1, Object.keys(aclCat1)) == -1) {
                aclCat1[cat1] = cat1;
            }            
            if ($.inArray(cat2, Object.keys(aclCat2)) == -1) {
                aclCat2[cat2] = cat2;
            }
        });
        
        var params = {
            'startingOptions': aclCat1,
            'selectedId': this.filterSection,
            'controlName': 'section',
            'translateOptions': ['-1'],
            'filters': {
            }
        };

        Wat.A.fillSelect(params);
        Wat.A.fillSelect(params);
        Wat.I.chosenElement('[name="section"]', 'single');

        var params = {
            'startingOptions': aclCat2,
            'selectedId': this.filterAction,
            'controlName': 'action',
            'translateOptions': ['-1'],
            'filters': {
            }
        };

        Wat.A.fillSelect(params);
        Wat.I.chosenElement('[name="action"]', 'single');
    },
    
    afterUpdateRoles: function () {
        this.renderManagerInheritedRoles();
        $('.bb-details-side1').html(HTML_MINI_LOADING);
        this.renderSide();
        var selectedSubmenuOption = $('.js-submenu-option.menu-option--selected').attr('data-show-submenu');
        $('.acls-management').hide();
        $('.' + selectedSubmenuOption).show();
    },
    
    afterUpdateAcls: function () {
        this.renderManagerInheritedRoles();
        this.renderManagerACLs();
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