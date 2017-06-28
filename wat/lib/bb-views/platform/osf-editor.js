Wat.Views.OSFEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'osf',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
        'change select[name="os_distro_select"]' : 'toggleOSDistro',
        'click .js-button-edit-os': 'openOSEditor',
        'click .js-expand-os-conf': 'toggleOSConfigExpanded'
    },
    
    createElement: function () {
        // Properties to create, update and delete obtained from parent view
        var properties = this.parseProperties('create');
                
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        
        args = {
            name: name,
            memory: DEFAULT_OSF_MEMORY
        };
        
        if (memory && Wat.C.checkACL('osf.create.memory')) {
            args['memory'] = memory;
        }
        
        if (Wat.C.checkACL('osf.create.user-storage')) {
            args['user_storage'] = user_storage;
        }
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('osf.create.properties')) {
            args["__properties__"] = properties.set;
        }
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            args["name"] = name;
        }
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            args["description"] = description;
        }
                 
        if (Wat.C.isSuperadmin()) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            args['tenant_id'] = tenant_id;
        }
        
        var distro_id = $('select[name="os_distro_select"]').val();
        
        // If distro is setted, materialize OSD snapshot
        if (distro_id != OSF_DISTRO_COMMON_ID) {
            // TODO SNAPSHOT MATERIALIZATION
            
            args['osd_id'] = Wat.CurrentView.OSDmodel.get('id');
        }
        
        Wat.CurrentView.createModel(args, Wat.CurrentView.fetchList);
    },
    
    updateElement: function (dialog) {
        // If current view is list, use selected ID as update element ID
        if (Wat.CurrentView.viewKind == 'list') {
            Wat.CurrentView.id = Wat.CurrentView.selectedItems[0];
        }
        
        var properties = this.parseProperties('update');
        
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        var description = context.find('textarea[name="description"]').val();

        args = {};
        
        if (Wat.C.checkACL('osf.update.name')) {
            args['name'] = name;
        }
        
        if (Wat.C.checkACL('osf.update.memory')) {
            args['memory'] = memory;
        }
        
        if (Wat.C.checkACL('osf.update.user-storage')) {
            args['user_storage'] = user_storage;
        }
        
        if (properties && !$.isEmptyObject(properties.set) && Wat.C.checkACL('osf.update.properties')) {
            args["__properties_changes__"] = properties;
        }
            
        if (Wat.C.checkACL('osf.update.description')) {
            args["description"] = description;
        }
        
        // If distro is setted, materialize OSD snapshot
        if (Wat.CurrentView.model.get('distro_id') != OSF_DISTRO_COMMON_ID) {
            // TODO SNAPSHOT MATERIALIZATION
        }
        
        var filters = {"id": Wat.CurrentView.id};
        
        Wat.CurrentView.updateModel(args, filters, Wat.CurrentView.fetchAny);
    },
    
    toggleOSDistro: function (e) {
        var selectedDistro = $(e.target).val();

        switch (selectedDistro) {
            case "-1":
                $('.js-os-configuration-row').hide();
                break;
            default:
                // Save distro id in OSD just for MOCK!
                Wat.CurrentView.OSDmodel.set({distro_id: selectedDistro, name: selectedDistro});
                Wat.CurrentView.OSDmodel.save();

                // Save distro id
                var opts = {
                    pluginId: 'os',
                    attributes: {distro: selectedDistro}
                };

                Wat.DIG.setPluginAttr(opts, function () {}, function () {
                    Wat.CurrentView.renderOSDetails(Wat.CurrentView.OSDmodel, {
                        shrinked: true,
                        editable: true,
                        container: '.editor-container'
                    });
                    $('.js-os-configuration-row').show();
                });

                break;
        }
    
    },
    
    renderCreate: function (target, that) {
        Wat.CurrentView.model = new Wat.Models.OSF();
        $('.ui-dialog-title').html($.i18n.t('New OS Flavour'));
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
        
        Wat.I.chosenElement('select[name="os_distro_select"]','single100');
        
        // Create OSD
        Wat.DIG.createOSD(function (OSDmodel) {
            Wat.CurrentView.OSDmodel = OSDmodel;
            
            var osList = Wat.CurrentView.OSDmodel.getPluginAttrOptions('os.distro');
            
            $.each (osList, function (id, distro) {
                var opt = document.createElement("OPTION");
                $(opt).val(id).html(distro.value);
                $('select[name="os_distro_select"').append(opt);
            });
            
            $('select[name="os_distro_select"').trigger('chosen:updated');
        });
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-title').html($.i18n.t('Edit OS Flavour') + ": " + this.model.get('name'));
        
        // If OSF were created using DIG, retrieve OS info from DIG
        var osdID = this.model.get('osd_id');
        if (osdID) {
            Wat.DIG.fetchOSD(osdID, function (OSDmodel) {
                that.OSDmodel = OSDmodel;

                Wat.CurrentView.renderOSDetails(that.OSDmodel, {
                    shrinked: true, 
                    editable: true, 
                    container: '.editor-container'
                });
            });
        }
        else {
            that.renderOSDetails();
        }
    },
    
    afterNewElementDialogAction: function (action) {
        switch (action) {
            case 'cancel':
                // Delete temporary OSD if OSF is not finally created
                Wat.CurrentView.OSDmodel.destroy();
                break;
        }
    },
    
    updateMassiveElement: function (dialog, id) {
        // Properties to create, update and delete obtained from parent view
        var properties = this.parseProperties('update');
        
        var arguments = {};
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('osf.update-massive.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        var context = $('.' + this.cid + '.editor-container');
        
        var description = context.find('textarea[name="description"]').val();
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        
        var filters = {"id": id};
        
        if (Wat.I.isMassiveFieldChanging("description") && Wat.C.checkACL(this.qvdObj + '.update-massive.description')) {
            arguments["description"] = description;
        }
        
        if (Wat.I.isMassiveFieldChanging("memory") && Wat.C.checkACL('osf.update-massive.memory')) {
            arguments["memory"] = memory;
        }
        
        if (Wat.I.isMassiveFieldChanging("user_storage") && Wat.C.checkACL('osf.update-massive.user-storage')) {
            arguments["user_storage"] = user_storage;
        }
        
        Wat.CurrentView.resetSelectedItems();
        
        var auxModel = new Wat.Models.OSF();
        Wat.CurrentView.updateModel(arguments, filters, Wat.CurrentView.fetchList, auxModel);
    },
    
    openOSEditor: function (e) {
        var osfId = $(e.target).attr('data-osf-id');
        var massive = false;

        if (osfId == -1) {
            osfIds = Wat.CurrentView.selectedItems.join(',');
            var massive = true;
        }

        var dialogConf = {
            title: "Software configuration",
            buttons : {
                "Cancel": function () {
                    Wat.I.closeDialog($(this));

                    // Send primary dialog to front again
                    $('.ui-dialog').eq(0).css('z-index','');

                    Wat.CurrentView.OSDdialogView.remove();
                    delete Wat.CurrentView.OSDdialogView;

                    var savepoint = new Wat.Models.OSDSavepoint({}, { 
                        osdId: Wat.CurrentView.OSDmodel.id, 
                        discard: true 
                    });
                    savepoint.save();
                },
                "Save": function () {
                    Wat.U.setFormChangesOnModel('.js-editor-form-osf-os', Wat.CurrentView.OSDmodel);
                    Wat.CurrentView.renderOSDetails(Wat.CurrentView.OSDmodel, {
                        shrinked: true, 
                        editable: true,
                        container: '.editor-container'
                    });
                    Wat.I.closeDialog($(this));

                    // Send primary dialog to front again
                    $('.ui-dialog').eq(0).css('z-index','');

                    Wat.CurrentView.OSDdialogView.remove();
                    delete Wat.CurrentView.OSDdialogView;

                    var savepoint = new Wat.Models.OSDSavepoint({}, { 
                        osdId: Wat.CurrentView.OSDmodel.id 
                    });
                    savepoint.save();
                }
            },
            buttonClasses: ['fa fa-ban js-button-close','fa fa-save js-button-save'],

            fillCallback: function (target) {
                Wat.CurrentView.OSDdialogView = new Wat.Views.OSDEditorView({
                    el: $(target),
                    osfId: osfId,
                    massive: massive,
                    osdId: Wat.CurrentView.OSDmodel.id
                });
            },
        }

        Wat.CurrentView.osDialog = Wat.I.dialog(dialogConf);

        // Add secondary dialog class to new dialog to give different look
        Wat.CurrentView.osDialog.parent().addClass('ui-dialog-secondary');
        Wat.CurrentView.osDialog.dialog("option", "position", {my: "center", at: "center", of: window});
        // Send primary dialog to back because jquery ui doesnt handle it properly
        $('.ui-dialog').eq(0).css('z-index','100');

        Wat.I.chosenElement('select[name="icons-collection"]','single100');
    },

    toggleOSConfigExpanded: function (e) {
        if ($(e.target).hasClass('fa-chevron-down')) {
            $(e.target).removeClass('fa-chevron-down').addClass('fa-chevron-up');
        }
        else {
            $(e.target).removeClass('fa-chevron-up').addClass('fa-chevron-down');
        }

        $('.js-os-configuration-expanded').toggle();
    },
});