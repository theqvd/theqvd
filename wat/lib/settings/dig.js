Wat.DIG = {
    pluginDef: {},
    
    createOSD: function (callback) {
        var that = this;
        
        var OSDmodel = new Wat.Models.OSD({ id: null, name: '0' });
        
        OSDmodel.save({}, {
            type: 'POST',
            complete: function () {
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
            complete: function(e) {
                that.fetchPluginDef(OSDmodel, callback);
            }
        });
    },
    
    fetchPluginDef: function (OSDmodel, callbackFetchDef) {
        var that = this;
        
        var osdId = OSDmodel.get('id');
        
        OSDmodel.pluginDef = new Wat.Collections.PluginsDef(null, {osdId: osdId});
        OSDmodel.pluginDef.fetch({
            complete: function () {
                callbackFetchDef(OSDmodel);
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
            complete: function (e) {
                callbackSave(e);
                // After any plugin update, plugin definitions must be retrieved
                Wat.DIG.fetchPluginDef(Wat.CurrentView.OSDmodel, callbackFetch);
            },
            patch: true
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
    
    changeAssetSelector: function (e) {
        var row = $(e.target).closest('tr').eq(0);
        
        var controlId = $(row).attr('data-control-id');
        var assetId = $(row).val();
        var type = $(row).attr('data-type');
        var url = $(row).attr('data-url');
        var pluginId = $(row).attr('data-plugin-id');
        var name = $(row).attr('data-name');
        
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
                $('[data-preview-id="' + controlId + '"]').html('<img src="' + url + '" style="width: 100%;"></img>');
                break;
        }
        
        $('table.js-asset-selector tr').removeClass('selected-row');
        $(row).addClass('selected-row');
    },
}
