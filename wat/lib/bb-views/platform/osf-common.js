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
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }
                
        this.dialogConf.title = $.i18n.t('Edit OS Flavour') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        this.fetchOSD(function (that) {
            var template = that.getOsDetailsRender(that.OSDmodel, {shrinked: true, editable: true});
            $('.editor-container .bb-os-configuration').html(template);
        });
    },
    
    fetchOSD: function (callback) {
        callback = callback || function () {};
        var that = this;
        
        if (!this.model.get('osd_id')) {
            callback(that);
            return;
        }
        
        this.OSDmodel = new Wat.Models.OSD({id: this.model.get('osd_id')});
        
        this.OSDmodel.fetch({
            success: function(e) {
                callback(that);
            }
        });
    },
    
    // Render OS Details template and return it
    // model: Backbone model of the OSD
    // options: Options of the rendering
    //          - editable: If Edit button will be rendering
    //          - shrinked: If is just showed SO distro and rest of the info is expanded clicking More button
    getOsDetailsRender: function (model, options) {
        var osfId = this.model.get('id') || 0;
        var distroModel = this.distros.where({id: model.get('distro_id')})[0];
        
        // Add specific parts of editor to dialog
        var template = _.template(
                    Wat.TPL.osConfiguration, {
                        osfId: osfId,
                        model: model,
                        config_params: model.get('config_params'),
                        shortcuts: model.get('shortcuts'),
                        scripts: model.get('scripts'),
                        distroModel: distroModel,
                        editable: options.editable,
                        shrinked: options.shrinked
                    }
                );
        
        return template;
    }
}