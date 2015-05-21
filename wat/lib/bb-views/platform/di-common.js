// Common lib for DI views (list and details)
Wat.Common.BySection.di = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = {
            editorAffectedVM: {
                name: 'editor/affected-vms'
            },
            editorAffectedVMList: {
                name: 'editor/affected-vms-list'
            }
        };
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    updateElement: function (dialog, that) {
        var that = that || this;
        that.id = that.id || that.selectedItems[0];
        that.model = that.model || that.collection.where({id: that.selectedItems[0]})[0];
        
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(that, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = that.properties;
                
        var context = $('.' + that.cid + '.editor-container');
                        
        var tags = context.find('input[name="tags"]').val();
        var newTags = tags && Wat.C.checkACL('di.update.tags') ? tags.split(',') : [];

        var def = context.find('input[name="default"][value=1]').is(':checked');
        
        // If we set default (only if the DI wasn't default), add this tag
        if (def && !that.model.get('default') && Wat.C.checkACL('di.update.default')) {
            newTags.push('default');
        }
                
        var baseTags = that.model.attributes.tags ? that.model.attributes.tags.split(',') : [];
        var keepedTags = _.intersection(baseTags, newTags);
        
        var createdTags = _.difference(newTags, keepedTags);
        var deletedTags = _.difference(baseTags, keepedTags);
        
        var filters = {"id": that.id};
        var arguments = {};
        
        if (Wat.C.checkACL('di.update.tags') || Wat.C.checkACL('di.update.default')) {
            arguments['__tags_changes__'] = {
                'create': createdTags,
                'delete': deletedTags
            };
        }
        
        if (properties.delete.length > 0 || !$.isEmptyObject(properties.set)) {
            arguments["__properties_changes__"] = properties;
        }
        
        this.tagChanges = arguments['__tags_changes__'];
        
        that.updateModel(arguments, filters, that.checkMachinesChanges);
    },
    
    openEditElementDialog: function(e) {
        this.model = this.model || this.collection.where({id: this.selectedItems[0]})[0];
        
        this.dialogConf.title = $.i18n.t('Disk image') + ": " + this.model.get('disk_image');

        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        // Configure tags inputs
        Wat.I.tagsInputConfiguration();
    },
    
    // Check if any running VM has suffered changes with a DI update
    checkMachinesChanges: function (that) {
        var realView = Wat.I.getRealView(that);

        // Get stored tag changes depending on if the view is embeded or not
        var tagChanges = realView.tagChanges;
        delete realView.tagChanges;
        
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
                
                Wat.A.performAction('vm_get_list', {}, vmFilters, {}, that.warnMachinesChanges, that);
            }
        }
        else {
            switch (realView.viewKind) {
                case 'details':
                    realView.fetchDetails();
                    break;
                case 'list':
                    realView.fetchList();
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
                that.openEditAffectedVMsDialog(affectedVMs);
            }
        }
        
        var realView = Wat.I.getRealView(that);
        
        switch (realView.viewKind) {
            case 'details':
                realView.fetchDetails();
                break;
            case 'list':
                realView.fetchList();
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