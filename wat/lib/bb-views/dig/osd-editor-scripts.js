Wat.Views.OSDScriptsEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
        
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'change .js-starting-script-mode': 'changeScriptMode',
        'click .js-script-name': 'clickAssetName',
        'click .js-show-select-mode': 'showSelectMode',
        'click .js-show-manage-mode': 'showManageMode',
        'click .js-add-starting-script': 'addScript',
        'click .js-show-upload': 'showUploadControl',
        'click .js-hide-upload': 'hideUploadControl',
        'click .js-upload-asset': 'createScript',
        'click .js-delete-selected-asset': 'deleteScript',
        'change .js-asset-check': 'changeAssetManagerSelector',
        'change .js-asset-selector': 'changeAssetSelector',
    },
    
    ////////////////////////////////////////////////////
    // Functions for render
    ////////////////////////////////////////////////////
    
    render: function () {
        var that = this;
        
        var template = _.template(
            Wat.TPL.osConfigurationEditorScripts, {
                massive: this.massive,
                model: Wat.CurrentView.OSDmodel,
                hookOptions: Wat.CurrentView.OSDmodel.getPluginAttrSettingOptions('execution_hooks.script.hook'),
                cid: this.cid,
                assetType: 'script',
            }
        );

        $('.bb-os-conf-scripts').html(template);
        
        this.renderAssetsControl({
            assetType: 'script',
            pluginId: 'execution_hooks',
            afterRender: function (availableScriptsCollection) {
                that.renderSectionScriptsRows(Wat.CurrentView.OSDmodel.get('scripts'), availableScriptsCollection.models);
            }
        });
    },
    
    renderSectionScriptsRows: function (scripts, availableScripts) {
        // Render rows with existent scripts
        var rows = _.template(
            Wat.TPL.osConfigurationEditorScriptsRows, {
                scripts: scripts,
                hookOptions: Wat.CurrentView.OSDmodel.getPluginAttrSettingOptions('execution_hooks.script.hook'),
                availableScripts: availableScripts
            }
        );

        $('table.js-scripts-list').html(rows);
        Wat.I.chosenElement('.js-starting-script', 'single100');
        Wat.I.chosenElement('.js-starting-script-mode', 'single100');
        
        Wat.T.translate();
        
        $('.' + this.cid + ' .js-upload-mode').hide();
        $('.' + this.cid + ' .js-preview').hide();
    },
    
    addScript: function (finishCallback) {
        var id = $('.js-starting-script').val();
        
        if (!id) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }
        
        var row = $('tr[data-control-id][data-id="' + id + '"]');
        
        var fileName = $('.js-starting-script option:checked').html();
        var execution_hook = $('.js-starting-script-mode').val();

        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: 'execution_hooks',
            osdId: this.params.osdId,
            attributes: {
                name: fileName,
                hook: execution_hook
            }
        }, this.afterAddScript, finishCallback);
    },
    
    afterAddScript: function (e) {
        // Mock
        var id = $('.js-starting-script').val();
        var row = $('tr[data-control-id][data-id="' + id + '"]');
        var fileName = $('.js-starting-script option:checked').html();
        var execution_hook = $('.js-starting-script-mode').val();
        // End mock
        
        // Add starting script row
        var newRow = _.template(
            Wat.TPL.osConfigurationEditorScriptsRows, {
                scripts: [{
                    id: id,
                    name: fileName,
                    execution_hook : execution_hook,
                    availableScripts: Wat.CurrentView.OSDmodel.pluginDef.where({code: 'execution_hooks'})[0].attributes.plugin.script.list_files
                }],
                hookOptions: Wat.CurrentView.OSDmodel.getPluginAttrSettingOptions('execution_hooks.script.hook')
            }
        );

        Wat.CurrentView.OSDmodel.attributes.scripts.push({
            id: id,
            name: fileName,
            execution_hook : execution_hook
        });
        
        Wat.CurrentView.editorView.softwareEditorView.sectionViews.scripts.renderSectionScriptsRows(Wat.CurrentView.OSDmodel.get('scripts'));

        $('.js-starting-script').val('');
    },
    
    afterDeleteScript: function (e) {
        var scripts = Wat.CurrentView.OSDmodel.get('scripts');
        
        Wat.CurrentView.editorView.softwareEditorView.sectionViews.scripts.renderSectionScriptsRows(scripts);
    },
    
    changeScriptMode: function (e) {
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
        
        $('.' + this.cid + ' .js-preview').hide();
    },
    
    showManageMode: function (e) {
        Wat.Views.OSDEditorView.prototype.showManageMode.apply(this, [e]);
        
        $('.' + this.cid + ' .js-preview').show();
    },
    
    createScript: function (e) {
        var that = this;
        
        var name = $('.' + this.cid + ' input[name="asset_name"]').val();
        
        if (!name) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }
        
        this.assetModel = new Wat.Models.Asset({
            name: name,
            assetType: 'script'
        });
        
        this.assetModel.save().complete(
            function (e) {
                that.uploadScript(that.assetModel.id);
            }
        );
    },
    
    uploadScript: function (assetId) {
        var that = this;
        
        this.assetFileModel = new Wat.Models.AssetFile({
            id: assetId
        });
        
        var file = $('.' + this.cid + ' input[name="asset_file"]')[0].files[0];
        
        if (!file) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }
        
        var data = new FormData();
        data.append('fileUpload', file);
        
        this.assetFileModel.save({
            data: data,
        }).complete(function () {
            that.renderAssetsControl({ 
                assetType: 'script',
                pluginId: 'desktop',
                afterRender: function () {
                    // Select uploaded element
                    $('.' + this.cid + ' [data-id="' + assetId + '"]>td>input.js-asset-check').trigger('change').prop('checked', true);
                }
            });
            
            Wat.I.M.showMessage({message: i18n.t('Successfully created'), messageType: 'success'});
            
            // Hide upload control
            that.hideUploadControl();
            
            // Reload combo list with available scripts
            that.renderAssetsControl({
                assetType: 'script',
                pluginId: 'execution_hooks'
            });
        });
    },
    
    deleteScript: function (e) {
        var that = this;
        
        var id = $('.' + this.cid + ' .js-asset-check:checked').val();
        
        var assetModel = new Wat.Models.Asset({
            id: id
        });
        
        assetModel.destroy({
            success: function () {
                that.renderAssetsControl({ 
                    assetType: 'script',
                    pluginId: 'desktop'
                });
                
                Wat.I.M.showMessage({message: i18n.t('Successfully deleted'), messageType: 'success'});
            },
            error: function () {
                Wat.I.M.showMessage({message: i18n.t('Error deleting'), messageType: 'error'});
            }
        });
    },
    
    changeAssetManagerSelector: function(e) {
        $('.' + this.cid + ' .js-data-preview-box').html('Loading');
        
        Wat.Views.OSDEditorView.prototype.changeAssetManagerSelector.apply(this, [e]);
    }
});