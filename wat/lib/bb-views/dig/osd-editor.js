Wat.Views.OSDEditorView = Wat.Views.DialogView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;

        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'click .js-os-editor-menu li': 'clickOSEditorMenu',
    },
    
    ////////////////////////////////////////////////////
    // Functions for render
    ////////////////////////////////////////////////////
    
    render: function () {
        Wat.Views.DialogView.prototype.render.apply(this);
        
        // Add common parts of editor to dialog
        var template = _.template(
            Wat.TPL.osConfigurationEditor, {
                osfId: this.params.osfId,
                massive: this.params.massive
            }
        );
        
        $(this.el).html(template);
        
        // Render sections
        this.sectionViews = {
            settings: new Wat.Views.OSDSettingsEditorView({massive: this.massive}),
            packages: new Wat.Views.OSDPackagesEditorView({massive: this.massive}),
            shortcuts: new Wat.Views.OSDShortcutsEditorView({massive: this.massive}),
            appearance: new Wat.Views.OSDAppearenceEditorView({massive: this.massive}),
            hooks: new Wat.Views.OSDHooksEditorView({massive: this.massive}),
        };
        
        Wat.I.chosenElement('select.js-app-to-shortcut', 'single100');
        
        Wat.T.translate();
    },
    
    renderAssetsControl: function (opts) {
        var that = this;
        
        var assets = new Wat.Collections.Assets(null, {
            filter: {
                type: opts.assetType
            } 
        });
        
        assets.fetch({
            complete: function () {
                var template = _.template(
                    Wat.TPL.osConfigurationEditorAssetOptions, {
                        models: assets.models,
                        assetType: opts.assetType,
                        pluginId: opts.pluginId
                    }
                );
                
                $('select.bb-os-conf-' + opts.assetType + '-assets').html(template);
                Wat.I.chosenElement('select.bb-os-conf-' + opts.assetType + '-assets', 'single100');
                
                var currentAssetId = Wat.CurrentView.OSDmodel.pluginData[opts.pluginId].get('id');
                if (currentAssetId) {
                    $('select.bb-os-conf-' + opts.assetType + '-assets>option[data-id="' + currentAssetId + '"]').prop('selected','selected');
                }
                $('select.bb-os-conf-' + opts.assetType + '-assets').trigger('chosen:updated');
                
                // Update preview of the selected asset
                Wat.DIG.updateAssetPreview($('.' + that.cid + ' select.js-asset-selector>option:checked'));
                
                var template = _.template(
                    Wat.TPL.osConfigurationEditorAssetRows, {
                        models: assets.models,
                        assetType: opts.assetType,
                        pluginId: opts.pluginId
                    }
                );
                
                $('table.bb-os-conf-' + opts.assetType + '-assets').html(template);
                
                Wat.T.translate();
                
                $('.' + that.cid + ' .js-asset-check').eq(0).prop('checked',true).trigger('change');
                
                if (opts.afterRender) {
                    opts.afterRender(assets);
                }
            }
        });
    },
    
    ////////////////////////////////////////////////////
    // Functions for menu
    ////////////////////////////////////////////////////
    
    clickOSEditorMenu: function (e) {
        target = $(e.target).attr('data-target') || $(e.target).parent().attr('data-target');
        
        $('li.lateral-menu-option').removeClass('lateral-menu-option--selected');
        $('li.js-lateral-menu-sub-div').hide();
        $('.js-os-editor-panel').hide();
        $('li.lateral-menu-option[data-target="' + target + '"]').addClass('lateral-menu-option--selected');
        $('li.js-lateral-menu-sub-div[data-from-menu="' + target +'"]').show();
        $('.js-os-editor-panel[data-target="' + target + '"]').show();
        
        this.sectionViews[target].afterLoadSection();
    },
    
    // Hook to execute code when section is loaded from menu
    afterLoadSection: function () {
    },
    
    ////////////////////////////////////////////////////
    // Functions for single controls
    ////////////////////////////////////////////////////
    
    changeMode: function (e) {
        switch($(e.target).val()) {
            case 'manage':
                this.showManageMode();
                break;
            case 'selection':
                this.showSelectMode();
                break;
        }
    },
    
    showSelectMode: function (e) {
        this.hideUploadControl();
        $('.' + this.cid + ' .js-upload-mode').hide();
        $('.' + this.cid + ' .js-select-mode').show();
        
        $('.' + this.cid + ' .js-change-mode').val('selection').trigger('chosen:updated');
    },
    
    showManageMode: function (e) {
        $('.' + this.cid + ' .js-upload-mode').show();
        $('.' + this.cid + ' .js-select-mode').hide();
        
        $('.' + this.cid + ' input[name="asset_name"]').val('');
        $('.' + this.cid + ' input[name="asset_file"]').val('');
        
        $('.' + this.cid + ' .js-change-mode').val('manage').trigger('chosen:updated');
        $('.' + this.cid + ' .js-asset-check:checked').trigger('change');
    },
    
    showUploadControl: function (e) {
        $('.' + this.cid + ' .js-upload-control').show();
        $('.' + this.cid + ' .js-asset-switch-buttonset').hide();
        $('.' + this.cid + ' .js-osf-conf-editor').hide();
    },
    
    hideUploadControl: function (e) {
        $('.' + this.cid + ' .js-upload-control').hide();
        $('.' + this.cid + ' .js-asset-switch-buttonset').show();
        $('.' + this.cid + ' .js-osf-conf-editor').show();
        this.showManageMode();
    },
    
    changeAssetManagerSelector: function (e) {
        var row = $(e.target).closest('tr');
        
        $('tr').removeClass('selected-row');
        $(row).addClass('selected-row');
        
        Wat.DIG.updateAssetPreview(row);
    },
    
    changeAssetSelector: function (e) {
        var opt = $(e.target).find('option:checked');
        
        Wat.DIG.updateAssetPreview(opt);
        
        var pluginId = $(opt).attr('data-plugin-id');
        
        var setCallback = function () {};
        
        switch(pluginId) {
            case 'wallpaper':
                    var id = $(opt).attr('data-id');
                    var name = $(opt).attr('data-name');
                    var url = $(opt).attr('data-url');
                    setCallback = this.afterSetWallpaper;
                break;
            default:
                return;
        }
        
        // If new option is None, element will be deleted
        if ($(opt).attr('data-none')) {
            // Save plugin element
            Wat.DIG.deletePluginListElement({
                pluginId: 'wallpaper',
                osdId: Wat.CurrentView.OSDmodel.id,
                attributes: {
                    pluginId: pluginId,
                    id: Wat.CurrentView.OSDmodel.pluginData.wallpaper.get('id')
                }
            }, setCallback, function () {});
            
            return;
        }
        
        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: pluginId,
            osdId: Wat.CurrentView.OSDmodel.id,
            attributes: {
                id: id,
                name: name,
                url: url
            }
        }, setCallback, function () {});
    },
    
    clickAssetName: function (e) {
        // Select this script
        $(e.target).parent().find('input[type="radio"]').trigger('click');
    }
});