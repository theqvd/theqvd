// Common lib for OSF views (list and details)
Wat.Common.BySection.osf = {
    editorViewClass: Wat.Views.OSFEditorView,
    
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = Wat.I.T.getTemplateList('osDetails');
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    // Render OS Details template and return it
    // model: Backbone model of the OSD
    // options: Options of the rendering
    //          - editable: If Edit button will be rendering
    //          - shrinked: If is just showed SO distro and rest of the info is expanded clicking More button
    //          - container: CSS selector of the container where will be rendered
    renderOSDetails: function (model, options) {
        options = options || {};
        options.container = options.container || '';
        
        if (!model) {
            var template = 'This OSF is of type custom';
        }
        else {
            var osfId = Wat.CurrentView.model ? Wat.CurrentView.model.get('id') : 0;
            var distroId = model.get('distro_id');
            
            var distros = model.getPluginAttrOptions('os.distro', function (distros) {
                // Add specific parts of editor to dialog
                var template = _.template(
                            Wat.TPL.osConfiguration, {
                                osfId: osfId,
                                model: model,
                                config_params: model.get('config_params'),
                                shortcuts: model.get('shortcuts'),
                                scripts: model.get('scripts'),
                                distro: distros[distroId],
                                editable: options.editable,
                                shrinked: options.shrinked
                            }
                        );
        
                $(options.container + ' .bb-os-configuration').html(template);
            });
        }
    },
}