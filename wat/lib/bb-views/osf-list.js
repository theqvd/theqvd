Wat.Views.OSFListView = Wat.Views.ListView.extend({
    shortName: 'osf',
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