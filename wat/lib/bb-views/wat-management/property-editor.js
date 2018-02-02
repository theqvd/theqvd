Wat.Views.PropertyEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'property',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
    },
    
    renderCreate: function (target, that) {
        Wat.CurrentView.model = new Wat.Models.Property();
        $('.ui-dialog-titlebar').html($.i18n.t('New property'));
        
        // When admin is a superadmin, the change of the tenant selector will trigger the property objects renderization
        if (Wat.C.isSuperadmin()) {
            Wat.B.bindEvent('change', '[name="tenant_id"]', this.renderPropertiesObjects);
        }
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
        
        // When admin is not a superadmin, the property objects will be renderized once
        if (!Wat.C.isSuperadmin()) {
            this.renderPropertiesObjects();
        }
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-titlebar').html($.i18n.t('Edit property'));
    },
    
    renderPropertiesObjects: function () {
        // Host properties are only allowed to be managed by superadministrators in supertenant
        var hostPropertiesEnabled = Wat.C.isSuperadmin() && $('select[name="tenant_id"]').val() == 0;
        
        // Objects editor have checked the filtered objects initially
        var selectedObj = $('select[name="obj-qvd-select"]').val();
        var checkedObjs = {
            user: selectedObj == 'all',
            vm: selectedObj == 'all',
            host: selectedObj == 'all',
            osf: selectedObj == 'all',
            di: selectedObj == 'all'
        };
        
        if (selectedObj != 'all') {
            checkedObjs[selectedObj] = true;
        }
        
        var template = _.template(
            Wat.TPL.editorPropertyObjects, {
                hostPropertiesEnabled: hostPropertiesEnabled,
                checkedObjs: checkedObjs
            }
        );
        
        $('.js-editor-container[data-qvd-obj="property"] .bb-editor-extra').html(template);
        
        Wat.T.translate();
    },
    
    createElement: function () {
        var context = $('.' + this.cid + '.editor-container');

        var key = context.find('input[name="key"]').val();
        var description = context.find('textarea[name="description"]').val(); 
        
        var args = {
            "key": key,
            "description": description,
            "__property_assign__": []
        };
        
        if (Wat.C.isSuperadmin()) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            args['tenant_id'] = tenant_id;
        }
        else {
            // TODO: This assignation must be done by the server automatically for tenant admins
            args["tenant_id"] = Wat.C.tenantID;
        }
                
        $.each(QVD_OBJS_WITH_PROPERTIES, function (iObj, qvdObj) {
            if ($('input[name="in_' + qvdObj + '"]').is(':checked')) {
                args["__property_assign__"].push(qvdObj);
            }
        });
        
        Wat.CurrentView.createModel(args, Wat.CurrentView.render);
    },
    
    updateElement: function (dialog) {
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="key"]').val();
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": Wat.CurrentView.model.get('property_id')};
        var arguments = {};
        
        arguments['key'] = name;
        
        arguments["description"] = description;
        
        Wat.CurrentView.updateModel(arguments, filters, Wat.CurrentView.render);
    }
});