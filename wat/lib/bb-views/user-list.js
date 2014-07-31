var UserListView = ListView.extend({
    listTemplateName: 'list-users',
    
    sortedAscUrl: 'json/list_users.json',
    
    sortedDescUrl: 'json/list_users_inv.json',
    
    breadcrumbs: {
        'screen': 'home',
        'link': '#/home',
        'next': {
            'screen': 'users_list'
        }
    },
    
    filters: [
        {
            'name': 'free_search',
            'type': 'text',
            'label': 'tFilter.search_by_name'
        }
    ],

    initialize: function (params) {
        this.collection = new Users();
        
        this.setColumns();
        this.setSelectedActions();
        this.setListActionButton();

        ListView.prototype.initialize.apply(this, [params]);
    },
    
    setColumns: function () {
        this.columns = [
            {
                'name': 'checks',
                'display': true
            },
            {
                'name': 'info',
                'display': true
            },
            {
                'name': 'id',
                'display': true
            },
            {
                'name': 'name',
                'display': true
            },
            {
                'name': 'started_vms',
                'display': true
            },
            {
                'name': 'Office',
                'display': true
            },
            {
                'name': 'Table',
                'display': true
            }
        ];
    },
    
    setSelectedActions: function () {
        this.selectedActions = [
            {
                'value': 'block',
                'text': 'tSelect.block'
            },
            {
                'value': 'unblock',
                'text': 'tSelect.unblock'
            },
            {
                'value': 'disconnect_all',
                'text': 'tSelect.disconnect_from_all_vms'
            },
            {
                'value': 'delete',
                'text': 'tSelect.delete'
            }
        ];
    },
    
    setListActionButton: function () {
        this.listActionButton = {
            'name': 'new_item_button',
            'value': 'tButton.new_user',
            'link': '#'
        }
    },
});