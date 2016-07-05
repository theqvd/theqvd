 Common lib for DI views (list and details)
Up.Common.BySection.di = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = Up.I.T.getTemplateList('commonDI');
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    updateElement: function (dialog, that) {
        var that = that || this;
        
        // If current view is list, use selected ID as update element ID
        if (that.viewKind == 'list') {
            that.id = that.selectedItems[0];
            that.model = that.collection.where({id: that.selectedItems[0]})[0];
        }
        
        var valid = Up.Views.DetailsView.prototype.updateElement.apply(that, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = that.properties;
                
        var context = $('.' + that.cid + '.editor-container');
                        
        var tags = context.find('input[name="tags"]').val();
        var newTags = tags && Up.C.checkACL('di.update.tags') ? tags.split(',') : [];
        var description = context.find('textarea[name="description"]').val();

        var def = context.find('input[name="default"][value=1]').is(':checked');
        
        // If we set default (only if the DI wasn't default), add this tag
        if (def && !that.model.get('default') && Up.C.checkACL('di.update.default')) {
            newTags.push('default');
        }
                
        var baseTags = that.model.attributes.tags ? that.model.attributes.tags.split(',') : [];
        var keepedTags = _.intersection(baseTags, newTags);
        
        var createdTags = _.difference(newTags, keepedTags);
        var deletedTags = _.difference(baseTags, keepedTags);
        
        var filters = {"id": that.id};
        var arguments = {};
        
        if (Up.C.checkACL('di.update.tags') || Up.C.checkACL('di.update.default')) {
            arguments['__tags_changes__'] = {
                'create': createdTags,
                'delete': deletedTags
            };
        }
        
        if (!$.isEmptyObject(properties.set) && Up.C.checkACL('di.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        if (Up.C.checkACL('di.update.description')) {
            arguments["description"] = description;
        }
        
        this.tagChanges = arguments['__tags_changes__'];
        
        that.updateModel(arguments, filters, that.checkMachinesChanges);
    },
    
    openEditElementDialog: function(e) {
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }   
                
        this.dialogConf.title = $.i18n.t('Disk image') + ": " + this.model.get('disk_image');

        Up.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        // Configure tags inputs
        Up.I.tagsInputConfiguration();
    },
    
    // Check if any running VM has suffered changes with a DI update
    checkMachinesChanges: function (that) {
        var realView = Up.I.getRealView(that);

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
        
        if (success && tagChanges && Up.C.checkACL('vm.update.expiration')) {
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
                    "osf_id": Up.CurrentView.model.get('osf_id')
                };
                
                Up.A.performAction('vm_get_list', {}, vmFilters, {}, that.warnMachinesChanges, that);
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
        
        var realView = Up.I.getRealView(that);
        
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

        this.templateEditor = Up.TPL.editorAffectedVM;
        
        this.dialogConf.buttons = {
            Cancel: function () {
                Up.I.closeDialog($(this));
            },
            Update: function () {
                that.dialog = $(this);
                var affectedVMsIds = [];
                $.each($('.affectedVMCheck:checked'), function (iAVM, aVm) {
                      affectedVMsIds.push($(aVm).val());
                });
                
                if (affectedVMsIds.length == 0) {
                    Up.I.closeDialog(that.dialog);
                    Up.I.M.showMessage({message: 'No items were selected - Nothing to do', messageType: 'info'});
                    return;
                }
                
                var filters = {
                    "id": affectedVMsIds
                };
                
                args = {};
                if (Up.C.checkACL('vm.update.expiration')) {
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
                
                Up.A.performAction ('vm_update', args, filters, messages, function (that) {
                    Up.I.closeDialog(that.dialog);
                }, that);
            }
        };
        
        this.dialogConf.button1Class = 'fa fa-ban js-button-cancel';
        this.dialogConf.button2Class = 'fa fa-save js-button-update';
        
        this.enabledProperties = false;
        this.dialogConf.fillCallback = this.fillEditor;
        
        this.editorElement ();

        // Add specific parts of editor to dialog
        var template = _.template(
                    Up.TPL.editorAffectedVMList, {
                        affectedVMs: affectedVMs
                    }
                );

        $('.bb-affected-vms-list').html(template);
    },
}