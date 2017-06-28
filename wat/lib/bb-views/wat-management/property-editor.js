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
        $('.ui-dialog-title').html($.i18n.t('New property'));
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-title').html($.i18n.t('Edit property'));
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
        
        //if (Wat.C.checkACL('role.update.name')) {
            arguments['key'] = name;
        //}
        
        //if (Wat.C.checkACL('role.update.description')) {
            arguments["description"] = description;
        //}
        
        Wat.CurrentView.updateModel(arguments, filters, Wat.CurrentView.render);
    }
});