Wat.Views.RoleListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'roles',
    qvdObj: 'role',
    
    initialize: function (params) {
        params.whatRender = 'list';
        if (params.filters == undefined) {
            params.filters = {};
        }
        
        params.filters.internal = false;
        
        this.collection = new Wat.Collections.Roles(params);
        
        this.renderSetupCommon();
    },
    
    renderSetupCommon: function () {
        var cornerMenu = Wat.I.getCornerMenu();
        
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.setupCommon, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: null,
                //setupMenu: cornerMenu.wat.subMenu
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');

        // After render the side menu, embed the content of the view in secondary container
        this.embedContent();
    },
    
    renderList: function () {
        Wat.Views.ListView.prototype.renderList.apply(this, []);

        var that = this;
        
        $.each($('.js-role-acls'), function (iCell, cell) {
            var roleID = $(cell).attr('data-id');
            Wat.A.performAction('number_of_acls_in_role', {}, {"role_id": roleID, "acl_pattern": ["%"]}, {}, function (that) {
                var numberOfAcls = that.retrievedData['%']['effective'];
                $(cell).html(numberOfAcls);
            }, that);
        });
    },
    
    embedContent: function () {
        $(this.secondaryContainer).html('<div class="bb-content-secondary"></div>');

        this.el = '.bb-content-secondary';
        Wat.Views.ListView.prototype.initialize.apply(this, []);
    },
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.Role();
        
        this.dialogConf.title = $.i18n.t('New Role');
        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
                
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        var tenant = context.find('select[name="tenant"]').val();
        
        var arguments = {
            "name": name,
            "tenant": tenant
        };
        
        // Go to first page and order by ID desc to got the last created element in first place
        this.collection.sort = {"field": "id", "order": "-desc"};
        $('div.pagination>.first').trigger('click');
                                
        this.createModel(arguments, this.fetchList);
    },
});