Wat.Views.OSDEditorView = Wat.Views.DialogView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;

        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'click .js-os-editor-menu li': 'clickOSEditorMenu',
        'change input[type="checkbox"][js-autosave-field]': 'autoSaveCheck',
        'change .js-asset-selector': 'changeAssetSelector',
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
        this.sectionAppearenceView = new Wat.Views.OSDAppearenceEditorView({massive: this.massive});
        this.sectionPackagesView = new Wat.Views.OSDPackagesEditorView({massive: this.massive});
        this.sectionShortcutsView = new Wat.Views.OSDShortcutsEditorView({massive: this.massive});
        this.sectionSettingsView = new Wat.Views.OSDSettingsEditorView({massive: this.massive});
        this.sectionScriptsView = new Wat.Views.OSDScriptsEditorView({massive: this.massive});

        Wat.I.chosenElement('select.js-app-to-shortcut', 'single100');
        
        Wat.T.translate();
    },
    
    renderAssetsControl: function (opts) {
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
                
                $('.bb-os-conf-' + opts.assetType + '-assets').html(template);
                
                // Select first radio button
                $('input[type="radio"][name="' + opts.assetType + '"]').eq(0).trigger('click');
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
    },
    
    ////////////////////////////////////////////////////
    // Functions for single controls
    ////////////////////////////////////////////////////
    
    autoSaveCheck: function (e) {
        var that = this;
    
        var name = $(e.target).attr('name');
        var checked = $(e.target).is(':checked');
        
        var [pluginId, attrName] = name.split('.');
        
        // Save distro id
        var attributes = {};
        attributes['id'] = attrName;
        attributes[attrName] = checked;
        
        Wat.DIG.setPluginAttr({
            pluginId: pluginId,
            attributes: attributes
        }, function () {}, function () {});
    },
});