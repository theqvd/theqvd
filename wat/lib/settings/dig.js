Wat.DIG = {
    pluginDef: {},
    
    createOSD: function (callback) {
        var that = this;
        
        var OSDmodel = new Wat.Models.OSD();
        
        OSDmodel.save({}, {
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
    
    fetchPluginDef: function (OSDmodel, callbackFetch) {
        var osdId = OSDmodel.get('id');
        
        OSDmodel.pluginDef = new Wat.Collections.PluginsDef(null, {osdId: osdId});
        OSDmodel.pluginDef.fetch({
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
}