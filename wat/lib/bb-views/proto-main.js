Wat.Views.MainView = Backbone.View.extend({
    el: '.bb-content',
    editorContainer: '.bb-editor',
    breadcrumbs: {},
    message: 'Unknown problem',
    // error/success/info
    messagetype: 'error',
    dialogConf: {},
    deleteProps: [],
    deleteACLs: [],
    addACLs: [],
    deleteRoles: [],
    addRoles: [],
    currentMenu: '', // platform-setup
    
    initialize: function () {
        _.bindAll(this, 'render');
                
        this.templateEditorCommon = Wat.A.getTemplate('editor-common');
        
        // Add to the view events the parent class of this view to avoid collisions with other views events
        this.events = this.restrictEventsScope(this.events);

        var that = this;
        this.render = _.wrap(this.render, function(render) { 
            that.beforeRender(); 
            render(); 
            that.afterRender(); 
            return that; 
        }); 
    },
    
    beforeRender: function () {
    },
    
    afterRender: function () {
    },
    
    events:  {
    },
    
    extendEvents: function (ev) {
        if (ev == undefined) {
            return;
        }
        ev = this.restrictEventsScope(ev);
        this.events = _.extend(this.events, ev);
    },
  
    restrictEventsScope: function (events) {
        var that = this;
        var newEvents = {};
        $.each(events, function(key, value) {
            var newKey = key.replace(' ', ' .' + that.cid + ' ');
            newEvents[newKey] = value;
        });
        return newEvents;
    },
    
    printBreadcrumbs: function (bc, bcHTML) {
        if (bc.link != undefined) {
            bcHTML += '<a href="' + bc.link + '" data-i18n="' + bc.screen + '"></a>';
        }
        else {
            bcHTML += '<span data-i18n="' + bc.screen + '">' + bc.screen + '</span>';
        }
        if (bc.next != undefined) {
            bcHTML += ' <i class="fa fa-angle-double-right"></i> ';
            this.printBreadcrumbs (bc.next, bcHTML);
        }
        else {
            $('#breadcrumbs').html(bcHTML);
        }
    },
    
    // Editor
    editorElement: function (e) {
        Wat.I.dialog(this.dialogConf, this);           
    },
    
    fillEditor: function (target, that) {
        var that = that || Wat.CurrentView;
        
        var isSuperadmin = Wat.C.isSuperadmin();
        var editorMode = that.collection ? 'create' : 'edit';
        var classifiedByTenant = $.inArray(that.qvdObj, QVD_OBJS_CLASSIFIED_BY_TENANT) != -1;
        var enabledProperties = $.inArray(that.qvdObj, QVD_OBJS_WITH_PROPERTIES) != -1;
        var enabledCreateProperties = true;
        var enabledUpdateProperties = true;
        var enabledDeleteProperties = true;

        if (enabledProperties) {
            switch (editorMode) {
                case 'edit':
                        if (!Wat.C.checkACL(Wat.CurrentView.qvdObj + '.update.properties-create')) {
                            var enabledCreateProperties = false;
                        }
                        if (!Wat.C.checkACL(Wat.CurrentView.qvdObj + '.update.properties-update')) {
                            var enabledUpdateProperties = false;
                        }
                        if (!Wat.C.checkACL(Wat.CurrentView.qvdObj + '.update.properties-delete')) {
                            var enabledDeleteProperties = false;
                        }
                    break;
                case 'create':
                        if (!Wat.C.checkACL(Wat.CurrentView.qvdObj + '.create.properties')) {
                            enabledProperties = false;
                        }
                    break;
            }
        }
        
        // Add common parts of editor to dialog
        that.template = _.template(
                    that.templateEditorCommon, {
                        classifiedByTenant: classifiedByTenant,
                        isSuperadmin: isSuperadmin,
                        editorMode: editorMode,
                        blocked: that.model.attributes.blocked,
                        properties: that.model.attributes.properties,
                        enabledProperties: enabledProperties,
                        enabledCreateProperties: enabledCreateProperties,
                        enabledUpdateProperties: enabledUpdateProperties,
                        enabledDeleteProperties: enabledDeleteProperties,
                        cid: that.cid
                    }
                );
        
        target.html(that.template);
        
        if (editorMode == 'create' && isSuperadmin && classifiedByTenant) {
            
            var params = {
                'action': 'tenant_tiny_list',
                'selectedId': 0,
                'controlName': 'tenant_id'
            };

            Wat.A.fillSelect(params);
            
            // Remove supertenant from tenant selector
            var existsInSupertenant = $.inArray(that.qvdObj, QVD_OBJS_EXIST_IN_SUPERTENANT) != -1;

            if (!existsInSupertenant) {
                $('select[name="tenant_id"] option[value="0"]').remove();
            }
            
            Wat.I.chosenElement('[name="tenant_id"]', 'single100');
        }

        // Add specific parts of editor to dialog
        that.template = _.template(
                    that.templateEditor, {
                        model: that.model
                    }
                );

        $(that.editorContainer).html(that.template);
    },
    
    updateElement: function () {
        this.parseProperties();
        
        var context = '.editor-container.' + this.cid;
        
        return Wat.I.validateForm(context);
    },  
    
    createElement: function () {
        this.parseProperties();
        
        var context = '.editor-container.' + this.cid;
        
        return Wat.I.validateForm(context);
    },
    
    // Parse properties from create/edit forms
    parseProperties: function () {
        var propNames = $('.' + this.cid + '.editor-container input.custom-prop-name');
        var propValues = $('.' + this.cid + '.editor-container input.custom-prop-value');
        
        var deletedProps = [];
        var setProps = {};
        
        switch(this.viewKind) {
            case 'list':
                var createPropertiesACL = this.qvdObj + '.update-massive.properties-create';
                var updatePropertiesACL = this.qvdObj + '.update-massive.properties-update';
                var deletePropertiesACL = this.qvdObj + '.update-massive.properties-delete';
                break;
            case 'details':
                var createPropertiesACL = this.qvdObj + '.update.properties-create';
                var updatePropertiesACL = this.qvdObj + '.update.properties-update';
                var deletePropertiesACL = this.qvdObj + '.update.properties-delete';
                break;    
        }
        
        for(i=0;i<propNames.length;i++) {
            var name = propNames.eq(i);
            var value = propValues.eq(i);
            
            if (!name.val()) {
                continue;
            }
                        
            // If the element has not data-current attribute means that it's new
            // New properties with empty name will be ignored
            if (name.val() !== '' && value.attr('data-current') === undefined && Wat.C.checkACL(createPropertiesACL)) {
                setProps[name.val()] = value.val();
            }
            else {
                // If the value is different of the data-current attribute means that it's different
                if (value.attr('data-current') != value.val() && Wat.C.checkACL(updatePropertiesACL)) {
                    setProps[name.val()] = value.val();
                }
            }
        }
        
        if (!Wat.C.checkACL(deletePropertiesACL)) {
            this.deleteProps = [];
        }
        
        this.properties = {
            'set' : setProps, 
            'delete': this.deleteProps
        };
        
        // Restore deleteProps array
        this.deleteProps = [];
    },
    
    createModel: function (arguments, successCallback) {
        this.model.setOperation('create');
        
        var messages = {
            'success': 'Successfully created',
            'error': 'Error creating'
        };
        
        this.saveModel(arguments, {}, messages, successCallback);        
    },
    
    updateModel: function (arguments, filters, successCallback, model) {
        // If not model is passed, use this.model
        var model = model || this.model;
        
        model.setOperation('update');
        
        var messages = {
            'success': 'Successfully updated',
            'error': 'Error updating'
        };
        
        this.saveModel(arguments, filters, messages, successCallback, model);
    },
    
    deleteModel: function (filters, successCallback, model) {
        // If not model is passed, use this.model
        var model = model || this.model;
        
        model.setOperation('delete');
        
        var messages = {
            'success': 'Successfully deleted',
            'error': 'Error deleting'
        };
        
        this.saveModel({}, filters, messages, successCallback, model);
    },
    
    saveModel: function (arguments, filters, messages, successCallback, model) {
        var model = model || this.model;
        
        var that = this;
        model.save(arguments, {filters: filters}).complete(function(e, a, b) {
            Wat.I.loadingUnblock();

            var callResponse = e.status;
            var response = {status: e.status};
            
            if (e.responseText) {
                try {
                    response = JSON.parse(e.responseText);
                }
                catch (err) {
                    //console.log (e.responseText);
                }
            }
            
            that.retrievedData = response;
            successCallback(that);
            
            if (callResponse == 200 && response.status == STATUS_SUCCESS) {
                that.message = messages.success;
                that.messageType = 'success';
            }
            else {
                that.message = messages.error;
                that.messageType = 'error';
            }

            if (that.dialog) {
                that.dialog.dialog('close');
            }
                        
            var messageParams = {
                message: that.message,
                messageType: that.messageType
            };
            
            Wat.I.showMessage(messageParams, response);
        });
    },
    
     
    openEditElementDialog: function (e) {
        var that = this;
                    
        this.templateEditor = Wat.A.getTemplate(this.editorTemplateName);
        
        this.dialogConf.buttons = {
            Cancel: function () {
                $(this).dialog('close');
            },
            Update: function () {
                that.dialog = $(this);
                that.updateElement();
            }
        };
        
        this.dialogConf.button1Class = 'fa fa-ban';
        this.dialogConf.button2Class = 'fa fa-save';
        
        this.dialogConf.fillCallback = this.fillEditor;
        
        this.editorElement (e);
    }
});
