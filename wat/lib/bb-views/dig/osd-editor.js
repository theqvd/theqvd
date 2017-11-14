Wat.Views.OSDEditorView = Wat.Views.DialogView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;

        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'click .js-os-editor-menu li': 'clickOSEditorMenu',
        'click .js-go-to-assets-management': 'goToAssetsManagement',
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
            assets: new Wat.Views.OSDAssetsEditorView({massive: this.massive}),
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
                    Wat.TPL.osConfigurationEditorAssetsOptions, {
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
                    Wat.TPL.osConfigurationEditorAssetsRows, {
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
    
    showSelectMode: function (e) {
        $('.' + this.cid + ' .js-upload-mode').hide();
        $('.' + this.cid + ' .js-select-mode').show();
        
        $('.' + this.cid + ' .js-change-mode').val('selection').trigger('chosen:updated');
    },
    
    changeAssetManagerSelector: function (e) {
        var row = $(e.target).closest('tr');
        
        $('tr').removeClass('selected-row');
        $(row).addClass('selected-row');
        
        Wat.DIG.updateAssetPreview(row);
    },
    
    goToAssetsManagement: function (e) {
        var assetType = $(e.target).attr('data-asset-type');
        $('.lateral-menu-option[data-target="assets"]').trigger('click');
        
        $('.js-change-mode').val(assetType).trigger('chosen:updated').trigger('change');
    }
});