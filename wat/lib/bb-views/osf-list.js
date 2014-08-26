Wat.Views.OSFListView = Wat.Views.ListView.extend({
    listTemplateName: 'list-osf',
    editorTemplateName: 'creator-osf',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#/home',
        'next': {
            'screen': 'OSF list'
        }
    },

    initialize: function (params) {
        this.collection = new Wat.Collections.OSFs(params);
        
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
                },
                {
                    'name': 'di',
                    'filterField': 'di_id',
                    'type': 'select',
                    'label': 'Disk image',
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
                'name': 'id',
                'display': true
            },
            {
                'name': 'name',
                'display': true
            },
            {
                'name': 'overlay',
                'display': true
            },
            {
                'name': 'memory',
                'display': true
            },
            {
                'name': 'user_storage',
                'display': true
            },
            {
                'name': 'dis',
                'display': true
            },
            {
                'name': 'vms',
                'display': true
            }
        ];
        
        Wat.Views.ListView.prototype.setColumns.apply(this);
    },
    
    setSelectedActions: function () {
        this.selectedActions = [
            {
                'value': 'delete',
                'text': 'Delete'
            }
        ];
    },
    
    setListActionButton: function () {
        this.listActionButton = {
            'name': 'new_osf_button',
            'value': 'New OS Flavour',
            'link': 'javascript:'
        }
    },
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.OSF();
        this.dialogConf.title = $.i18n.t('New OS Flavour');

        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
    },
    
    createElement: function () {
        Wat.Views.ListView.prototype.createElement.apply(this);
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();        
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        
        arguments = {
            properties: properties.create,
            name: name,
            memory: memory || 256,
            //user_storage: user_storage
        };
        
        var name = context.find('input[name="name"]').val();
        if (!name) {
            console.error('name empty');
        }
        else {
            arguments["name"] = name;
        }
                        
        this.createModel(arguments);
    }
});