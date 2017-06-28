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
});