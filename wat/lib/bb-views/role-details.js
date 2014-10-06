Wat.Views.RoleDetailsView = Wat.Views.DetailsView.extend({  
    setupCommonTemplateName: 'setup-common',
    setupOption: 'roles',
    secondaryContainer: '.bb-setup',
    qvdObj: 'role',

    initialize: function (params) {
        this.model = new Wat.Models.Role(params);
        
        this.setBreadCrumbs();
       
        // Clean previous 
        this.breadcrumbs.next.next.next.screen="";

        this.params = params;
        
        this.renderSetupCommon();
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
        var sideContainer = '.' + this.cid + ' .bb-details-side1';
        
        // Render ACLs list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer;
        params.forceListColumns = {name: true, roles: true};
        params.forceSelectedActions = {};
        params.forceListActionButton = null;
        params.block = 10;
        params.filters = {"id": this.elementId};
        params.action = 'get_acls_in_roles';
        
        this.sideView = new Wat.Views.ACLListView(params);
    },
    
    render: function () {
        Wat.Views.DetailsView.prototype.render.apply(this);

        this.renderManagerInheritedRoles();   
        this.renderManagerACLs();
        this.renderManagerExcludedACLs();
        
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
        $('.bb-role-acls').html(aclsRolesTemplate);
        
        var params = {
            'action': 'acl_tiny_list',
            'selectedId': '',
            'controlName': 'acl_positive',
            'filters': {
            }
        };

        Wat.A.fillSelect(params);
        
        // Set selected acls on rigth side and delete it from left side
        $.each(this.model.get('acls').positive, function (iAcl, acl) {
            $('select[name="acl_positive"] option[value="' + iAcl + '"]').remove();
            $('select[name="acl_positive_on_role"]').append('<option value="' + iAcl + '">' + acl + '</option>');
        });   
        
        // Disable acls that exist in negative mode
        $.each(this.model.get('acls').negative, function (iAcl, acl) {
            $('select[name="acl_positive"] option[value="' + iAcl + '"]').remove();
        });
        
        
        var excludedRolesTemplate = Wat.A.getTemplate('details-role-excluded-acls');
        $('.bb-role-excluded-acls').html(excludedRolesTemplate);
        
        var params = {
            'action': 'acl_tiny_list',
            'selectedId': '',
            'controlName': 'acl_negative',
            'filters': {
            }
        };

        Wat.A.fillSelect(params);
        
        // Set selected acls on rigth side and delete it from left side
        $.each(this.model.get('acls').negative, function (iAcl, acl) {
            $('select[name="acl_negative"] option[value="' + iAcl + '"]').remove();
            $('select[name="acl_negative_on_role"]').append('<option value="' + iAcl + '">' + acl + '</option>');
        });
        
        // Disable acls that exist in positive mode
        $.each(this.model.get('acls').positive, function (iAcl, acl) {
            $('select[name="acl_negative"] option[value="' + iAcl + '"]').remove();
        });
    },    
    
    renderManagerExcludedACLs: function () {

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