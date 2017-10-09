Wat.Views.DIEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'di',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
        'change select[name="osf_id"]': 'changeOSF',
        'click .js-expand-os-conf': 'toggleOSConfigExpanded'
    },
    
    renderCreate: function (target, that) {
        if (Wat.CurrentView.qvdObj == 'osf') {
            Wat.CurrentView.embeddedViews.di = Wat.CurrentView.embeddedViews.di || {};
            Wat.CurrentView.embeddedViews.di.model = new Wat.Models.DI();
        }
        else {
            Wat.CurrentView.model = new Wat.Models.DI();
        }
        
        $('.ui-dialog-titlebar').html($.i18n.t('New Disk Image'));
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
        
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
            if (Wat.CurrentView.model && Wat.CurrentView.model.id) {
                userHidden.value = Wat.CurrentView.model.get('id');
            }
            else if (Wat.CurrentView.collection) {
                // If is OSF list view get id from subview filters
                userHidden.value = Wat.CurrentView.embeddedViews.di.collection.filters.osf_id;
            }
            $('.editor-container').append(userHidden);
            
            if ($('[name="tenant_id"]').length > 0) {
                $('[name="tenant_id"]').parent().parent().remove();
            }
            
            this.toggleSoftwareFields(Wat.CurrentView.id);
        }
        else {
            // Fill OSF select on virtual machines creation form
            var params = {
                'actionAuto': 'osf',
                'selectedId': $('.' + this.cid + ' .filter select[name="osf"]').val(),
                'controlName': 'osf_id',
                'chosenType': 'advanced100'
            };

            // If exist tenant control (in superadmin cases) show osfs of selected tenant
            if ($('[name="tenant_id"]').length > 0) {
                // Add an event to the tenant select change
                Wat.B.bindEvent('change', '[name="tenant_id"]', Wat.B.editorBinds.filterTenantOSFs);
                Wat.I.chosenElement('select[name="osf_id"]', 'advanced100');
            }
            else {
                Wat.A.fillSelect(params);
            }
        }
        
        $('select[name="images_source"]').trigger('change');
        Wat.I.chosenElement('select[name="images_source"]', 'single100');
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-titlebar').html($.i18n.t('Edit Disk image') + ": " + this.model.get('disk_image'));

        // Configure tags inputs
        Wat.I.tagsInputConfiguration();
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
        
        // Store tags for affected VMs checking
        tags.push('head');
        
        this.tagChanges = {
            create: tags,
            delete: []
        };
        
        var osdId = context.find('input[name="osd_id"]').val();
        
        if (osdId) {
            var imageModel = new Wat.Models.Plugin({}, {osdId: osdId, pluginId: 'image'});
            
            imageModel.save({name: 'image_name'}, {
                complete: function () {
                    Wat.I.M.showMessage({message: 'Succesfully created', messageType: 'success'});
                    
                    // If view is OSF details, render DI progress monitoring
                    if (Wat.CurrentView.qvdObj == 'osf') {
                        Wat.CurrentView.renderDiProgress(osdId);
                        $('.js-details-option[data-details-target="activity"]').trigger('click');
                    }
                }
            });
        }
        else {
            var image_source = context.find('select[name="images_source"]').val();
            
            switch (image_source) {
                case 'staging':
                    var disk_image = context.find('select[name="disk_image"]').val();
                    if (disk_image) {
                        arguments["disk_image"] = disk_image;
                    }
                    this.heavyCreateStaging(arguments);
                    break;
                case 'computer':
                    var diskImageFile = context.find('input[name="disk_image_file"]');
                    
                    // In this case the progress is controlled by HTML5 API for files uploading
                    this.saveFile(arguments, diskImageFile);
                    break;
                case 'url':
                    var diskImageUrl = context.find('input[name="disk_image_url"]').val();
                    arguments["disk_image"] = Wat.U.basename(diskImageUrl);
                    
                    this.heavyCreateDownload(arguments, diskImageUrl);
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
        
        that.updateModel(arguments, filters, that.checkMachinesChanges);
    },
    
    // Show/Hide image source and software configuration depending on OSD
    changeOSF: function (e) {
        var osfId = $(e.target).val();
        
        this.toggleSoftwareFields(osfId);
    },
    
    toggleSoftwareFields: function (osfId) {
        var that = this;
        
        var osfModel = new Wat.Models.OSF({ id: osfId });
        
        osfModel.fetch ({
            complete: function () {
                var osdId = osfModel.get('osd_id');
                
                $('input[name="osd_id"]').val(osdId);
                
                if (osdId) {
                    $('.js-custom-image-row').hide();
                    
                    Wat.DIG.fetchOSD(osdId, function (OSDmodel) {
                        Wat.DIG.renderOSDetails(OSDmodel, {
                            shrinked: true,
                            container: '.' + that.cid
                        });
                        
                        $('.js-osd-row').show();
                    });
                }
                else { 
                    $('.js-osd-row').hide();
                    $('.js-custom-image-row').show();
                    $('select[name="images_source"]').trigger('change');
                }
            }
        });
    },

    toggleOSConfigExpanded: function (e) {
        if ($(e.target).hasClass('fa-chevron-down')) {
            $(e.target).removeClass('fa-chevron-down').addClass('fa-chevron-up');
        }
        else {
            $(e.target).removeClass('fa-chevron-up').addClass('fa-chevron-down');
        }

        $('.' + this.cid + ' .js-os-configuration-expanded').toggle();
    },
    
    heavyCreateDownload: function (args, diskImageUrl) {
        // Di creation is a heavy operation. Screen will be blocked and a progress graph shown
        Wat.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
        Wat.WS.openWebsocket (this.qvdObj, 'di_create', {
                arguments: args,
                url: encodeURI(diskImageUrl)
        }, this.creatingProcessDownload, 'di/download/');
    },
    
    heavyCreateStaging: function (args) {
        // Di creation is a heavy operation. Screen will be blocked and a progress graph shown
        Wat.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
        Wat.WS.openWebsocket (this.qvdObj, 'di_create', {
                arguments: args
        }, this.creatingProcessStaging, 'staging');
    },
    
    creatingProcessStaging: function (qvdObj, id, data, ws) {
        var usefulView = Wat.I.getUsefulView(qvdObj, 'creatingProcess');
        usefulView.creatingProcess(qvdObj, id, data, ws, 'staging');
    },
    
    creatingProcessDownload: function (qvdObj, id, data, ws) {
        var usefulView = Wat.I.getUsefulView(qvdObj, 'creatingProcess');
        usefulView.creatingProcess(qvdObj, id, data, ws, 'download');
    },
});