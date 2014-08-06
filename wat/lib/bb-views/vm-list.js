var VMListView = ListView.extend({  
    listTemplateName: 'list-vms',
    editorTemplateName: 'creator-vm',
    sortedAscUrl: 'json/list_vms.json',
    sortedDescUrl: 'json/list_vms_inv.json',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#/home',
        'next': {
            'screen': 'Virtual machine list'
        }
    },
    
    formFilters: [
        {
            'name': 'name',
            'filterField': 'name',
            'type': 'text',
            'label': 'Search by name',
            'mobile': true
        },
        {
            'name': 'state',
            'filterField': 'state',
            'type': 'select',
            'label': 'State',
            'class': 'chosen-single',
            'options': [
                {
                    'value': -1,
                    'text': 'All',
                    'selected': true
                },
                {
                    'value': 'running',
                    'text': 'Running',
                    'selected': false
                },
                {
                    'value': 'stopped',
                    'text': 'Stopped',
                    'selected': false
                }
                        ]
        },
        {
            'name': 'user',
            'filterField': 'user_id',
            'type': 'select',
            'label': 'User',
            'class': 'chosen-advanced',
            'fillable': true,
            'options': [
                {
                    'value': -1,
                    'text': 'All',
                    'selected': true
                }
                        ]
        },
        {
            'name': 'osf',
            'filterField': 'osf_id',
            'type': 'select',
            'label': 'OS Flavour',
            'class': 'chosen-advanced',
            'fillable': true,
            'options': [
                {
                    'value': -1,
                    'text': 'All',
                    'selected': true
                }
                        ]
        },
        {
            'name': 'host',
            'filterField': 'host_id',
            'type': 'select',
            'label': 'Node',
            'class': 'chosen-advanced',
            'fillable': true,
            'options': [
                {
                    'value': -1,
                    'text': 'All',
                    'selected': true
                }
                        ]
        }
    ],
    
    initialize: function (params) {
        if(params === undefined) {
            params = {};
        }
        params.blocked = params.elementsBlock || this.elementsBlock;
        params.offset = this.elementsOffset;
        
        this.collection = new VMs(params);
        
        this.setColumns();
        this.setSelectedActions();
        this.setListActionButton();
        
        // Extend the common lists events
        this.events = _.extend(this.events, this.eventsVMs);

        ListView.prototype.initialize.apply(this, [params]);
    },
    
    eventsVMs: {
        'click [name="new_vm_button"]': 'newElement'
    },
    
    editorDialogTitle: function () {
        return $.i18n.t('New Virtual machine');
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
                'name': 'OSF / Tag',
                'display': true
            }
        ];
    },
    
    setSelectedActions: function () {
        this.selectedActions = [
            {
                'value': 'start',
                'text': 'Start'
            },
            {
                'value': 'stop',
                'text': 'Stop'
            },
            {
                'value': 'block',
                'text': 'Block'
            },
            {
                'value': 'unblock',
                'text': 'Unblock'
            },
            {
                'value': 'disconnect',
                'text': 'Disconnect user'
            },
            {
                'value': 'delete',
                'text': 'Delete'
            }
        ];
    },
    
    setListActionButton: function () {
        this.listActionButton = {
            'name': 'new_vm_button',
            'value': 'New Virtual machine',
            'link': 'javascript:',
            'icon': ''
        }
    },
    
    newElement: function () {
        this.model = new VM();
        this.editElement();
    }
});