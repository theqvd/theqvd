Wat.Views.OSFEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'osf',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
        'change select[name="os_distro_select"]' : 'showOSEditor'
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
    
    showOSEditor: function (e) {
        var selectedDistro = $(e.target).val();
        var selectedDistroName = $('[name="os_distro_select"] option:selected').html();

        switch (selectedDistro) {
            case "-1":
                $('.js-os-configuration-row').hide();
                
                Wat.CurrentView.editorView.softwareEditorView.remove();
                break;
            default:
                // Save distro id in OSD just for MOCK!
                Wat.CurrentView.OSDmodel.set({distro_id: selectedDistro, name: selectedDistro});
                Wat.CurrentView.OSDmodel.save();
                
                $('.bb-os-configuration-editor').html('<div style="color: #222;">' + HTML_MID_LOADING + '</div>');
                
                // Save distro id
                var opts = {
                    pluginId: 'os',
                    attributes: {
                        id: selectedDistro
                    }
                };
                
                Wat.DIG.setPluginAttr(opts, function () {}, function () {
                    var osfId = $(e.target).attr('data-osf-id');
                    var massive = false;
                    
                    if (osfId == -1) {
                        osfIds = Wat.CurrentView.selectedItems.join(',');
                        var massive = true;
                    }
                    
                    Wat.CurrentView.editorView.softwareEditorView = new Wat.Views.OSDEditorView({
                        el: '.bb-os-configuration-editor',
                        osfId: osfId,
                        massive: false,
                        osdId: Wat.CurrentView.OSDmodel.id
                    });
                });

                break;
        }
    },
    
    renderCreate: function (target, that) {
        Wat.CurrentView.model = new Wat.Models.OSF();
        $('.ui-dialog-titlebar').html($.i18n.t('New OS Flavour'));
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
        
        Wat.I.chosenElement('select[name="os_distro_select"]','single100');
        
        // Create OSD
        Wat.DIG.createOSD(function (OSDmodel) {
            Wat.CurrentView.OSDmodel = OSDmodel;
            
            var osList = Wat.CurrentView.OSDmodel.getPluginAttrOptions('os.distro', function (osList) {
                $.each (osList, function (id, distro) {
                    var opt = document.createElement("OPTION");
                    $(opt).val(id).html(distro.value);
                    $('select[name="os_distro_select"').append(opt);
                });

                $('select[name="os_distro_select"').trigger('chosen:updated');
            });
        });
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-titlebar').html($.i18n.t('Edit OS Flavour') + ": " + this.model.get('name'));
        
        // If OSF were created using DIG, retrieve OS info from DIG
        var osdId = this.model.get('osd_id');
        if (osdId) {
            Wat.DIG.fetchOSD(osdId, function (OSDmodel) {
                if (OSDmodel.get('error')) {
                    $('.bb-os-configuration-editor').html('<div class="center" data-i18n="Error retrieving software information"></div>');
                    Wat.T.translate();
                    return;
                }
                
                OSDmodel.initPlugins();
                
                // If OSD is not retrieved properly hide software tab
                if (!OSDmodel) {
                    $('[data-tab="software"]').remove();
                    return;
                }
                
                Wat.CurrentView.OSDmodel = OSDmodel;
                
                if (Wat.CurrentView.viewKind == 'list') {
                    var osfId = Wat.CurrentView.selectedItems[0];
                }
                else {
                    var osfId = Wat.CurrentView.id;
                }
                
                Wat.CurrentView.editorView.softwareEditorView = new Wat.Views.OSDEditorView({
                    el: '.bb-os-configuration-editor',
                    osfId: osfId,
                    massive: false,
                    osdId: osdId
                });
            });
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
    }
});