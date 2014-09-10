Wat.Views.VMListView = Wat.Views.ListView.extend({  
    qvdObj: 'vm',
    listTemplateName: 'list-vms',
    editorTemplateName: 'creator-vm',
        
    initialize: function (params) {   
        this.collection = new Wat.Collections.VMs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {},
    
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
            'selectedId': 'default',
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
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');

        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        var user_id = context.find('select[name="user_id"]').val();
        var osf_id = context.find('select[name="osf_id"]').val();
        
        var arguments = {
            "propertyChanges" : properties.create,
            "blocked": blocked ? 1 : 0,
            "user_id": user_id,
            "osf_id": osf_id
        };
        
        var di_tag = context.find('select[name="di_tag"]').val();
        
        if (di_tag) {
            arguments.di_tag = di_tag;
        }
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            arguments["name"] = name;
        }
                                
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