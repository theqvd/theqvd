Wat.Views.UserListView = Wat.Views.ListView.extend({
    listTemplateName: 'list-users',
    editorTemplateName: 'creator-user',
    
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
        },     
        {
            'name': 'world',
            'filterField': 'world',
            'type': 'text',
            'label': 'world',
            'noTranslatable': true
        },     
        {
            'name': 'sex',
            'filterField': 'sex',
            'type': 'text',
            'label': 'sex',
            'noTranslatable': true
        }
    ],

    initialize: function (params) {
        this.collection = new Wat.Collections.Users(params);
        
        this.setColumns();
        this.setSelectedActions();
        this.setListActionButton();
        
        this.extendEvents(this.eventsUsers);

        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    eventsUsers: {
        
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
            },
            {
                'name': 'sex',
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
            'value': 'New User',
            'link': 'javascript:'
        }
    },
    
    newElement: function (e) {
        this.model = new Wat.Models.User();
        this.dialogConf.title = $.i18n.t('New user');
        Wat.Views.ListView.prototype.newElement.apply(this, [e]);
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
        
        var password = context.find('input[name="password"]').val();
        var password2 = context.find('input[name="password2"]').val();
        if (!password || !password2) {
            console.error('password empty');
        }
        else if (password != password2) {
            console.error('password missmatch');
        }
        else {
            arguments['password'] = password;
        }
                
        console.log(arguments);
                
        this.createModel(arguments);
    }
});