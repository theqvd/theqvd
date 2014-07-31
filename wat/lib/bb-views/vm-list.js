var VMListView = ListView.extend({  
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
    
    setSelectedActions: function () {
        this.selectedActions = [
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
    },
    
    setListActionButton: function () {
        this.listActionButton = {
            'name': 'new_item_button',
            'value': 'tButton.new_vm',
            'link': '#',
            'icon': ''
        }
    },
});