Wat.Views.VMListView = Wat.Views.ListView.extend({  
    qvdObj: 'vm',
    viewMode: 'grid',
    liveFields: ['state', 'user_state', 'ip', 'host_id', 'host_name', 'ssh_port', 'vnc_port', 'serial_port'],
    
    relatedDoc: {
        image_update: "Images update guide",
        full_vm_creation: "Create a virtual machine from scratch",
    },
    
    initialize: function (params) {  
        this.collection = new Wat.Collections.VMs(params);

        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {
        'click .js-change-viewmode': 'changeViewMode',
        'mouseover .js-vm-screenshot': 'overScreenshot',
        'mouseover .js-vm-screenshot>*': 'overScreenshotContent',
        'mouseout .js-vm-screenshot': 'outScreenshot',
        'mouseout .js-vm-screenshot>*': 'outScreenshotContent',
    },
    
    overScreenshot: function (e) {
        $(e.target).find('.js-connect-btn').css('opacity', '1');
    },    
    
    outScreenshot: function (e) {
        $(e.target).find('.js-connect-btn').css('opacity', '0.5');
    },
    
    overScreenshotContent: function (e) {
        $(e.target).parent().find('.js-connect-btn').css('opacity', '1');
    },    
    
    outScreenshotContent: function (e) {
        $(e.target).parent().find('.js-connect-btn').css('opacity', '0.5');
    },
    
    startVM: function (filters) {        
        var messages = {
            'success': 'Successfully required to be started',
            'error': 'Error starting Virtual machine'
        }
        
        Wat.A.performAction ('vm_start', {}, filters, messages, function(){}, this);
    },
    
    // Different functions applyed to the selected items in list view
    applyStart: function (that) {
        that.startVM (that.applyFilters);
        that.resetSelectedItems ();
    },
    
    applyStop: function (that) {
        that.stopVM (that.applyFilters);
        that.resetSelectedItems ();
    },
    
    applyDisconnect: function (that) {
        that.disconnectVMUser (that.applyFilters);
        that.resetSelectedItems ();
    },
    
});