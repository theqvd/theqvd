var UserListView = ListView.extend({
    config: {
        'new_item_text': 'tButton.new_user'
    },
    
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
        
        this.columns = this.getColumns();
        this.selectedActions = this.getSelectedActions();

        ListView.prototype.initialize.apply(this, [params]);
    },
    
    getColumns: function () {
        return [
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
    
    getSelectedActions: function () {
        return [
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
    }
});