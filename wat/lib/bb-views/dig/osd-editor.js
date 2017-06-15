Wat.Views.OSDEditorView = Wat.Views.DialogView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'click .js-os-editor-menu': 'clickOSEditorMenu',
        'click .js-add-shortcut': 'addShortcut',
        'click .js-delete-shortcut': 'deleteShortcut',
        'click .js-update-shortcut': 'updateShortcut',
        'click .js-button-show-shortcut-details': 'toggleShortcutConfiguration',
        'click .js-add-starting-script': 'addScript',
        'click .js-delete-starting-script': 'deleteScript',
        'change input[type="checkbox"][js-autosave-field]': 'autoSaveCheck',
        'change .js-starting-script-mode': 'changeScriptMode'
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
        this.renderSectionAppearence();
        this.renderSectionPackages();
        this.renderSectionShortcuts();
        this.renderSectionSettings();
        this.renderSectionScripts();

        Wat.I.chosenElement('select.js-app-to-shortcut', 'single100');

        $("textarea").expanding();
        
        Wat.T.translate();
    },
    
    renderSectionAppearence: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorAppearance, {
                massive: this.massive
            }
        );

        $('.bb-os-conf-appearance').html(template);
    },
    
    renderSectionPackages: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorPackages, {
                massive: this.massive
            }
        );

        $('.bb-os-conf-packages').html(template);
        
        this.renderPackages();
    },
    
    renderPackages: function() {
        var params = {};
        params.whatRender = 'list';
        params.listContainer = '.bb-packages-wrapper';
        params.forceListActionButton = null;

        params.forceSelectedActions = {};
        params.block = 5;
        params.filters = {"tenant_id": this.elementId};
        Wat.CurrentView.embeddedViews = Wat.CurrentView.embeddedViews || {};
        Wat.CurrentView.embeddedViews.package = new Wat.Views.PackageListView(params);

        $.each (Wat.CurrentView.embeddedViews.package.events, function (actionSelector, func) {
            actionSelector = actionSelector.split(' ');
            var action = actionSelector.shift();
            var selector = actionSelector.join(' ');
            e = {
                target: $(selector)
            };
            Wat.B.bindEvent(action, selector, $.proxy(Wat.CurrentView.embeddedViews.package[func], Wat.CurrentView.embeddedViews.package), e);
        });
    },
    
    renderSectionShortcuts: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorShortcuts, {
                settings: Wat.CurrentView.settings,
                apps: Wat.CurrentView.apps,
                massive: this.massive
            }
        );

        $('.bb-os-conf-shortcuts').html(template);

        // Render rows with existent shortcuts
        var template = _.template(
            Wat.TPL.osConfigurationEditorShortcutsRows, {
                shortcuts: Wat.CurrentView.OSDmodel.get('shortcuts')
            }
        );

        $('.bb-os-conf-shortcuts-rows').html(template);
    },
    
    renderSectionSettings: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorSettings, {
                massive: this.massive,
                model: Wat.CurrentView.OSDmodel
            }
        );

        $('.bb-os-conf-settings').html(template);
    },
    
    renderSectionScripts: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorScripts, {
                massive: this.massive,
                model: Wat.CurrentView.OSDmodel
            }
        );

        $('.bb-os-conf-scripts').html(template);

        // Render rows with existent scripts
        var rows = _.template(
            Wat.TPL.osConfigurationEditorScriptsRows, {
                scripts: Wat.CurrentView.OSDmodel.get('scripts')
            }
        );

        $("table.js-scripts-list").append(rows);
        Wat.I.chosenElement('.js-starting-script-mode', 'single100');

        if (Wat.CurrentView.OSDmodel.get('scripts').length > 0) {
            $('table.js-scripts-list tr.js-scripts-empty').hide();
        }
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
    // Functions for shortcuts
    ////////////////////////////////////////////////////
    
    addShortcut: function (e) {
        var command = $('input[name="shortcut_command"]').val();
        var name = $('input[name="shortcut_name"]').val();
        var defaultIconUrl = "http://icons.iconarchive.com/icons/custom-icon-design/flatastic-11/256/Application-icon.png";
        
        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: 'shortcuts',
            osdId: this.params.osdId,
            attributes: {
                name: name,
                icon_url: defaultIconUrl,
                command: command
            }
        }, this.afterAddShortcut, function () {});
    },
    
    afterAddShortcut: function (e) {
        var response = JSON.parse(e.responseText);
        
        // Mock
        var command = $('input[name="shortcut_command"]').val();
        var name = $('input[name="shortcut_name"]').val();
        var defaultIconUrl = "http://icons.iconarchive.com/icons/custom-icon-design/flatastic-11/256/Application-icon.png";

        var newShortcut = {
            name: name,
            icon_url: defaultIconUrl,
            command: command,
            id: btoa(command + name)
        };
        // End Mock
        
        // Render new shortcut on shortcut list
        var template = _.template(
            Wat.TPL.osConfigurationEditorShortcutsRows, {
                shortcuts: [newShortcut]
            }
        );
        
        $('.bb-os-conf-shortcuts-new-rows').prepend(template);
        
        // Reset controls
        $('.shortcuts-form input[name="shortcut_command"]').val('');
        $('.shortcuts-form input[name="shortcut_name"]').val('');
        
        Wat.T.translate();
    },
    
    updateShortcut: function (e) {
        var id = $(e.target).attr('data-id');

        var newName = $('.js-editor-row input[name="shortcut_name"]').val();
        var newCommand = $('.js-editor-row input[name="shortcut_command"]').val();
        var newIcon = $('.js-editor-row input[name="shortcut_icon"]').val();

        // Update visible data
        $('.js-shortcut-row[data-id="' + id + '"] .js-shortcut-name').html(newName);
        $('.js-shortcut-row[data-id="' + id + '"] .js-shortcut-command').html(newCommand);
        $('.icon-bg[data-id="' + id + '"]').css('background-image','url(' + newIcon + ')');

        // Update hidden forms
        $('[data-form-field-name="name"]').val(newName);
        $('[data-form-field-name="command"]').val(newCommand);
        $('[data-form-field-name="icon_url"]').val(newIcon);

        $('.js-button-show-shortcut-details[data-id="' + id + '"]').trigger('click');
        
        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: 'shortcuts',
            osdId: this.params.osdId,
            attributes: {
                id: id,
                name: newName,
                command: newCommand,
                newIcon:  newIcon
                
            }
        }, function () {}, function () {});
    },
    
    deleteShortcut: function (e) {
        var id = $(e.target).attr('data-id');
        $('.js-shortcut-row[data-id="' + id + '"]').remove();
        $('.js-editor-row[data-id="' + id + '"]').remove();
        
        // Delete plugin element
        Wat.DIG.deletePluginListElement({
            pluginId: 'shortcuts',
            osdId: this.params.osdId,
            attributes: {id: id}
        }, function () {}, function () {});
    },
    
    toggleShortcutConfiguration: function (e) {
        if ($(e.target).hasClass('disabled')) {
            return;
        }

        var id = $(e.target).attr('data-id');

        // Toggle icons
        if ($(e.target).hasClass('fa-chevron-down')) {
            $(e.target).removeClass('fa-chevron-down').addClass('fa-chevron-up');
        }
        else {
            $(e.target).removeClass('fa-chevron-up').addClass('fa-chevron-down');
        }

        // Toggle rows
        $('tr.js-editor-row[data-id="' + id + '"]').toggle();
    },
    
    ////////////////////////////////////////////////////
    // Functions for scripts
    ////////////////////////////////////////////////////
        
    addScript: function (e) {
        if (!$('.js-starting-script').val()) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }

        var fileName = $('.js-starting-script')[0].files[0].name;

        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: 'execution_hooks',
            osdId: this.params.osdId,
            attributes: {
                name: fileName
            }
        }, this.afterAddScript, function () {});
    },
    
    
    afterAddScript: function (e) {
        // Mock
        var fileName = $('.js-starting-script')[0].files[0].name;
        var id = btoa(fileName);
        var execution_hook = 'first_connection';
        // End mock
        
        // Add starting script row
        var newRow = _.template(
            Wat.TPL.osConfigurationEditorScriptsRows, {
                scripts: [{
                    id: id,
                    name: fileName,
                    execution_hook : execution_hook
                }]
            }
        );

        $("table.js-scripts-list").append(newRow);
        Wat.I.chosenElement('.js-starting-script-mode', 'single100');

        $('table.js-scripts-list tr.js-scripts-empty').hide();

        Wat.T.translate();

        $('.js-starting-script').val('');
    },
    
    deleteScript: function (e) {
        var id = $(e.target).attr('data-id');
        $(e.target).closest('tr').remove();

        var nRows = $('table.js-scripts-list tr').length;

        if (nRows == 1) {
            $('table.js-scripts-list tr.js-scripts-empty').show();
        }
        
        // Delete plugin element
        Wat.DIG.deletePluginListElement({
            pluginId: 'execution_hooks',
            osdId: this.params.osdId,
            attributes: {id: id}
        }, function () {}, function () {});
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
    }
});