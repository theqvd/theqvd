Wat.Views.OSDShortcutsEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'click .js-add-shortcut': 'addShortcut',
        'click .js-delete-shortcut': 'deleteShortcut',
        'click .js-update-shortcut': 'updateShortcut',
        'click .js-button-show-shortcut-details': 'toggleShortcutConfiguration',
    },
    
    render: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorShortcuts, {
                settings: Wat.CurrentView.settings,
                apps: Wat.CurrentView.apps,
                massive: this.massive,
                cid: this.cid
            }
        );

        $('.bb-os-conf-shortcuts').html(template);

        // Render rows with existent shortcuts
        var template = _.template(
            Wat.TPL.osConfigurationEditorShortcutsRows, {
                shortcuts: Wat.CurrentView.OSDmodel.get('shortcuts'),
                cid: this.cid
            }
        );

        $('.bb-os-conf-shortcuts-rows').html(template);
    },
    
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
                shortcuts: [newShortcut],
                cid: Wat.CurrentView.editorView.softwareEditorView.sectionShortcutsView.cid
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
});