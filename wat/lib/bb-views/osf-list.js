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
    
    formFilters: [
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
    ],

    initialize: function (params) {
        this.collection = new Wat.Collections.OSFs(params);
        
        this.setColumns();
        this.setSelectedActions();
        this.setListActionButton();
        
        this.extendEvents(this.eventsOSFs);

        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    eventsOSFs: {
        
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
                'name': '#dis',
                'display': true
            },
            {
                'name': 'vms',
                'display': true
            }
        ];
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
    
    newElement: function (e) {
        this.model = new Wat.Models.OSF();
        this.dialogConf.title = $.i18n.t('New OS Flavour');

        Wat.Views.ListView.prototype.newElement.apply(this, [e]);
    }
});