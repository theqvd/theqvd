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
            },
        });
    },
    
    updateAssetPreview: function (opt) {
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
            case 'icon':
                if (assetId) {
                    $('[data-preview-id="' + controlId + '"]').html('<img src="' + url + '" style="width: 32px; display: block; margin: 50px auto;"></img>');
                }
                else {
                    $('[data-preview-id="' + controlId + '"]').html('');
                }
                break;
            case 'wallpaper':
                $('[data-preview-id="' + controlId + '"]').html('<img src="' + url + '" style="width: 90%; display: block; margin: 0 auto;"></img>');
                break;
            default:
                if ($(opt).attr('data-none')) {
                    $('[data-preview-id="' + controlId + '"]').html('');
                }
        }
        
        switch (type) {
            case 'icon':
            case 'wallpaper':
                // Show loading message for preview image until it is loaded
                if (assetId) {
                    $('.js-preview img').hide();
                    $('.js-data-preview-message').show();
                }
                $('.js-preview img').on('load', function () {
                    $('.js-preview img').show();
                    $('.js-data-preview-message').hide();
                });
                break;
        }
    },
    
    // Render OS Details template and return it
    // model: Backbone model of the OSD
    // options: Options of the rendering
    //          - mode:
    //              + shrinked: If is just showed SO distro and rest of the info is expanded clicking More button
    //              + unshrinked: If is showed full data and More button
    //              + full: If is showed full data without More button
    //          - container: CSS selector of the container where will be rendered
    renderOSDetails: function (model, options) {
        options = options || {};
        options.container = options.container || '';
        
        if (model === undefined) {
            var template = $.i18n.t('Software information not available');
            $(options.container + ' .bb-os-configuration').html(template);
        }
        else if (model === false || model.get('error')) {
            var template = $.i18n.t('Error retrieving software information');
            $(options.container + ' .bb-os-configuration').html(template);
        }
        else {
            var osfId = Wat.CurrentView.model ? Wat.CurrentView.model.get('id') : 0;
            var distroId = model.get('distro_id') || 1;
            
            var distros = model.getPluginAttrOptions('os.distro', function (distros) {
                // If mode is unshrinked means that is not needed render all table again
                if (options.mode != 'unshrinked') {
                    // Add specific parts of editor to dialog
                    var template = _.template(
                                Wat.TPL.osConfiguration, {
                                    osfId: osfId,
                                    model: model,
                                    config_params: model.get('config_params'),
                                    shortcuts: model.get('shortcuts'),
                                    scripts: model.get('scripts'),
                                    distro: distros[distroId],
                                    mode: options.mode
                                }
                            );

                    $(options.container + ' .bb-os-configuration').html(template);
                }
                
                // Get all assets to be showed in OSD details
                var assets = new Wat.Collections.Assets();

                assets.fetch({
                    complete: function (e) {
                        $.each(model.pluginData, function (pluginKey, pluginData) {
                            // When mode shrinked, only OS is rendered
                            if (options.mode == 'shrinked' && pluginKey != 'os') {
                                return;
                            }
                            // When mode unshrinked, all but OS is rendered
                            if (options.mode == 'unshrinked' && pluginKey == 'os') {
                                return;
                            }
                            
                            // Packages case is special and will be treated individually
                            if (pluginKey == 'pkg') {
                                pluginData = new Wat.Collections.Packages({ 
                                    offset: 1,
                                    block: 100,
                                    installed: 1,
                                    filters: {
                                        installed: true
                                    }
                                });
                            }
                            
                            $(options.container + ' .bb-osd-' + pluginKey).html(HTML_MICRO_LOADING);
                            
                            pluginData.fetch({
                                complete: function (e) {
                                    var template = _.template(
                                        Wat.TPL['osConfiguration_' + pluginKey], {
                                            pluginData: pluginData,
                                            assets: assets,
                                            mode: options.mode
                                        }
                                    );

                                    $(options.container + ' .bb-osd-' + pluginKey).html(template);
                                    Wat.T.translate();
                                }
                            });
                        });
                    }
                });
            });
        }
    },
}