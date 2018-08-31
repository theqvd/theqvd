Wat.Views.DIEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'di',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
        'change select[name="osf_id"]': 'changeOSF',
        'click .js-expand-os-conf': 'toggleOSConfigExpanded',
        'change select[name="images_source"]': 'changeImageSource',
        'change select[name="expire_vms"]': 'changeExpireVms',
        'change .js-scheduler-hours': 'changeSchedulerHours',
        'click .js-scheduler-hours + .ui-spinner-button': 'changeSchedulerHours',
        'click .js-scheduler-hours + .ui-spinner-button + .ui-spinner-button': 'changeSchedulerHours',
        'click .js-scheduler-minutes + .ui-spinner-button': 'changeSchedulerMinutes',
        'click .js-scheduler-minutes + .ui-spinner-button + .ui-spinner-button': 'changeSchedulerMinutes'
    },
    
    renderCreate: function (target, that) {
        Wat.I.disableDialogButton('create');
        
        if (Wat.CurrentView.qvdObj == 'osf') {
            this.model = new Wat.Models.DI();
        }
        else {
            Wat.CurrentView.model = new Wat.Models.DI();
        }
        
        $('.ui-dialog-titlebar').html($.i18n.t('New Disk Image'));
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
        
        // Configure DI methods
        switch(Wat.C.hypervisor.toLowerCase()) {
            case 'kubernetes':
                $('select[name="images_source"]').val('docker');
                break;
            default:
        }

        // Configure tags inputs
        Wat.I.tagsInputConfiguration();
        
        // Fill disk images of staging folder select on disk images creation form
        var params = {
            'action': 'dis_in_staging',
            'controlName': 'disk_image',
            'nameAsId': true,
            'chosenType': 'advanced100'
        };
        
        Wat.A.fillSelect(params);
        
        // If main view is osf view, we are creating a disk image from osf details view. 
        // OSF and tenant (if exists) controls will be removed
        if (Wat.CurrentView.qvdObj == 'osf') {
            $('[name="osf_id"]').parent().parent().remove();

            var userHidden = document.createElement('input');
            userHidden.type = "hidden";
            userHidden.name = "osf_id";
            // If is OSF details view get id from model
            if (Wat.CurrentView.viewKind == 'details' && Wat.CurrentView.model.id) {
                userHidden.value = Wat.CurrentView.model.get('id');
            }
            else if (Wat.CurrentView.collection) {
                // If some OSF is selected means that the DI is created from selectedActions
                if (Wat.CurrentView.selectedItems[0]) {
                    userHidden.value = Wat.CurrentView.selectedItems[0];
                }
                else {
                    // If is OSF list view get id from subview filters
                    userHidden.value = Wat.CurrentView.embeddedViews.di.collection.filters.osf_id;
                }
            }
            $('.editor-container').append(userHidden);
            
            if ($('[name="tenant_id"]').length > 0) {
                $('[name="tenant_id"]').parent().parent().remove();
            }
            
            this.toggleSoftwareFields(userHidden.value);
        }
        else {
            // Fill OSF select on disk images creation form
            var params = {
                'actionAuto': 'osf',
                'selectedId': $('.' + this.cid + ' .filter select[name="osf"]').val(),
                'controlName': 'osf_id',
                'chosenType': 'advanced100',
                'extraFields': ['osd_id']
            };

            // If exist tenant control (in superadmin cases) show osfs of selected tenant
            if ($('[name="tenant_id"]').length > 0) {
                // Add an event to the tenant select change
                Wat.B.bindEvent('change', '[name="tenant_id"]', Wat.B.editorBinds.filterTenantOSFs);
                Wat.I.chosenElement('select[name="osf_id"]', 'advanced100');
            }
            else {
                var that = this;
                Wat.A.fillSelect(params, function () {
                    that.restrictOsfsWithDisabledDiCreation();
                    
                    var selectedOsfId = $('.' + this.cid + ' .filter select[name="osf"]').val();
                    that.toggleSoftwareFields(selectedOsfId);
                });
            }
        }
        
        Wat.I.chosenElement('select[name="images_source"]', 'single100');
        Wat.I.chosenElement('select[name="publish"]', 'single100');
        Wat.I.chosenElement('select[name="expire_vms"]', 'single100');
        $('[name="expire_vms_hours"]').spinner();
        $('[name="expire_vms_minutes"]').spinner();
    },
    
    // Remove OSFs with restricted DI creation from select control
    restrictOsfsWithDisabledDiCreation: function () {
        if (!Wat.C.checkACL('di.create.generation') || !Wat.C.isDIGEnabled()) {
            $.each($('.' + this.cid + ' select[name="osf_id"] option'), function (iOpt, opt) {
                var osdId = $(opt).attr('data-osd_id') || 0;
                
                if (osdId) {
                    $(this).remove();
                }
            });
            
            $('.' + this.cid + ' select[name="osf_id"]').trigger('chosen:updated');
        }
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-titlebar').html($.i18n.t('Edit Disk image') + ": " + this.model.get('disk_image'));
        
        // Configure tags inputs
        Wat.I.tagsInputConfiguration();
        
        this.toggleSoftwareFields(this.model.get('osf_id'));
        
        Wat.I.chosenElement('select[name="publish"]', 'single100');
        Wat.I.chosenElement('select[name="expire_vms"]', 'single100');
        $('[name="expire_vms_hours"]').spinner();
        $('[name="expire_vms_minutes"]').spinner();
    },
    
    createElement: function () {
        var properties = this.parseProperties('create');
        var context = $('.' + this.cid + '.editor-container');

        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        var osf_id = context.find('[name="osf_id"]').val();
        
        var arguments = {
            "blocked": blocked ? 1 : 0,
            "osf_id": osf_id
        };
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('di.create.properties')) {
            arguments["__properties__"] = properties.set;
        }
        
        var version = context.find('input[name="version"]').val();
        if (version && Wat.C.checkACL('di.create.version')) {
            arguments["version"] = version;
        }
        
        var tags = context.find('input[name="tags"]').val();
        tags = tags && Wat.C.checkACL('di.create.tags') ? tags.split(',') : [];
        
        var def = context.find('input[name="default"][value=1]').is(':checked');
        
        // If we set default add this tag
        if (def && Wat.C.checkACL('di.create.default')) {
            tags.push('default');
        }
        
        arguments['__tags__'] = tags;
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            arguments["description"] = description;
        }
        
        this.tagChanges = {
            create: tags,
            delete: []
        };
        
        var osdId = context.find('input[name="osd_id"]').val();
        
        if (osdId) {
            switch (context.find('select[name="publish"]').val()) {
                default:
                case 'no':
                    arguments["auto_publish"] = false;
                    break;
                case 'when_finish':
                    arguments["auto_publish"] = true;
                    break;
            }
            
            switch (context.find('select[name="expire_vms"]').val()) {
                default:
                case 'no':
                    // No send expiration parameters
                    break;
                case 'when_finish':
                    arguments["expiration_time_soft"] = 0;
                    arguments["expiration_time_hard"] = 0;
                    break;
                case 'after_finish':
                    arguments["expiration_time_soft"] = 0;
                    var hours = parseInt(context.find('input[name="expire_vms_hours"]').val());
                    var minutes = parseInt(context.find('input[name="expire_vms_minutes"]').val());
                    arguments["expiration_time_hard"] = ((hours * 60) + minutes) * 60;
                    break;
            }
            
            arguments.disk_image = context.find('.os-name').html()
            
            this.createDig(arguments);
        }
        else {
            var image_source = context.find('select[name="images_source"]').val();
            
            switch (image_source) {
                case 'staging':
                    var disk_image = context.find('select[name="disk_image"]').val();
                    if (disk_image) {
                        arguments["disk_image"] = disk_image;
                    }
                    var diView = Wat.U.getViewFromQvdObj('di');
                    diView.model.setEndpoint('di/staging');
                    
                    diView.createModel(arguments, diView.fetchList);
                    break;
                case 'computer':
                    var diskImageFile = context.find('input[name="disk_image_file"]');
                    
                    // In this case the progress is controlled by HTML5 API for files uploading
                    this.saveFile(arguments, diskImageFile);
                    break;
                case 'url':
                    var diskImageUrl = context.find('input[name="disk_image_url"]').val();
                    arguments["disk_image"] = Wat.U.basename(diskImageUrl);
                    
                    var diView = Wat.U.getViewFromQvdObj('di');
                    diView.model.setEndpoint('di/download');
                    diView.model.setExtraUrlArguments('&url="' + diskImageUrl + '"');
                    
                    diView.createModel(arguments, diView.fetchList);
                    break;
                case 'docker':
                    var dockerUrl = context.find('input[name="docker_url"]').val();
                    arguments["disk_image"] = dockerUrl;
                    
                    var diView = Wat.U.getViewFromQvdObj('di');
                    diView.model.setEndpoint('di/docker');
                    
                    diView.createModel(arguments, diView.fetchList);
                    break;
            }
        }
    },
    
    updateElement: function (dialog, that) {
        // If current view is list, use selected ID as update element ID
        if (that.viewKind == 'list') {
            that.id = that.selectedItems[0];
            that.model = that.collection.where({id: that.selectedItems[0]})[0];
        }
        
        var properties = this.parseProperties('update');
                
        var context = $('.' + this.cid + '.editor-container');
                        
        var tags = context.find('input[name="tags"]').val();
        var newTags = tags && Wat.C.checkACL('di.update.tags') ? tags.split(',') : [];
        var description = context.find('textarea[name="description"]').val();

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
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('di.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        if (Wat.C.checkACL('di.update.description')) {
            arguments["description"] = description;
        }
        
        that.tagChanges = arguments['__tags_changes__'];
        
        var osdId = context.find('input[name="osd_id"]').val();
        
        if (osdId) {
            if (Wat.C.checkACL('di.update.auto-publish')) {
                switch (context.find('select[name="publish"]').val()) {
                    case 'no':
                        arguments["auto_publish"] = false;
                        break;
                    case 'when_finish':
                        arguments["auto_publish"] = true;
                        break;
                }
            }
            
            if (Wat.C.checkACL('di.update.vms-expiration')) {
                switch (context.find('select[name="expire_vms"]').val()) {
                    case 'no':
                        arguments["expiration_time_soft"] = null;
                        arguments["expiration_time_hard"] = null;
                        break;
                    case 'when_finish':
                        arguments["expiration_time_soft"] = 0;
                        arguments["expiration_time_hard"] = 0;
                        break;
                    case 'after_finish':
                        arguments["expiration_time_soft"] = 0;
                        var hours = parseInt(context.find('input[name="expire_vms_hours"]').val());
                        var minutes = parseInt(context.find('input[name="expire_vms_minutes"]').val());
                        arguments["expiration_time_hard"] = ((hours * 60) + minutes) * 60;
                        break;
                }
            }
        }
        
        that.updateModel(arguments, filters, that.checkMachinesChanges);
    },
    
    // Show/Hide image source and software configuration depending on OSD
    changeOSF: function (e) {
        var osfId = $(e.target).val();
        
        this.toggleSoftwareFields(osfId);
    },
    
    toggleSoftwareFields: function (osfId) {
        var that = this;
        
        Wat.I.disableDialogButton('create');
        
        var osfModel = new Wat.Models.OSF({ id: osfId });
        
        osfModel.fetch ({
            complete: function () {
                var osdId = osfModel.get('osd_id');
                
                $('input[name="osd_id"]').val(osdId);
                
                if (osdId && Wat.C.isDIGEnabled()) {
                    $('.js-custom-image-row').hide().addClass('hidden-by-conf');
                    $('.js-osd-row').removeClass('hidden-by-conf');
                    
                    Wat.DIG.fetchOSD(osdId, function (OSDmodel) {
                        Wat.CurrentView.OSDmodel = OSDmodel;
                        
                        OSDmodel.initPlugins();
                        
                        Wat.DIG.renderOSDetails(OSDmodel, {
                            mode : 'shrinked',
                            container: '.' + that.cid
                        });
                        
                        // If OSD name is not available in the model, means that query has failed, so element cannot be created and creation button will not be enabled
                        if (OSDmodel.get('name')) {
                            Wat.I.enableDialogButton('create');
                        }
                    });
                }
                else { 
                    $('.js-osd-row').addClass('hidden-by-conf');
                    $('.js-custom-image-row').removeClass('hidden-by-conf');
                    
                    Wat.I.enableDialogButton('create');
                }
            }
        });
    },

    toggleOSConfigExpanded: function (e) {
        if ($(e.target).hasClass('fa-chevron-down')) {
            $(e.target).removeClass('fa-chevron-down').addClass('fa-chevron-up');
            
            Wat.DIG.renderOSDetails(Wat.CurrentView.OSDmodel, {
                mode: 'unshrinked'
            });
        }
        else {
            $(e.target).removeClass('fa-chevron-up').addClass('fa-chevron-down');
        }

        $('.' + this.cid + ' .js-os-configuration-expanded').toggle();
    },
    
    createDig: function (args) {
        var that = this;
        
        var realView = Wat.I.getRealView(this);
        
        realView.model.setEndpoint('di/generate');
        realView.model.setOperation('create');
        realView.model.save(args, {
            filters: {}
        }).complete(function (e) {
            var response = JSON.parse(e.responseText);
            
            if (response.status != STATUS_SUCCESS) {
                Wat.I.M.showMessage({message: i18n.t(response.message), messageType: 'error'});
                return;
            }
            
            realView.fetchList();
            realView.checkMachinesChanges(that);
            
            Wat.I.M.showMessage({message: i18n.t('Successfully created'), messageType: 'success'});
        });
    },
    
    saveFile: function(arguments, disk_image_file) {
        var that = this;
        var file = disk_image_file[0].files[0];
        var data = new FormData();
        data.append('file', file);
        
        // Set as disk_image the basename of the file
        arguments.disk_image = file.name;
        
        // Get Url for the API call
        var url = Wat.C.getUpdateDiUrl() + '&action=di_create&arguments=' + JSON.stringify(arguments) + '&parameters=' + JSON.stringify({source: Wat.C.source});
        
        Wat.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));

        $.ajax({
            url: encodeURI(url), 
            data: data,
            dataType: 'json',
            type: 'POST',
            xhr: function() {  // Custom XMLHttpRequest
                var myXhr = $.ajaxSettings.xhr();
                
                if(myXhr.upload){ // Check if upload property exists
                    myXhr.upload.addEventListener('progress', that.updateProgress, false); // For handling the progress of the upload
                }
                
                return myXhr;
            },
            processData: false,
            contentType: false, // Setting contentType as false 'multipart/form-data' and boundary will be sent

        }).success(function(e) {
            Wat.I.loadingUnblock();
            
            if (e.status == STATUS_SUCCESS) {
                var realView = Wat.I.getRealView(that);
                realView.fetchList();
                realView.checkMachinesChanges(that);

                Wat.I.M.showMessage({message: i18n.t('Successfully created'), messageType: 'success'});
            }
            else {
                Wat.I.M.showMessage({message: e.message, messageType: 'error'});
            }
        }).fail(function(data) {
            Wat.I.loadingUnblock();
            Wat.I.M.showMessage({message: i18n.t('Error creating'), messageType: 'error'});
        });
    },
    
    updateProgress: function (e)  {
        if (e.total == 0) {
            var percent = 100;
        }
        else {
            var percent = parseInt((e.loaded / e.total) * 100);
        }

        var step = 5;
        
        if (percent == 100) {
            var progressHiddenInput = '<input type="hidden" data-di-uploading="completed">';
        }
        else {
            var progressHiddenInput = '<input type="hidden" data-di-uploading="inprogress-' + Math.floor(percent/step)*step + '">';
        }

        var progressData = [e.loaded, e.total - e.loaded];
        Wat.I.G.drawPieChartSimple('loading-block', progressData);

        var progressMessage = '';
        progressMessage += parseInt(e.loaded/(BYTES_ON_KB*BYTES_ON_KB)) + 'MB';
        progressMessage += ' / ';
        progressMessage += parseInt(e.total/(BYTES_ON_KB*BYTES_ON_KB)) + 'MB';
        progressMessage += progressHiddenInput;
        
        var creatingMessage = $.i18n.t('Uploading image to server');
        
        $('.loading-little-message').html(creatingMessage + '<br><br>' + progressMessage);
    },
    
    changeImageSource: function (e) {
        var selectedSource = $(e.target).val();
        
        switch (selectedSource) {
            case 'computer':
                $('.js-custom-image-row--source').hide();
                $('.image_computer_row').show();
                break;
            case 'staging':
                $('.js-custom-image-row--source').hide();
                $('.image_staging_row').show();
                break;
            case 'url':
                $('.js-custom-image-row--source').hide();
                $('.image_url_row').show();
                break;
            case 'docker':
                $('.js-custom-image-row--selector').hide();
                $('.image_docker_row').show();
                break;
        }
    },
    
    switchEditorTab: function (tab) {
        Wat.Views.EditorView.prototype.switchEditorTab.apply(this, [tab]);
        
        if (tab == 'image') {
            // Reset visibility of image source control
            $('.js-custom-image-row--source').hide();
            if ($('select[name="images_source"]').closest('tr').css('display') != 'none') {
                $('select[name="images_source"]').trigger('change');
            }
            
            $('.js-expire-vms-scheduler').hide();
            if ($('select[name="expire_vms"]').closest('tr').css('display') != 'none') {
                $('select[name="expire_vms"]').trigger('change');
            }
        }
    },
    
    changeExpireVms: function (e) {
        switch ($(e.target).val()) {
            case 'after_finish':
                $('.js-expire-vms-scheduler').show();
                break;
            default:
                $('.js-expire-vms-scheduler').hide();
                break;
        }
    },
    
    changeSchedulerHours: function (e) {
        var field = $(e.target).closest('.ui-spinner-button').parent().find('input');
        var hours = parseInt($(field).val());
        
        if (hours < 0) {
            hours = 0;
        }
        
        $(field).val(hours);
    },
    
    changeSchedulerMinutes: function (e) {
        var field = $(e.target).closest('.ui-spinner-button').parent().find('input');
        var minutes = parseInt($(field).val());
        
        // Minutes will be updated 5 by 5
        if (minutes % 5 < 3) {
            minutes = Math.ceil(minutes / 5) * 5;
        }
        else {
            minutes = Math.floor(minutes / 5) * 5;
        }
        
        if (minutes < 0) {
            minutes = 0;
        }
        else if (minutes > 59) {
            minutes = 55;
        }
        
        $(field).val(minutes);
    }
});