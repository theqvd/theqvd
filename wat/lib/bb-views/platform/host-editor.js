Wat.Views.HostEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'host',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
    },
    
    renderCreate: function (target, that) {
        Wat.CurrentView.model = new Wat.Models.Host();
        $('.ui-dialog-title').html($.i18n.t('New Host'));
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-title').html($.i18n.t('Edit node') + ": " + this.model.get('name'));
    },
    
    createElement: function () {
        // Properties to create, update and delete obtained from parent view
        var properties = this.parseProperties('create');
                
        var context = $('.' + this.cid + '.editor-container');

        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        
        var arguments = {
            "blocked": blocked ? 1 : 0
        };
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('host.create.properties')) {
            arguments["__properties__"] = properties.set;
        }
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            arguments["name"] = name;
        } 
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            arguments["description"] = description;
        }
        
        var address = context.find('input[name="address"]').val();
        if (name) {
            arguments["address"] = address;
        }
                        
        Wat.CurrentView.createModel(arguments,Wat.CurrentView.fetchList);
    },
    

    updateElement: function (dialog) {
        // If current view is list, use selected ID as update element ID
        if (Wat.CurrentView.viewKind == 'list') {
            Wat.CurrentView.id = Wat.CurrentView.selectedItems[0];
        }
        
        var properties = this.parseProperties('update');
                
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var address = context.find('input[name="address"]').val();
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": Wat.CurrentView.id};
        var arguments = {};
        
        if (Wat.C.checkACL('host.update.name')) {
            arguments['name'] = name;
        }
        if (Wat.C.checkACL('host.update.address')) {
            arguments['address'] = address;
        }

        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('host.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        if (Wat.C.checkACL('host.update.description')) {
            arguments["description"] = description;
        }

        Wat.CurrentView.updateModel(arguments, filters, Wat.CurrentView.fetchAny);
    }
});