// Common lib for OSF views (list and details)
Wat.Common.BySection.osf = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = Wat.I.T.getTemplateList('osDetails');
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    updateElement: function (dialog) {
        var that = that || this;
        
        // If current view is list, use selected ID as update element ID
        if (that.viewKind == 'list') {
            that.id = that.selectedItems[0];
        }
        
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(that, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = that.properties;
        
        var context = $('.' + that.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        var description = context.find('textarea[name="description"]').val();

        arguments = {};
        
        if (Wat.C.checkACL('osf.update.name')) {
            arguments['name'] = name;
        }
        
        if (Wat.C.checkACL('osf.update.memory')) {
            arguments['memory'] = memory;
        }
        
        if (Wat.C.checkACL('osf.update.user-storage')) {
            arguments['user_storage'] = user_storage;
        }
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('osf.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
            
        if (Wat.C.checkACL('osf.update.description')) {
            arguments["description"] = description;
        }
        
        // If distro is setted, create an OSD on DIG
        if (that.model.get('distro_id') != OSF_DISTRO_COMMON_ID) {
            var that = this;
            that.OSDmodel.save(that.OSDmodel.changedAttributes(), {
                success: function () {
                },
                patch: true
            });
        }
        
        var filters = {"id": that.id};
        
        that.updateModel(arguments, filters, that.fetchAny);
    },
    
    openEditElementDialog: function(e) {
        var that = this;
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }
                
        this.dialogConf.title = $.i18n.t('Edit OS Flavour') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        // If OSF were created using DIG, retrieve OS info from DIG
        var osdID = this.model.get('osd_id');
        if (osdID) {
            Wat.DIG.fetchOSD(osdID, function (OSDmodel) {
                that.OSDmodel = OSDmodel;

                that.renderOSDetails(that.OSDmodel, {
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
    
    // Render OS Details template and return it
    // model: Backbone model of the OSD
    // options: Options of the rendering
    //          - editable: If Edit button will be rendering
    //          - shrinked: If is just showed SO distro and rest of the info is expanded clicking More button
    //          - container: CSS selector of the container where will be rendered
    renderOSDetails: function (model, options) {
        options.container = options.container || '';
        
        if (!model) {
            var template = 'This OSF is of type custom';
        }
        else {
            var osfId = this.model.get('id') || 0;
            var distroId = model.get('distro_id');
            
            var distros = model.getPluginAttrOptions('os.distro');

            // Add specific parts of editor to dialog
            var template = _.template(
                        Wat.TPL.osConfiguration, {
                            osfId: osfId,
                            model: model,
                            config_params: model.get('config_params'),
                            shortcuts: model.get('shortcuts'),
                            scripts: model.get('scripts'),
                            distro: distros[distroId],
                            editable: options.editable,
                            shrinked: options.shrinked
                        }
                    );
        }
        
        $(options.container + ' .bb-os-configuration').html(template);
    }
}