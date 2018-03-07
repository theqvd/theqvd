// Common lib for DI views (list and details)
Wat.Common.BySection.di = {
    editorViewClass: Wat.Views.DIEditorView,
    
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templatesOD = Wat.I.T.getTemplateList('osDetails');
        
        var templatesCommon = Wat.I.T.getTemplateList('commonDI');
        
        this.templates = $.extend({}, this.templates, templatesOD, templatesCommon);
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
                    "osf_id": Wat.CurrentView.model ? Wat.CurrentView.model.get('osf_id') : ''
                };
                
                Wat.A.performAction('vm_get_list', {}, vmFilters, {}, that.warnMachinesChanges, that);
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
                Wat.I.closeDialog($(this));
            },
            Update: function () {
                that.dialog = $(this);
                var affectedVMsIds = [];
                $.each($('.affectedVMCheck:checked'), function (iAVM, aVm) {
                      affectedVMsIds.push($(aVm).val());
                });
                
                if (affectedVMsIds.length == 0) {
                    Wat.I.closeDialog(that.dialog);
                    Wat.I.M.showMessage({message: 'No items were selected - Nothing to do', messageType: 'info'});
                    return;
                }
                
                var filters = {
                    "id": affectedVMsIds
                };
                
                args = {};
                if (Wat.C.checkACL('vm.update.expiration')) {
                    var expiration_soft = that.dialog.find('input[name="expiration_soft"]').val();
                    var expiration_hard = that.dialog.find('input[name="expiration_hard"]').val();
                    
                    // Convert expiration dates to UTC and a properly format to be stored
                    if (expiration_soft != undefined) {
                        args['expiration_soft'] = Wat.U.stringDateToDatabase(expiration_soft);
                    }
                    if (expiration_hard != undefined) {
                        args['expiration_hard'] = Wat.U.stringDateToDatabase(expiration_hard);
                    }
                }
                
                messages = {
                    'error': i18n.t('Error updating'), 
                    'success': i18n.t('Successfully updated')
                };
                
                Wat.A.performAction ('vm_update', args, filters, messages, function (that) {
                    Wat.I.closeDialog(that.dialog);
                }, that);
            }
        };
        
        this.dialogConf.buttonClasses = ['fa fa-ban js-button-cancel', 'fa fa-save js-button-update'];
        
        this.enabledProperties = false;
        this.dialogConf.fillCallback = function (target, that) {
            // Add general editor
            var template = _.template(
                        Wat.TPL.editorAffectedVM, {
                        }
                    );
            
            $(target).html(template);
            
            // Add list of affected VMs
            var template = _.template(
                        Wat.TPL.editorAffectedVMList, {
                            affectedVMs: affectedVMs
                        }
                    );

            $('.bb-affected-vms-list').html(template);

            Wat.I.enableDataPickers();
        };
        
        Wat.I.dialog(this.dialogConf, this);
    },
    
    // Hook to be called after create an element
    afterCreating: function () {
        // Nothing
    },
    
    renderProgressBars: function () {
        var that = this;
        
        if (that.collection) {
            var models = that.collection.models;
        }
        else {
            var models = [that.model];
        }
        
        $.each(models, function (i, model) {
            // Show only state icons for each row
            $('[data-id="' + model.get('id') + '"] .js-progress-icon').hide();
            $('[data-id="' + model.get('id') + '"] .js-progress-icon--' + model.get('state')).show();
            
            this.template = _.template(
                Wat.TPL.diProgressBar, {
                    id: model.get('id'),
                    state: model.get('state'),
                    percentage: model.get('percentage'),
                    remainingTime: model.get('remaining_time'),
                    elapsedTime: model.get('elapsed_time')
                }
            );
            
            $('.bb-di-progress[data-id="' + model.get('id') + '"]').html(this.template);
        });
        
        var progressBars = $("." + this.cid + " .progressbar");

        $.each (progressBars, function (i, progressBar) {
            var progressLabel = $(progressBar).find('.progress-label');
            $(progressBar).progressbar({
                value: false,
                change: function (e) {
                    that.updateDiProgress(progressBar);
                },
                complete: function () {
                    var progressLabel = $(progressBar).find('.progress-label');
                    progressLabel.text($.i18n.t("Complete"));
                }
            });
        });
        
        clearInterval(that.intervals['localDiProgressTime']);
        
        that.intervals['localDiProgressTime'] = setInterval(function () {
            $.each(progressBars, function (i, progressBar) {
                var percent = parseInt($(progressBar).attr('data-percent'));
                var remainingTime = parseInt($(progressBar).attr('data-remaining'));
                var elapsedTime = parseInt($(progressBar).attr('data-elapsed'));

                if (percent >= 100) {
                    return;
                }

                $(progressBar).attr('data-remaining', remainingTime>0 ? remainingTime-1 : 0);
                $(progressBar).attr('data-elapsed', elapsedTime+1);

                that.updateDiProgress(progressBar);
            });
        }, 1000);
    },
    
    updateDiProgress: function (progressBar) {
        var progressRemaining = $(progressBar).parent().find('.progress-remaining');
        var progressElapsed = $(progressBar).parent().find('.progress-elapsed');
        var progressLabel = $(progressBar).find('.js-progress-label--percentage');
        
        var percent = $(progressBar).attr('data-percent');
        var remaining = $(progressBar).attr('data-remaining');
        var elapsed = $(progressBar).attr('data-elapsed');
        
        progressRemaining.html(Wat.U.secondsToHms(remaining));
        progressElapsed.html(Wat.U.secondsToHms(elapsed));
        var progressText = percent + "%";
        progressLabel.text(progressText);
        $(progressBar).progressbar("value", percent);
        $(progressBar).find('.ui-progressbar-value').css('width', percent + '%').show();
    },
}