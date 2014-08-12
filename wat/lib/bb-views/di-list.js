Wat.Views.DIListView = Wat.Views.ListView.extend({
    listTemplateName: 'list-di',
    editorTemplateName: 'creator-di',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#/home',
        'next': {
            'screen': 'DI list'
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
            'name': 'osf',
            'filterField': 'osf_id',
            'type': 'select',
            'label': 'OS Flavour',
            'class': 'chosen-advanced',
            'fillable': true
        }
    ],

    initialize: function (params) {
        if(params === undefined) {
            params = {};
        }
        params.blocked = params.elementsBlock || this.elementsBlock;
        params.offset = this.elementsOffset;
        
        this.collection = new Wat.Collections.DIs(params);
        
        this.setColumns();
        this.setSelectedActions();
        this.setListActionButton();
        
        this.extendEvents(this.eventsDIs);

        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    eventsDIs: {
        'click [name="new_di_button"]': 'newElement'
    },
    
    editorDialogTitle: function () {
        return $.i18n.t('New Disk image');
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
                'name': 'disk_image',
                'display': true
            },
            {
                'name': 'version',
                'display': true
            },
            {
                'name': 'osf',
                'display': true
            },
            {
                'name': 'default',
                'display': true
            },
            {
                'name': 'head',
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
            'name': 'new_di_button',
            'value': 'New Disk image',
            'link': 'javascript:'
        }
    },
    
    newElement: function () {
        this.model = new Wat.Models.DI();
        this.editElement();
    }
});