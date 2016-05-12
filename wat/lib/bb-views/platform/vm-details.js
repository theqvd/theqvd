Wat.Views.VMDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'vm',
    liveFields: ['state', 'user_state', 'ip', 'ip_in_use', 'host_id', 'host_name', 'ssh_port', 'vnc_port', 'serial_port', 'di_id_in_use', 'di_name_in_use', 'di_version_in_use'],

    relatedDoc: {
        image_update: "Images update guide"
    },
    
    initialize: function (params) {
        this.model = new Wat.Models.VM(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    events: {
        'click .js-execution-params-button': 'showExecutionParams',
        'click .js-button-spy-vm': 'spyVM'
    },
    
    showExecutionParams: function () {
        $('.js-execution-params-button-row').hide();
        $('.js-execution-params').show();
    },
    
    renderSide: function () {
        // No side rendered
        var sideCheck = this.checkSide({'vm.see.state': '.js-side-component1', 'vm.see.log': '.js-side-component2'});
        if (sideCheck === false) {
            return;
        }
        
        if (sideCheck['vm.see.log']) { 
        var sideContainer = '.' + this.cid + ' .bb-details-side2';

        // Render Related log list on side
        var params = this.getSideLogParams(sideContainer);

        this.sideViews.push(new Wat.Views.LogListView(params));
        
        this.renderLogGraph(params);
        }
        
        
        if (sideCheck['vm.see.state']) { 
        // Execution state animation
        var that = this;
        var oldState = '';
        var filledDot = 1;
        
        this.executionAnimationInterval = setInterval(function() {
            if (oldState != that.model.get('state')) {
                filledDot = 1;
                oldState = that.model.get('state');
            }
            
            switch(that.model.get('state')) {
                case "running":
                        $('.js-vmst-dot').removeClass('fa-dot-circle-o');
                        $('.js-vmst-dot').removeClass('fa-circle-o');
                        $('.js-vmst-dot').addClass('fa-circle');
                    break;
                case "starting":
                    $.each($('.js-vmst-dot'), function (iDot, dot) {
                        if (iDot >= (filledDot - 1) && iDot <= (filledDot + 1)) {
                            $(dot).addClass('fa-chevron-right');
                            $(dot).removeClass('fa-circle-o');
                            $(dot).removeClass('fa-circle');
                        }
                        else {
                            $(dot).removeClass('fa-chevron-right');
                            $(dot).addClass('fa-circle-o');
                            $(dot).removeClass('fa-circle');
                        }
                    });

                    filledDot++;
                    if (filledDot == $('.js-vmst-dot').length) {
                        filledDot = 0;
                    }
                    break;
                case "stopping":
                    $.each($('.js-vmst-dot'), function (iDot, dot) {
                        if (iDot >= (filledDot - 1) && iDot <= (filledDot + 1)) {
                            $(dot).addClass('fa-chevron-left');
                            $(dot).removeClass('fa-circle');
                            $(dot).removeClass('fa-circle-o');
                        }
                        else {
                            $(dot).addClass('fa-circle');
                            $(dot).removeClass('fa-chevron-left');
                            $(dot).removeClass('fa-circle-o');
                        }
                    });

                    filledDot--;
                    if (filledDot < 0) {
                        filledDot = $('.js-vmst-dot').length - 1;
                    }
                    break;
                case "stopped":
                        $('.js-vmst-dot').removeClass('fa-circle');
                        $('.js-vmst-dot').removeClass('fa-dot-circle-o');
                        $('.js-vmst-dot').addClass('fa-circle-o');
                    break;
            }
        }, 100);
        }
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