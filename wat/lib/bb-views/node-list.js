Wat.Views.NodeListView = Wat.Views.ListView.extend({
    listTemplateName: 'list-nodes',
    editorTemplateName: 'creator-node',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#/home',
        'next': {
            'screen': 'Node list'
        }
    },
    
    initialize: function (params) { 
        this.collection = new Wat.Collections.Nodes(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {
        
    },
    
    setFilters: function() {
        this.formFilters = [
                {
                    'name': 'name',
                    'filterField': 'name',
                    'type': 'text',
                    'label': 'Search by name',
                    'mobile': true
                },
                {
                    'name': 'vm',
                    'filterField': 'vm_id',
                    'type': 'select',
                    'label': 'Virtual machine',
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
            ];
        
        Wat.Views.ListView.prototype.setFilters.apply(this);
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
                'name': 'state',
                'display': false
            },
            {
                'name': 'address',
                'display': true
            },
            {
                'name': 'vms_connected',
                'display': true
            },
            {
                'name': 'Cosa',
                'display': true
            }
        ];
        
        Wat.Views.ListView.prototype.setColumns.apply(this);
    },
    
    setSelectedActions: function () {
        this.selectedActions = [
            {
                'value': 'block',
                'text': 'Block'
            },
            {
                'value': 'unblock',
                'text': 'Unblock'
            },
            {
                'value': 'stop_all',
                'text': 'Stop all VMs'
            },
            {
                'value': 'delete',
                'text': 'Delete'
            }
        ];
    },
    
    setListActionButton: function () {
        this.listActionButton = {
            'name': 'new_node_button',
            'value': 'New Node',
            'link': 'javascript:'
        }
    },
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.Node();
        this.dialogConf.title = $.i18n.t('New node');
        
        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
    },
    
    createElement: function () {
        Wat.Views.ListView.prototype.createElement.apply(this);
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');

        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        
        var arguments = {
            "properties" : properties.create,
            "blocked": blocked ? 1 : 0
        };
        
        var name = context.find('input[name="name"]').val();
        if (!name) {
            console.error('name empty');
        }
        else {
            arguments["name"] = name;
        }     
        
        var address = context.find('input[name="address"]').val();
        if (!name) {
            console.error('address empty');
        }
        else {
            arguments["address"] = address;
        }
                        
        this.createModel(arguments);
    }
});