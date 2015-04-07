Wat.Views.LogListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'log',
    qvdObj: 'log',

    
    initialize: function (params) {
        
        params.sort = {
            "field": "id",
            "order": "-desc"
        }
        
        this.collection = new Wat.Collections.Logs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    events: {
    },
    
    renderList: function () {
        Wat.Views.ListView.prototype.renderList.apply(this, []);

        if (Wat.C.isSuperadmin()) {
            // If tenant select is defined, we wait to be loaded to load administrators select
            Wat.A.performAction ('tenant_tiny_list', {}, {}, {}, function(e) {
                
                var fillTenantAdmins = function (tenants) {
                    if (tenants.length > 0) {
                        var tenant = tenants.shift();
                        
                        var params = {
                            'action': 'admin_tiny_list',
                            'selectedId': '',
                            'controlName': 'admin',
                            'filters': {
                                "tenant_id": tenant.id
                            },
                            'order_by': {
                                "field": ["name"],
                                "order": "-asc"
                            },
                            'group': tenant.name,
                            'chosenType': 'advanced100'
                        };

                        Wat.A.fillSelect(params, function () {
                            fillTenantAdmins(tenants);
                        });
                    }
                };
                
                fillTenantAdmins(e.retrievedData.rows);
            }, this);

        }
        else {
            // If administrator is not superadmin, administrators combo will be charged normally
            var params = {
                'action': 'admin_tiny_list',
                'selectedId': '',
                'controlName': 'admin',
                'order_by': {
                    "field": ["name"],
                    "order": "-asc"
                },
                'chosenType': 'advanced100'
            };

            Wat.A.fillSelect(params, function () {
                fillTenantAdmins(tenants);
            });
        }
    },
});