Wat.Views.RoleListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'roles',
    qvdObj: 'role',
    
    initialize: function (params) {        
        if (params.filters == undefined) {
            params.filters = {};
        }
        
        params.filters.internal = false;
        
        this.collection = new Wat.Collections.Roles(params);

        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // Enlarge render list function to load dinamically column of number of ACLs of each role
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
        
        var arguments = {
            "name": name
        };
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            arguments["description"] = description;
        }
        
        if (Wat.C.isSuperadmin) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            arguments['tenant_id'] = tenant_id;
        }
        
        // Go to first page and order by ID desc to got the last created element in first place
        this.collection.sort = {"field": "id", "order": "-desc"};
        $('div.pagination>.first').trigger('click');
                                
        this.createModel(arguments, this.fetchList);
    },
});