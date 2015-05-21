Wat.Views.VMDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'vm',
    liveFields: ['state', 'user_state', 'ip', 'host_id', 'host_name', 'ssh_port', 'vnc_port', 'serial_port', 'di_id_in_use', 'di_name_in_use', 'di_version_in_use'],

    relatedDoc: {
        image_update: "Images update guide"
    },
    
    initialize: function (params) {
        this.model = new Wat.Models.VM(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    events: {
        'click .js-execution-params-button': 'showExecutionParams'
    },
    
    showExecutionParams: function () {
        $('.js-execution-params-button-row').hide();
        $('.js-execution-params').show();
    },
    
    renderSide: function () {
        // No side rendered
        if (this.checkSide({'vm.see.state': '.js-side-component1', 'vm.see.log': '.js-side-component2'}) === false) {
            return;
        }
        
        var sideContainer = '.' + this.cid + ' .bb-details-side2';

        // Render Related log list on side
        var params = this.getSideLogParams(sideContainer);

        this.sideViews.push(new Wat.Views.LogListView(params));
        
        this.renderLogGraph(params);
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
        
        // Toggle controls for new password
        this.bindEvent('change', 'input[name="change_password"]', this.vmEditorBinds.toggleNewPassword);
    },
    
    vmEditorBinds: {
        toggleNewPassword: function () {
            $('.new_password_row').toggle();
        }
    },
    
    startVM: function () {
        var messages = {
            'success': 'Successfully required to be started',
            'error': 'Error starting Virtual machine'
        }
        
        Wat.A.performAction ('vm_start', {}, {id: this.elementId}, messages, function(){
            // After start/stop VM render side to update log
            Wat.CurrentView.renderSide();
        }, this);
    },
    
    stopVM: function () {
        var messages = {
            'success': 'Stop request successfully performed',
            'error': 'Error stopping Virtual machine'
        }
        
        Wat.A.performAction ('vm_stop', {}, {id: this.elementId}, messages, function(){
            // After start/stop VM render side to update log
            Wat.CurrentView.renderSide();
        }, this);
    },
    
    
    restartVM: function () {   
        Wat.CurrentView.restarting = true;
        Wat.stopVM();
    },  
});