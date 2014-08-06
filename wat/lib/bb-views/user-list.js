var UserListView = ListView.extend({
    listTemplateName: 'list-users',
    editorTemplateName: 'creator-user',
    sortedAscUrl: 'json/list_users.json',
    sortedDescUrl: 'json/list_users_inv.json',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#/home',
        'next': {
            'screen': 'User list'
        }
    },
    
    formFilters: [
        {
            'name': 'name',
            'filterField': 'name',
            'type': 'text',
            'label': 'Search by name',
            'mobile': true
        }   ,     
        {
            'name': 'world',
            'filterField': 'world',
            'type': 'text',
            'label': 'world',
            'noTranslatable': true
        }
    ],

    initialize: function (params) {
        if(params === undefined) {
            params = {};
        }
        params.blocked = params.elementsBlock || this.elementsBlock;
        params.offset = this.elementsOffset;
        
        this.collection = new Users(params);
        
        this.setColumns();
        this.setSelectedActions();
        this.setListActionButton();
        
        // Extend the common lists events
        this.events = _.extend(this.events, this.eventsUsers);

        ListView.prototype.initialize.apply(this, [params]);
    },
    
    eventsUsers: {
        'click [name="new_user_button"]': 'newElement'
    },
    
    editorDialogTitle: function () {
        return $.i18n.t('New user');
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
                'name': 'world',
                'display': true,
                'noTranslatable': true
            }
        ];
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
                'value': 'disconnect_all',
                'text': 'Disconnect from all VMs'
            },
            {
                'value': 'delete',
                'text': 'Delete'
            }
        ];
    },
    
    setListActionButton: function () {
        this.listActionButton = {
            'name': 'new_user_button',
            'value': 'New user',
            'link': 'javascript:'
        }
    },
    
    newElement: function () {
        this.model = new User();
        this.editElement();
    }
});