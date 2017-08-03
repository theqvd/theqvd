Wat.DIG = {
    pluginDef: {},
    
    createOSD: function (callback) {
        var that = this;
        
        var OSDmodel = new Wat.Models.OSD({ id: null, name: '0' });
        
        OSDmodel.save({}, {
            type: 'POST',
            complete: function (e) {
                that.fetchPluginDef(OSDmodel, function (OSDmodel) {
                    OSDmodel.initPlugins();
                    callback(OSDmodel);
                });
            }
        });
    },
    
    fetchOSD: function (osdId, callback) {
        var that = this;
        
        var OSDmodel = new Wat.Models.OSD({id: osdId});
        
        OSDmodel.fetch({
            success: function(e) {
                that.fetchPluginDef(OSDmodel, callback);
            },
            error: function (e) {
                callback(false);
            }
        });
    },
    
    fetchPluginDef: function (OSDmodel, callbackFetchDef) {
        var that = this;
        
        var osdId = OSDmodel.get('id');
        
        OSDmodel.pluginDef = new Wat.Collections.PluginsDef(null, {osdId: osdId});
        OSDmodel.pluginDef.fetch({
            success: function () {
                callbackFetchDef(OSDmodel);
            },
            error: function (e) {
                callbackFetchDef(false);
            }
        });
    },
    
    fetchPlugin: function (OSDmodel, callbackFetch) {
        var that = this;
        
        var osdId = OSDmodel.get('id');
        
        OSDmodel.plugin = new Wat.Collections.Plugins(null, {osdId: osdId});
        OSDmodel.plugin.fetch({
            complete: function () {
                callbackFetch(OSDmodel);
            }
        });
    },
    
    setPluginAttr: function (opts, callbackSave, callbackFetch) {
        Wat.CurrentView.OSDmodel.pluginData[opts.pluginId].save(opts.attributes, {
            type: 'PUT',
            complete: function (e) {
                callbackSave(e);
                // After any plugin update, plugin definitions must be retrieved
                Wat.DIG.fetchPluginDef(Wat.CurrentView.OSDmodel, callbackFetch);
            }
        });
    },
    
    setPluginListElement: function (opts, callbackSave, callbackFetch) {
        Wat.CurrentView.OSDmodel.pluginData[opts.pluginId] = new Wat.Models.Plugin(opts.attributes, { 
            osdId: opts.osdId,
            pluginId: opts.pluginId
        });
        Wat.CurrentView.OSDmodel.pluginData[opts.pluginId].save({}, {
            complete: function (e) {
                callbackSave(e);
                // After any plugin update, plugin definitions must be retrieved
                Wat.DIG.fetchPluginDef(Wat.CurrentView.OSDmodel, callbackFetch);
            }
        });
    },
    
    deletePluginListElement: function (opts, callbackDestroy, callbackFetch) {
        Wat.CurrentView.OSDmodel.pluginData[opts.pluginId] = new Wat.Models.Plugin(opts.attributes, { 
            osdId: opts.osdId,
            pluginId: opts.pluginId
        });
                
        Wat.CurrentView.OSDmodel.pluginData[opts.pluginId].destroy({
            complete: function (e) {
                callbackDestroy(e);
                // After any plugin update, plugin definitions must be retrieved
                Wat.DIG.fetchPluginDef(Wat.CurrentView.OSDmodel, callbackFetch);
            }
        });
    },
    
    changeAssetSelector: function (e, opt) {
        var controlId = $(opt).attr('data-control-id');
        var assetId = $(opt).val();
        var type = $(opt).attr('data-type');
        var url = $(opt).attr('data-url');
        var pluginId = $(opt).attr('data-plugin-id');
        var name = $(opt).attr('data-name');
        
        switch (type) {
            case 'script':
                var defaultText = "#!/bin/bash\n\nSTR=\"Hello World!\"\necho $STR";
                $.ajax ( {
                    url: url,
                    complete: function (e) {
                        // Mock if error
                        var responseText = e.responseText || defaultText;
                        $('[data-preview-id="' + controlId + '"]').html(responseText.replace(/\n/g,"<br>").replace('World', url)).show();
                    },
                });
                break;
            case 'wallpaper':
                $('[data-preview-id="' + controlId + '"]').html('<img src="' + url + '" style="width: 90%; display: block; margin: 0 auto;"></img>');
                break;
        }
    },
    
    // Render OS Details template and return it
    // model: Backbone model of the OSD
    // options: Options of the rendering
    //          - editable: If Edit button will be rendering
    //          - shrinked: If is just showed SO distro and rest of the info is expanded clicking More button
    //          - container: CSS selector of the container where will be rendered
    renderOSDetails: function (model, options) {
        options = options || {};
        options.container = options.container || '';
        
        if (model === undefined) {
            var template = $.i18n.t('Software information not available');
            $(options.container + ' .bb-os-configuration').html(template);
        }
        else if (model === false) {
            var template = $.i18n.t('Error retrieving software information');
            $(options.container + ' .bb-os-configuration').html(template);
        }
        else {
            var osfId = Wat.CurrentView.model ? Wat.CurrentView.model.get('id') : 0;
            var distroId = model.get('distro_id');
            
            var distros = model.getPluginAttrOptions('os.distro', function (distros) {
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
        
                $(options.container + ' .bb-os-configuration').html(template);
            });
        }
    },
}
