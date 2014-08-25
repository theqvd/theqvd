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
            'filterField': 'disk_image',
            'type': 'text',
            'label': 'Search by disk image',
            'mobile': true
        },
        {
            'name': 'osf',
            'filterField': 'osf_id',
            'type': 'select',
            'label': 'OS Flavour',
            'class': 'chosen-advanced',
            'fillable': true,
            'mobile': true
        }
    ],

    initialize: function (params) {
        this.collection = new Wat.Collections.DIs(params);
        
        this.setColumns();
        this.setSelectedActions();
        this.setListActionButton();
        
        this.extendEvents(this.eventsDIs);

        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    eventsDIs: {
        'change input[name="di_default"]': 'setDefault'
    },
    
    setDefault: function (e) {
        var di_id = $(e.target).attr('data-di_id');
        
        var filters = {"id": di_id};
        var arguments = {
            "tags": {
                'create': ['default'],
            },
        };
        
        var auxModel = new Wat.Models.DI();
        
        this.updateModel(arguments, filters, this.fetchList, auxModel);
    },
    
    fetchFilters: function () {
        Wat.Views.ListView.prototype.fetchFilters.apply(this);

        // As the osf filter in DI list hasn't all option, we trigger the change once it is loaded to perform the filtering
        $('.filter-control [name="osf"]').trigger('change');
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
                'name': 'disk_image',
                'display': true
            },
            {
                'name': 'version',
                'display': true
            },
            {
                'name': 'osf',
                'display': false
            },
            {
                'name': 'default',
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
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.DI();
        this.dialogConf.title = $.i18n.t('New Disk image');

        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
        
        // Configure tags inputs
        Wat.I.tagsInputConfiguration();
        
        // Fill OSF select on virtual machines creation form
        var params = {
            'action': 'osf_tiny_list',
            'selectedId': $('.' + this.cid + ' .filter select[name="osf"]').val(),
            'controlName': 'osf_id'
        };
        
        Wat.A.fillSelect(params);  
        
        Wat.I.chosenElement('[name="osf_id"]', 'single100');
    },
    
    createElement: function () {
        Wat.Views.ListView.prototype.createElement.apply(this);
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');

        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        var osf_id = context.find('select[name="osf_id"]').val();
        
        var arguments = {
            "properties" : properties.create,
            "blocked": blocked ? 1 : 0,
            "osf_id": osf_id
        };
        
        var disk_image = context.find('input[name="disk_image"]').val();
        if (!disk_image) {
            console.error('disk image empty');
        }
        else {
            arguments["disk_image"] = disk_image;
        }   
        
        var version = context.find('input[name="version"]').val();
        if (version) {
            arguments["version"] = version;
        }
        
        var tags = context.find('input[name="tags"]').val();
        var def = context.find('input[name="default"][value=1]').is(':checked');
        
        // If we set default add this tag
        if (def) {
            tags += ',default';
        }
        
        arguments.tags = tags ? tags.split(',') : [];
                        
        this.createModel(arguments);
    }
});