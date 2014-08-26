Wat.Views.VMListView = Wat.Views.ListView.extend({  
    listTemplateName: 'list-vms',
    editorTemplateName: 'creator-vm',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#/home',
        'next': {
            'screen': 'Virtual machine list'
        }
    },
    
    initialize: function (params) {   
        this.collection = new Wat.Collections.VMs(params);
        
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
                'name': 'node',
                'display': true
            },        
            {
                'name': 'user',
                'display': true
            },        
            {
                'name': 'osf/tag',
                'display': true
            },        
            {
                'name': 'tag',
                'display': false
            }
        ];
        
        Wat.Views.ListView.prototype.setColumns.apply(this);
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
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.VM();
        
        this.dialogConf.title = $.i18n.t('New Virtual machine');
        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
        
        // Fill OSF select on virtual machines creation form
        var params = {
            'action': 'user_tiny_list',
            'selectedId': '',
            'controlName': 'user_id'
        };

        Wat.A.fillSelect(params);  
        
        Wat.I.chosenElement('[name="user_id"]', 'advanced100');
        
        // Fill OSF select on virtual machines creation form
        var params = {
            'action': 'osf_tiny_list',
            'selectedId': '',
            'controlName': 'osf_id'
        };

        Wat.A.fillSelect(params);  
        
        Wat.I.chosenElement('[name="osf_id"]', 'single100');
        
        // Fill DI Tags select on virtual machines creation form
        var params = {
            'action': 'tag_tiny_list',
            'selectedId': '',
            'controlName': 'di_tag',
            'filters': {
                'osf_id': $('[name="osf_id"]').val()
            },
            'nameAsId': true
        };

        Wat.A.fillSelect(params);
        
        Wat.I.chosenElement('[name="di_tag"]', 'single100');
    },
    
    createElement: function () {
        Wat.Views.ListView.prototype.createElement.apply(this);
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');

        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        var user_id = context.find('select[name="user_id"]').val();
        var osf_id = context.find('select[name="osf_id"]').val();
        
        var arguments = {
            "properties" : properties.create,
            "blocked": blocked ? 1 : 0,
            "user_id": user_id,
            "osf_id": osf_id
        };
        
        var di_tag = context.find('select[name="di_tag"]').val();
        
        if (di_tag) {
            arguments.di_tag = di_tag;
        }
        
        var name = context.find('input[name="name"]').val();
        if (!name) {
            console.error('name empty');
        }
        else {
            arguments["name"] = name;
        }
                
        console.log(arguments);
                
        this.createModel(arguments);
    },
    
    startVM: function (filters) {        
        var messages = {
            'success': 'Successfully started',
            'error': 'Error starting VM'
        }
        
        Wat.A.performAction ('vm_start', {}, filters, messages, this.fetchList, this);
    },
    
    stopVM: function (filters) {        
        var messages = {
            'success': 'Successfully stopped',
            'error': 'Error stopping VM'
        }
        
        Wat.A.performAction ('vm_stop', {}, filters, messages, this.fetchList, this);
    },
    
    disconnectVMUser: function (filters) {        
        var messages = {
            'success': 'User successfully disconnected from VM',
            'error': 'Error disconnecting user from VM'
        }
        
        Wat.A.performAction ('vm_user_disconnect', {}, filters, messages, this.fetchList, this);
    }
});