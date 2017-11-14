Wat.Views.OSDHooksEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
        
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'change .js-starting-script-mode': 'changeHookMode',
        'click .js-add-starting-script': 'addHook',
        'click .js-delete-hook': 'deleteHook',
        'click .js-save-hook': 'saveHook',
        'click .js-button-open-hook-configuration': 'openHookConfiguration',
        'click .js-button-close-hook-configuration': 'closeHookConfiguration'
    },
    
    ////////////////////////////////////////////////////
    // Functions for render
    ////////////////////////////////////////////////////
    
    render: function () {
        var that = this;
        
        if (!Wat.CurrentView.OSDmodel.pluginData.hook) {
            return;
        }
        
        var template = _.template(
            Wat.TPL.osConfigurationEditorHooks, {
                massive: this.massive,
                model: Wat.CurrentView.OSDmodel,
                hookOptions: Wat.CurrentView.OSDmodel.getPluginAttrSettingOptions('execution_hooks.script.hook'),
                cid: this.cid,
                assetType: 'script',
            }
        );
        
        $('.bb-os-conf-hooks').html(template);
        
        Wat.CurrentView.OSDmodel.pluginData.hook.fetch({
            success: function () {
                // Fetch scripts and load images on list
                that.renderAssetsControl({
                    assetType: 'script',
                    pluginId: 'hook',
                    afterRender: function (availableHooksCollection) {
                        // Convert scripts collection to easier hash to be accesed within the template
                        var scripts = {};
                        $.each(availableHooksCollection.models, function (i, model) {
                                scripts[model.get('id')] = model;
                        });
                        
                        that.renderSectionHooksRows(scripts, Wat.CurrentView.OSDmodel.pluginData.hook.attributes);
                    }
                });

                $('.' + that.cid + ' .js-upload-mode').hide();
            }
        });
    },
    
    renderSectionHooksRows: function (scripts, hooks) {
        // Render rows with existent scripts
        var template = _.template(
            Wat.TPL.osConfigurationEditorHooksRows, {
                hooks: hooks,
                cid: this.cid,
                scripts: scripts
            }
        );
        
        $('.bb-os-conf-hooks-rows').html(template);
        
        $('.' + this.cid + ' .js-asset-check').eq(0).prop('checked', true).trigger('change');
        
        Wat.T.translate();
    },
    
    afterLoadSection: function () {
        this.showSelectMode();
    },
    
    ////////////////////////////////////////////////////
    // Functions for interface
    ////////////////////////////////////////////////////
    
    openHookConfiguration: function (e) {
        var that = this;
        
        if ($(e.target).hasClass('disabled')) {
            return;
        }
        
        var id = $(e.target).attr('data-id');
        
        var hook = {
                id: id
            };
        
        if (id > 0) {
            $.each(Wat.CurrentView.OSDmodel.pluginData.hook.attributes, function (i, hk) {
                if (hk.id == parseInt(id)) {
                    hook = hk;
                }
            });
        }
        
        var hookTypes = Wat.CurrentView.OSDmodel.getPluginAttrOptions('hook.hookType');
        
        // Render edit hook row
        var template = _.template(
            Wat.TPL.osConfigurationEditorHooksRowsEdit, {
                hook: hook,
                hookTypes: Wat.CurrentView.OSDmodel.getPluginAttrOptions('hook.hookType'),
                cid: this.cid
            }
        );
        
        $('.' + this.cid + '.bb-os-conf-hooks-rows-editor').html(template);
        
        Wat.I.chosenElement('.' + this.cid + ' select.js-hook-type', 'single100');
        Wat.I.chosenElement('.' + this.cid + ' select.js-hook', 'single100');
        
        this.renderAssetsControl({ 
            assetType: 'script',
            pluginId: 'hook',
            afterRender: function (availableHooksCollection) {
                $('.' + that.cid + ' .js-os-conf-hook').html('');
                
                if (availableHooksCollection.models.length == 0) {
                    $('.' + that.cid + ' .js-os-conf-hook').append('<option data-i18n="None">None</option>');
                }
                
                $.each(availableHooksCollection.models, function (i, hookModel) {
                    $('.' + that.cid + ' .js-os-conf-hook').append('<option value="' + hookModel.get('id') + '">' + hookModel.get('name') + '</option>');
                });
                
                $('.' + that.cid + ' .js-os-conf-hook').trigger('chosen:updated');

                $('.' + that.cid + ' .js-osf-conf-editor').hide();
                
                if (id > 0) {
                    $('.' + that.cid + ' .js-hook-name-edition').html(hook.name);
                    $('.' + that.cid + ' .js-os-conf-hooks-rows-editor--edit').show();
                    
                    // Select hook script
                    $('.' + that.cid + ' .js-os-conf-hook').val(hook.idAsset).trigger('chosen:updated').trigger('change');
                }
                else {
                    $('.' + that.cid + ' .js-os-conf-hooks-rows-editor--new').show();
                }
                
                $('.' + that.cid + ' .js-os-conf-hooks-rows-editor').show();
                $('.' + that.cid + ' .js-asset-switch-buttonset').hide();
            }
        });
    },
    
    closeHookConfiguration: function (e) {
        if ($(e.target).hasClass('disabled')) {
            return;
        }
        
        this.showSelectMode();
    },
    
    changeHookMode: function (e) {
        var newMode = $(e.target).val();
        var id = $(e.target).attr('data-id');

        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: 'execution_hooks',
            osdId: this.params.osdId,
            attributes: {
                id: id,
                mode: newMode
            }
        }, function () {}, function () {});
    },
    
    showSelectMode: function (e) {
        Wat.Views.OSDEditorView.prototype.showSelectMode.apply(this, [e]);
        
        // Keep preview hidden
        $('.' + this.cid + ' .js-preview').hide();
        
        // Keep editor hidden
        $('.' + this.cid + ' .bb-os-conf-hooks-rows-editor').html('');
        $('.' + this.cid + ' .js-os-conf-hooks-rows-editor').hide();
        $('.' + this.cid + ' .js-asset-switch-buttonset').show();
        $('.' + this.cid + ' .js-os-conf-hooks-rows-editor--new, .js-os-conf-hooks-rows-editor--edit').hide();
    },
    
    ////////////////////////////////////////////////////
    // Functions for hooks management
    ////////////////////////////////////////////////////
    
    saveHook: function (e) {
        var hookId = $(e.target).attr('data-id');
        
        var idAsset = $('select.js-hook[data-id="' + hookId + '"]').val();
        var hookType = $('select.js-hook-type[data-id="' + hookId + '"]').val();
        var hookName = $('input[data-id="' + hookId + '"][name="hook_name"]').val();
        
        var attributes = {
            name: hookName,
            idAsset: idAsset,
            hookType: hookType
        };
        
        var afterCallback = this.afterAddHook;
        
        if (hookId > 0) {
            attributes.id = hookId;
            afterCallback = this.afterUpdateHook;
        }
        
        // Save hook
        Wat.DIG.setPluginListElement({
            pluginId: 'hook',
            osdId: Wat.CurrentView.OSDmodel.get('id'),
            attributes: attributes
        }, afterCallback, function () {});
    },
    
    deleteHook: function (e) {
        var id = $(e.target).attr('data-id');
        
        // Delete plugin element
        Wat.DIG.deletePluginListElement({
            pluginId: 'hook',
            osdId: Wat.CurrentView.OSDmodel.get('id'),
            attributes: {id: id}
        }, this.afterDeleteHook, function () {});
    },
    
    afterAddHook: function (e) {
        var response = JSON.parse(e.responseText);
        
        Wat.I.M.showMessage({message: i18n.t('Successfully created'), messageType: 'success'});
        
        Wat.CurrentView.editorView.softwareEditorView.sectionViews.hooks.afterSaveHook(e);
    },
    
    afterUpdateHook: function (e) {
        var response = JSON.parse(e.responseText);
        
        Wat.I.M.showMessage({message: i18n.t('Successfully updated'), messageType: 'success'});
        
        Wat.CurrentView.editorView.softwareEditorView.sectionViews.hooks.afterSaveHook(e);
    },
    
    afterDeleteHook: function (e) {
        var response = JSON.parse(e.responseText);
        
        Wat.I.M.showMessage({message: i18n.t('Successfully deleted'), messageType: 'success'});
        
        Wat.CurrentView.editorView.softwareEditorView.sectionViews.hooks.afterSaveHook(e);
    },
    
    afterSaveHook: function (e) {
        Wat.CurrentView.OSDmodel.pluginData.hook.clear();
        
        Wat.CurrentView.editorView.softwareEditorView.sectionViews.hooks.render();
    },
    
    changeAssetManagerSelector: function(e) {
        $('.' + this.cid + ' .js-data-preview-box').html('Loading');
        
        Wat.Views.OSDEditorView.prototype.changeAssetManagerSelector.apply(this, [e]);
    },
});