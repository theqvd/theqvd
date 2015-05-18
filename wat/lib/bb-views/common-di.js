// Common lib for DI views (list and details)
Wat.Common.DIViews = {
    // Check if any running VM has suffered changes with a DI update
    checkMachinesChanges: function (that) {
        // Get stored tag changes depending on if the view is embeded or not
        if (Wat.CurrentView.tagChanges != undefined) {
            var tagChanges = Wat.CurrentView.tagChanges;
            delete Wat.CurrentView.tagChanges;
        }
        else if (Wat.CurrentView.sideView2.tagChanges != undefined) {
            var tagChanges = Wat.CurrentView.sideView2.tagChanges;
            delete Wat.CurrentView.sideView2.tagChanges;
        }
        
        // The procedence point of this function can be a disk image update action or a direct call. 
        // The second one occurs when create a disk image and this function is called after close websocket operations        
        // For the first one, we will check the operation status, in second case, we won't check anything
        if (that.retrievedData) {
            var success = that.retrievedData.status == STATUS_SUCCESS;
        }
        else {
            var success = true;
        }
        
        if (success && tagChanges && Wat.C.checkACL('vm.update.expiration')) {
            var tagChanges = tagChanges["create"].concat(tagChanges["delete"]);
            
            if (tagChanges.length > 0) {
                var tagCond = []
                $.each(tagChanges, function (iTag, tag) {
                    tagCond.push("di_tag");
                    tagCond.push(tag);
                });
                
                var vmFilters = {
                    "-or": tagCond, 
                    "state": "running",
                    "osf_id": Wat.CurrentView.model.get('osf_id')
                };
                
                Wat.A.performAction('vm_get_list', {}, vmFilters, {}, Wat.CurrentView.warnMachinesChanges, this);
            }
        }
        else {
            switch (Wat.CurrentView.viewKind) {
                case 'details':
                    Wat.CurrentView.fetchDetails();
                    break;
                case 'list':
                    Wat.CurrentView.fetchList();
                    break;
            }
        }
    },
    
    // If the VMs changes checking is positive, open dialog to warn to administrator about it and give him the option of set expiration date or directly stop the VM
    warnMachinesChanges: function (that) {
        if (that.retrievedData.status == STATUS_SUCCESS && that.retrievedData.total > 0) {
            var affectedVMs = [];
            $.each(that.retrievedData.rows, function (iVm, vm) {
                // If the possible affected VM have the same DI assigned and DI in use, avoid to warn about it
                // This checking is done in this way because API doesnt support comparison between two element fields
                if (vm.di_id == vm.di_id_in_use) {
                    return;
                }
                
                affectedVMs.push(vm);
            });
            
            if (affectedVMs.length > 0) {        
                Wat.CurrentView.openEditAffectedVMsDialog(affectedVMs);
            }
        }
        
        switch (Wat.CurrentView.viewKind) {
            case 'details':
                Wat.CurrentView.fetchDetails();
                break;
            case 'list':
                Wat.CurrentView.fetchList();
                break;
        }
    },
    
    openEditAffectedVMsDialog: function (affectedVMs) {
        var that = this;
        
        this.dialogConf.title = $.i18n.t('There are VMs affected by the latest action');

        this.templateEditor = Wat.TPL.editorAffectedVM;
        
        this.dialogConf.buttons = {
            Cancel: function () {
                $(this).dialog('close');
            },
            Update: function () {
                that.dialog = $(this);
                var affectedVMsIds = [];
                $.each($('.affectedVMCheck:checked'), function (iAVM, aVm) {
                      affectedVMsIds.push($(aVm).val());
                });
                
                if (affectedVMsIds.length == 0) {
                    that.dialog.dialog('close');
                    Wat.I.showMessage({message: 'No items were selected - Nothing to do', messageType: 'info'});
                    return;
                }
                
                var filters = {
                    "id": affectedVMsIds
                };
                
                args = {};
                if (Wat.C.checkACL('vm.update.expiration')) {
                    var expiration_soft = that.dialog.find('input[name="expiration_soft"]').val();
                    var expiration_hard = that.dialog.find('input[name="expiration_hard"]').val();

                    if (expiration_soft != undefined) {
                        args['expiration_soft'] = expiration_soft;
                    }

                    if (expiration_hard != undefined) {
                        args['expiration_hard'] = expiration_hard;
                    }
                }
                
                messages = {
                    'error': i18n.t('Error updating'), 
                    'success': i18n.t('Successfully updated')
                };
                
                Wat.A.performAction ('vm_update', args, filters, messages, function (that) {
                    that.dialog.dialog('close');
                }, that);
            }
        };
        
        this.dialogConf.button1Class = 'fa fa-ban';
        this.dialogConf.button2Class = 'fa fa-save';
        
        this.enabledProperties = false;
        this.dialogConf.fillCallback = this.fillEditor;
        
        this.editorElement ();

        // Add specific parts of editor to dialog
        var template = _.template(
                    Wat.TPL.editorAffectedVMList, {
                        affectedVMs: affectedVMs
                    }
                );

        $('.bb-affected-vms-list').html(template);
    },
}