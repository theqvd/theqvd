var VMListView = ListView.extend({
    config: {
        'new_item_text': 'tButton.new_vm'
    },
    
    listTemplateName: 'list-vms',
    
    sortedAscUrl: 'json/list_vms.json',
    
    sortedDescUrl: 'json/list_vms_inv.json',
    
    breadcrumbs: {
        'screen': 'home',
        'link': '#/home',
        'next': {
            'screen': 'vms_list'
        }
    },
    
    filters: [
        {
            'name': 'free_search',
            'type': 'text',
            'label': 'tFilter.search_by_name'
        },
        {
            'name': 'state',
            'type': 'select',
            'label': 'tFilter.state',
            'class': 'chosen-single',
            'options': [
                {
                    'value': 'running',
                    'text': 'tSelect.all',
                    'selected': true
                },
                {
                    'value': 'running',
                    'text': 'tSelect.running',
                    'selected': false
                },
                {
                    'value': 'stopped',
                    'text': 'tSelect.stopped',
                    'selected': false
                }
                        ]
        },
        {
            'name': 'user',
            'type': 'select',
            'label': 'tFilter.user',
            'class': 'chosen-advanced',
            'fillable': true,
            'options': [
                {
                    'value': -1,
                    'text': 'tSelect.all',
                    'selected': true
                }
                        ]
        },
        {
            'name': 'osf',
            'type': 'select',
            'label': 'tFilter.osf',
            'class': 'chosen-advanced',
            'fillable': true,
            'options': [
                {
                    'value': -1,
                    'text': 'tSelect.all',
                    'selected': true
                }
                        ]
        },
        {
            'name': 'node',
            'type': 'select',
            'label': 'tFilter.node',
            'class': 'chosen-advanced',
            'fillable': true,
            'options': [
                {
                    'value': -1,
                    'text': 'tSelect.all',
                    'selected': true
                }
                        ]
        }
    ],
    
    initialize: function (params) {
        this.collection = new VMs();
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
                'name': 'node',
                'display': true
            },        
            {
                'name': 'user',
                'display': true
            },        
            {
                'name': 'osf/tag',
                'display': true
            }
        ];
    },
    
    getSelectedActions: function () {
        return [
            {
                'value': 'start',
                'text': 'tSelect.start'
            },
            {
                'value': 'stop',
                'text': 'tSelect.stop'
            },
            {
                'value': 'block',
                'text': 'tSelect.block'
            },
            {
                'value': 'unblock',
                'text': 'tSelect.unblock'
            },
            {
                'value': 'disconnect',
                'text': 'tSelect.disconnect_user'
            },
            {
                'value': 'delete',
                'text': 'tSelect.delete'
            }
        ];
    }
});