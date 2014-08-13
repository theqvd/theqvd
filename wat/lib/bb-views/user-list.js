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
        
        var arguments = {'properties' : properties};
        
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        arguments['name'] = name;
        
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
        
        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        
        arguments['blocked'] = blocked ? 1 : 0;
        
        console.log(arguments);
        return;
        
        var filters = {"id": this.id};
        
        var result = Wat.A.performAction('create_user', filters, arguments);
        
        if (result.status == SUCCESS) {
            this.fetchDetails();
            this.renderSide();

            this.message = 'Successfully updated';
            this.messageType = 'success';
        }
        else {
            this.message = 'Error updating';
            this.messageType = 'error';
        }
        
        dialog.dialog('close');
    }
});