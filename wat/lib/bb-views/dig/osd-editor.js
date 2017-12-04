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
                
                $('.' + that.cid + ' select.bb-os-conf-' + opts.assetType + '-assets').html(template);
                Wat.I.chosenElement('select.bb-os-conf-' + opts.assetType + '-assets', 'single100');
                
                var currentAssetId = Wat.CurrentView.OSDmodel.pluginData[opts.pluginId].get('id');
                if (currentAssetId) {
                    $('.' + that.cid + ' select.bb-os-conf-' + opts.assetType + '-assets>option[data-id="' + currentAssetId + '"]').prop('selected','selected');
                }
                $('.' + that.cid + ' select.bb-os-conf-' + opts.assetType + '-assets').trigger('chosen:updated');
                
                // Update preview of the selected asset
                that.updateAssetPreview($('.' + that.cid + ' select.js-asset-selector>option:checked'));
                
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
        
        if (target == 'assets') {
            this.goToAssetsManagement();
            return;
        }
        
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
        
        this.updateAssetPreview(row);
    },
    
    goToAssetsManagement: function (e) {
        var that = this;
        var assetType = e ? $(e.target).attr('data-asset-type') : 'icon';
        
        var dialogConf = {
            title: "Assets management",
            buttons : {
                "Close": function () {
                    Wat.I.closeDialog($(this));
                    
                    // Send primary dialog to front again
                    $('.ui-dialog').eq(0).css('z-index','');
                }
            },
            buttonClasses: ['fa fa-check js-button-close'],
            
            fillCallback: function (target) {
                $(target).addClass('bb-os-conf-assets').css('padding','30px');
                that.sectionViews.assets = new Wat.Views.OSDAssetsEditorView({massive: this.massive});
                
                $('.js-change-mode').val(assetType).trigger('chosen:updated').trigger('change');
            }
        };
        
        Wat.CurrentView.assetsDialog = Wat.I.dialog(dialogConf);

        // Add secondary dialog class to new dialog to give different look
        Wat.CurrentView.assetsDialog.parent().addClass('ui-dialog-secondary');
        Wat.CurrentView.assetsDialog.dialog("option", "position", {my: "center", at: "center", of: window});
        // Send primary dialog to back because jquery ui doesnt handle it properly
        $('.ui-dialog').eq(0).css('z-index','100');
    },
    
    updateAssetPreview: function (opt) {
        var that = this;
        
        var controlId = $(opt).attr('data-asset-type');
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
                        $('.' + that.cid + ' [data-preview-id="' + controlId + '"]').html(responseText.replace(/\n/g,"<br>").replace('World', url)).show();
                    },
                });
                break;
            case 'icon':
                if (assetId) {
                    $('.' + that.cid + ' [data-preview-id="' + controlId + '"]').html('<img src="' + url + '" style="width: 32px; display: block; margin: 50px auto;"></img>');
                }
                else {
                    $('.' + that.cid + ' [data-preview-id="' + controlId + '"]').html('');
                }
                break;
            case 'wallpaper':
                $('.' + that.cid + ' [data-preview-id="' + controlId + '"]').html('<img src="' + url + '" style="width: 90%; display: block; margin: 0 auto;"></img>');
                break;
            default:
                if ($(opt).attr('data-none')) {
                    $('.' + that.cid + ' [data-preview-id="' + controlId + '"]').html('');
                }
        }
        
        switch (type) {
            case 'icon':
            case 'wallpaper':
                // Show loading message for preview image until it is loaded
                if (assetId) {
                    $('.' + that.cid + ' .js-preview img').hide();
                    $('.' + that.cid + ' .js-data-preview-message').show();
                }
                $('.js-preview img').on('load', function () {
                    $('.' + that.cid + ' .js-preview img').show();
                    $('.' + that.cid + ' .js-data-preview-message').hide();
                });
                break;
        }
    },
});