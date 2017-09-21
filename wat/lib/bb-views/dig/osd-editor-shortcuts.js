Wat.Views.OSDShortcutsEditorView = Wat.Views.OSDEditorView.extend({
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'click .js-add-shortcut': 'addShortcut',
        'click .js-delete-shortcut': 'deleteShortcut',
        'click .js-save-shortcut': 'saveShortcut',
        'click .js-button-open-shortcut-configuration': 'openShortcutConfiguration',
        'click .js-button-close-shortcut-configuration': 'closeShortcutConfiguration',
        'click .js-icon-name': 'clickAssetName',
        'change .js-asset-check': 'changeAssetManagerSelector',
        'change .js-asset-selector': 'changeAssetSelector',
        'click .js-upload-asset': 'createIcon',
        'click .js-delete-selected-asset': 'deleteIcon',
        'click .js-show-upload': 'showUploadControl',
        'click .js-hide-upload': 'hideUploadControl',
        'change .js-change-mode': 'changeMode',
        'change .js-list-shortcuts .js-asset-selector[data-control-id="icon"]': 'changeIcon'
    },
    
    render: function () {
        var that = this;
        
        var template = _.template(
            Wat.TPL.osConfigurationEditorShortcuts, {
                massive: this.massive,
                cid: this.cid
            }
        );
        
        $('.bb-os-conf-shortcuts').html(template);
        
        Wat.I.chosenElement('select.js-change-mode', 'single100');
        
        var template = _.template(
            Wat.TPL.osConfigurationEditorAssetUploadControl, {
            }
        );
        
        $('.' + that.cid + ' .bb-upload-control').html(template);
        
        Wat.CurrentView.OSDmodel.pluginData.shortcut.fetch({
            success: function () {
                // Render rows with existent shortcuts
                var template = _.template(
                    Wat.TPL.osConfigurationEditorShortcutsRows, {
                        shortcuts: Wat.CurrentView.OSDmodel.pluginData.shortcut.attributes,
                        cid: that.cid
                    }
                );
                
                $('.bb-os-conf-shortcuts-rows').html(template);
                
                // Fetch icons and load images on list
                that.renderAssetsControl({
                    assetType: 'icon',
                    pluginId: 'shortcut',
                    afterRender: function (assets) {
                        $.each($('.js-icon-bg'), function (i, icon) {
                            var idAsset = $(icon).attr('data-id-asset');
                            
                            $.each(assets.models, function (i, model) {
                                if (model.get('id') == idAsset) {
                                    $(icon).css('background-image', 'url(' + model.get('url') + ')');
                                }
                            });
                        });
                    }
                });

                $('.' + that.cid + ' .js-upload-mode').hide();
            }
        });
    },
    
    afterLoadSection: function () {
        this.showSelectMode();
    },
    
    ////////////////////////////////////////////////////
    // Functions for interface changes
    ////////////////////////////////////////////////////
    
    changeIcon: function (e) {
        var shortcutId = $(e.target).attr('data-id');
        var iconUrl = $(e.target).find('option:selected').attr('data-url');
        
        $('.js-icon-bg[data-id="' + shortcutId + '"]').css('background-image', 'url(' + iconUrl + ')');
    },
    
    ////////////////////////////////////////////////////
    // Functions for shortcuts management
    ////////////////////////////////////////////////////
    
    saveShortcut: function (e) {
        var shortcutId = $(e.target).attr('data-id');
        
        var command = $('input[name="shortcut_command"][data-id="' + shortcutId + '"]').val();
        var name = $('input[name="shortcut_name"][data-id="' + shortcutId + '"]').val();
        var iconId = $('select.js-asset-selector[data-id="' + shortcutId + '"]').val();
        
        var attributes = {
            idAsset: iconId, 
            name: name, 
            code: command
        };
        
        var afterCallback = this.afterAddShortcut;
        
        if (shortcutId > 0) {
            attributes.id = shortcutId;
            afterCallback = this.afterUpdateShortcut;
        }
        
        // Save shortcut
        Wat.DIG.setPluginListElement({
            pluginId: 'shortcut',
            osdId: Wat.CurrentView.OSDmodel.get('id'),
            attributes: attributes
        }, afterCallback, function () {});
    },
    
    deleteShortcut: function (e) {
        var id = $(e.target).attr('data-id');
        
        // Delete plugin element
        Wat.DIG.deletePluginListElement({
            pluginId: 'shortcut',
            osdId: Wat.CurrentView.OSDmodel.get('id'),
            attributes: {id: id}
        }, this.afterDeleteShortcut, function () {});
    },
    
    afterAddShortcut: function (e) {
        var response = JSON.parse(e.responseText);
        
        Wat.I.M.showMessage({message: i18n.t('Successfully created'), messageType: 'success'});
        
        Wat.CurrentView.editorView.softwareEditorView.sectionViews.shortcuts.afterSaveShortcut(e);
    },
    
    afterUpdateShortcut: function (e) {
        var response = JSON.parse(e.responseText);
        
        Wat.I.M.showMessage({message: i18n.t('Successfully updated'), messageType: 'success'});
        
        Wat.CurrentView.editorView.softwareEditorView.sectionViews.shortcuts.afterSaveShortcut(e);
    },
    
    afterDeleteShortcut: function (e) {
        var response = JSON.parse(e.responseText);
        
        Wat.I.M.showMessage({message: i18n.t('Successfully deleted'), messageType: 'success'});
        
        Wat.CurrentView.editorView.softwareEditorView.sectionViews.shortcuts.afterSaveShortcut(e);
    },
    
    afterSaveShortcut: function (e) {
        Wat.CurrentView.OSDmodel.pluginData.shortcut.clear();
        
        Wat.CurrentView.editorView.softwareEditorView.sectionViews.shortcuts.render();
    },
    
    openShortcutConfiguration: function (e) {
        var that = this;
        
        if ($(e.target).hasClass('disabled')) {
            return;
        }
        
        var id = $(e.target).attr('data-id');
        
        var shortcut = {
                id: id
            };
        
        if (id > 0) {
            $.each(Wat.CurrentView.OSDmodel.pluginData.shortcut.attributes, function (i, sc) {
                if (sc.id == parseInt(id)) {
                    shortcut = sc;
                }
            });
        }
        
        // Render edit shortcut row
        var template = _.template(
            Wat.TPL.osConfigurationEditorShortcutsRowsEdit, {
                shortcut: shortcut,
                cid: this.cid
            }
        );
        
        $('.' + this.cid + ' .bb-os-conf-shortcuts-rows-editor').html(template);
        
        this.renderAssetsControl({ 
            assetType: 'icon',
            pluginId: 'shortcut',
            afterRender: function () {
                $('.' + that.cid + ' .js-osf-conf-editor').hide();
                
                if (id > 0) {
                    $('.' + that.cid + ' .js-shortcut-name-edition').html(shortcut.name);
                    $('.' + that.cid + ' .js-os-conf-shortcuts-rows-editor--edit').show();
                    
                    // Select shortcut icon
                    $('.' + that.cid + ' .js-asset-selector').val(shortcut.idAsset).trigger('chosen:updated').trigger('change');
                }
                else {
                    $('.' + that.cid + ' .js-os-conf-shortcuts-rows-editor--new').show();
                }
                
                $('.' + that.cid + ' .js-os-conf-shortcuts-rows-editor').show();
                $('.' + that.cid + ' .js-asset-switch-buttonset').hide();
            }
        });
    },
    
    closeShortcutConfiguration: function (e) {
        if ($(e.target).hasClass('disabled')) {
            return;
        }
        
        this.showSelectMode();
    },
    
    showSelectMode: function (e) {
        Wat.Views.OSDEditorView.prototype.showSelectMode.apply(this, [e]);
        
        // Keep editor hidden
        $('.' + this.cid + ' .bb-os-conf-shortcuts-rows-editor').html('');
        $('.' + this.cid + ' .js-os-conf-shortcuts-rows-editor').hide();
        $('.' + this.cid + ' .js-asset-switch-buttonset').show();
        $('.' + this.cid + ' .js-os-conf-shortcuts-rows-editor--new, .js-os-conf-shortcuts-rows-editor--edit').hide();
    },
    
    ////////////////////////////////////////////////////
    // Functions for icons (assets) management
    ////////////////////////////////////////////////////
    
    createIcon: function (e) {
        var that = this;
        
        var name = $('.' + this.cid + ' input[name="asset_name"]').val();
        
        if (!name) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }
        
        
        this.assetModel = new Wat.Models.Asset({
            name: name,
            assetType: 'icon'
        });
        
        this.assetModel.save().complete(
            function (e) {
                that.uploadIcon(that.assetModel.id);
            }
        );
    },
    
    uploadIcon: function (assetId) {
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
                assetType: 'icon',
                pluginId: 'shortcuts',
                afterRender: function () {
                    // Select uploaded element
                    $('.' + this.cid + ' [data-id="' + assetId + '"]>td>input.js-asset-check').trigger('change').prop('checked', true);
                }
            });
            
            Wat.I.M.showMessage({message: i18n.t('Successfully uploaded'), messageType: 'success'});
            
            // Hide upload control
            that.hideUploadControl();
        });
    },
    
    deleteIcon: function (e) {
        var that = this;
        
        var id = $('.' + this.cid + ' .js-asset-check:checked').val();
        
        var assetModel = new Wat.Models.Asset({
            id: id
        });
        
        assetModel.destroy({
            success: function () {
                that.renderAssetsControl({ 
                    assetType: 'icon',
                    pluginId: 'shortcut'
                });
                
                Wat.I.M.showMessage({message: i18n.t('Successfully deleted'), messageType: 'success'});
            },
            error: function () {
                Wat.I.M.showMessage({message: i18n.t('Error deleting'), messageType: 'error'});
            }
        });
    },
});