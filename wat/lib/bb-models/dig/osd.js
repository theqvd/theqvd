Wat.Models.OSD = Wat.Models.DIG.extend({
    pluginDef: {},
    pluginData: {},
    
    initialize: function (attrs, opts) {
        Backbone.Model.prototype.initialize.apply(this, [attrs]);
        
        this.urlRoot = this.baseUrl() + '/osd';
    },
    
    initPlugins: function () {
        var that = this;
        
        $.each (this.pluginDef.models, function (iModel, model) {
            var pluginId = model.get('code');
            var plugin = model.get('plugin');
            
            that.pluginData[pluginId] = new Wat.Models.Plugin({}, {osdId: that.id, pluginId: pluginId});
        });
    },
    
    defaults: {
    },
    
    parse: function(response) {
        if (response.status && response.status != STATUS_SUCCESS) {
            response.error = response.message;
        }
        
        return response;
    },
    
    getPluginDef: function (pluginId) {
        var pluginModel = this.pluginDef.where({code: pluginId})[0];
        
        return pluginModel ? pluginModel.attributes : false;
    },
    
    // Get possible options of an attribute of type list of a plugin
    // - pluginAttr: Plugin and attribute Ids separated by dots
    //      I.E.: os.distro|execution_hooks.script
    getPluginAttrOptions: function (pluginAttr, enumCallback) {
        var [pluginId, attr] = pluginAttr.split('.');
        
        var plugin = this.getPluginDef(pluginId);
        
        if (!plugin) {
            return [];
        }
        
        var attrModel = {};
        $.each(plugin.values, function (i,v) {
            if (v.method == 'PUT') {
                $.each(v.model, function (ii, vv) {
                    if (vv.code == attr) {
                        attrModel = vv;
                        return false;
                    }
                });
                return false;
            }
        });
        
        if (attrModel.type == 'enum') {
            return attrModel.values;
        }
        
        var location = '/' + pluginId;
        var enums = new Wat.Collections.PluginEnums({location: location});
        enums.fetch({
            complete: function () {
                var listEnums = {};
                $.each(enums.models, function (i, model) {
                    listEnums[model.id] = model.attributes;
                    listEnums[model.id].value = model.get('name');
                });
                
                enumCallback(listEnums);
            }
        });
    },
    
    // Get possible options of a setting of type list form an attribute of type list of a plugin
    // - pluginAttr: Plugin and attribute Ids separated by dots
    //      I.E.: execution_hooks.script.hook
    getPluginAttrSettingOptions: function (pluginAttrSetting) {
        var [pluginId, attr, setting] = pluginAttrSetting.split('.');
        
        var plugin = this.getPluginDef(pluginId);
        
        if (plugin.plugin) {
            return plugin.plugin[attr].settings[setting].list_options;
        }
        else {
            return {};
        }
    },
});