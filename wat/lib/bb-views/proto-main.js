Wat.Views.MainView = Backbone.View.extend({
    el: '.bb-content',
    editorContainer: '.bb-editor',
    editorPropertiesContainer: '.bb-custom-properties',
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
    sideViews: [],
    templates: {},
    
    initialize: function () {
        _.bindAll(this, 'render');
        
        // Add common functions
        Wat.C.addCommonFunctions (this);
        
        // Add to the view events the parent class of this view to avoid collisions with other views events
        this.events = this.restrictEventsScope(this.events);
        
        // Add the commonly used templates
        this.addCommonTemplates();

        var that = this;
        this.render = _.wrap(this.render, function(render) { 
            that.beforeRender(); 
            render(); 
            that.afterRender(); 
            return that; 
        }); 
    },
    
    addCommonTemplates: function () {
        var templates = {};
                
        templates['editor_' + this.qvdObj] = {
            name: 'editor/' + this.qvdObj
        };
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    beforeRender: function () {
            // Close submenus for touch devices compatibility
            $('.js-menu-corner li ul').hide();
    },
    
    afterRender: function () {
        var htmlString ="<html><body ><label>INPUT TYPE</label></body></html>";
        var doc = new jsPDF('landscape','pt');
        var specialElementHandlers = {
          '#editor': function( element, renderer ) {
              return true;
            }
        };
    },
    
    events:  {
        'input .filter-control>input': 'filterBySubstring'
    },
    
    filterBySubstring: function(e) {
        // Store typed search to mantain the order in filter task avoiding 
        // filtering if current typed search doesnt match with stored one
        Wat.CurrentView.typedSearch = $(e.target).val();
        
        this.filter(e);
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
        // If no bradcrumbs are given, do nothing
        if ($.isEmptyObject(bc)) {
            return;
        }
        
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
            bcHTML += '<a href="javascript:" class="fa fa-book js-screen-help screen-help" data-i18n="[title]Related documentation" data-docsection="' + this.qvdObj + '"></a>'
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
                
        if (that.viewKind == 'details' || that.editingFromList) {
            var editorMode = 'edit';
            delete that.editingFromList;
        }
        else {
            var editorMode = 'create';
        }
        
        var classifiedByTenant = $.inArray(that.qvdObj, QVD_OBJS_CLASSIFIED_BY_TENANT) != -1;
        
        // Add common parts of editor to dialog
        that.template = _.template(
                    Wat.TPL.editorCommon, {
                        classifiedByTenant: editorMode == 'create' ? classifiedByTenant : 0,
                        isSuperadmin: isSuperadmin,
                        editorMode: editorMode,
                        blocked: that.model ? that.model.attributes.blocked : 0,
                        cid: that.cid
                    }
                );
        
        target.html(that.template);
        
        if (editorMode == 'create' && isSuperadmin && classifiedByTenant) { 
            var params = {
                'action': 'tenant_tiny_list',
                'selectedId': that.selectedTenant || 0,
                'controlId': 'tenant_editor',
                'chosenType': 'single100'
            };
            
            Wat.A.fillSelect(params, function () {
                // Remove supertenant from tenant selector
                var existsInSupertenant = $.inArray(that.qvdObj, QVD_OBJS_EXIST_IN_SUPERTENANT) != -1;

                if (!existsInSupertenant) {
                    $('select[name="tenant_id"] option[value="0"]').remove();
                    
                    Wat.I.updateChosenControls('[name="tenant_id"]');
                }
                                
                Wat.B.bindEvent('change', '.tenant-selector select[name="tenant_id"]', Wat.B.editorBinds.updatePropertyRows);
                $('[name="tenant_id"]').trigger('change');
            });
        }
        
        // Add specific parts of editor to dialog
        that.template = _.template(
                    that.templateEditor, {
                        model: that.model || that.collection.where({id: that.selectedItems[0]})[0]
                    }
                );

        $(that.editorContainer).html(that.template);
        
        // Apply expanding plugin to make textareas expandable
        $("textarea").expanding();
        
        // Custom Properties
        
        if (!Wat.C.checkACL(Wat.CurrentView.qvdObj + '.update.properties')) {
            var enabledProperties = false;
        }
        // Get enabled properties value from constant. Properties could be disabled by variable
        else if (that.enabledProperties != undefined) {
            var enabledProperties =  that.enabledProperties;
            // Clean enabledProperties variable
            delete that.enabledProperties;
        }
        else {
            var enabledProperties =  $.inArray(that.qvdObj, QVD_OBJS_WITH_PROPERTIES) != -1;
        }
        
        switch (editorMode) {
            case 'create':
                var enabledEditProperties = Wat.C.checkACL(that.qvdObj + '.create.properties');
                break;
            case 'edit':
                var enabledEditProperties = Wat.C.checkACL(that.qvdObj + '.update.properties');
                break;
        }
        
        if (enabledProperties && enabledEditProperties) {
            var filters = {};

            if (editorMode == 'edit') {
                if (Wat.C.isMultitenant() && Wat.C.isSuperadmin()) {
                    filters['-or'] = ['tenant_id', that.model.get('tenant_id'), 'tenant_id', SUPERTENANT_ID];
                }
                else {
                    filters['tenant_id'] = that.model.get('tenant_id');
                }
            }
            
            that.editorMode = editorMode;
                
            Wat.A.performAction(that.qvdObj + '_get_property_list', {}, filters, {}, that.fillEditorProperties, that, undefined, {"field":"key","order":"-asc"});
        }
    },
    
    fillEditorProperties: function (that) {
        if (that.retrievedData.total > 0) {
            var properties = {};
            
            $.each(that.retrievedData.rows, function (iProp, prop) {
                var value = '';
                
                // Massive editor will not shot any value
                if (that.editorMode != 'massive-edit' && that.model && that.model.get('properties') && that.model.get('properties')[prop.property_id]) {
                    value = that.model.get('properties')[prop.property_id].value;
                }
                
                properties[prop.property_id] = {
                    value: value,
                    key: prop.key,
                    description: prop.description,
                    tenant_id: prop.tenant_id
                };
            });

            // Override properties including not setted on element
            that.model.set({properties: properties});
        }
        
        that.template = _.template(
                    Wat.TPL.editorCommonProperties, {
                        properties: that.model ? that.model.attributes.properties : {}
                    }
                );
        
        $(that.editorPropertiesContainer).html(that.template);
        
        Wat.T.translate();

        if (that.editorMode != 'create' || !Wat.C.isSuperadmin()) {
            $('.js-editor-property-row').show();
        }
        else if (Wat.C.isMultitenant() && Wat.C.isSuperadmin() && $('[name="tenant_id"]').val() != undefined) {
            $('.js-editor-property-row[data-tenant-id="' + $('[name="tenant_id"]').val() + '"]').show();
            $('.js-editor-property-row[data-tenant-id="' + SUPERTENANT_ID + '"]').show();
        }
        else {
            var existsInSupertenant = $.inArray(that.qvdObj, QVD_OBJS_EXIST_IN_SUPERTENANT) != -1;
            if (!existsInSupertenant) {
                $('.js-editor-property-row[data-tenant-id="' + Wat.C.tenantID + '"]').show();
            }
        }

        
        delete that.editorMode;
    },
    
    updateElement: function () {
        this.parseProperties('update');
        
        var context = '.editor-container.' + this.cid;
        
        return Wat.I.validateForm(context);
    },  
    
    createElement: function () {
        this.parseProperties('create');
        
        var context = '.editor-container.' + this.cid;
        
        return Wat.I.validateForm(context);
    },
    
    // Parse properties from create/edit forms
    parseProperties: function (mode) {
        var propNames = $('.' + this.cid + '.editor-container input.custom-prop-name');
        var propValues = $('.' + this.cid + '.editor-container input.custom-prop-value');
        
        switch (mode) {
            case 'create':
                var createPropertiesACL = this.qvdObj + '.create.properties';
                
                if (!createPropertiesACL) {
                    return;
                }
                break;
            case 'update':
                switch(this.viewKind) {
                    case 'list':
                        var updatePropertiesACL = this.qvdObj + '.update-massive.properties';
                        break;
                    case 'details':
                        var updatePropertiesACL = this.qvdObj + '.update.properties';
                        break;    
                }
                
                if (!updatePropertiesACL) {
                    return;
                }
                break;
        }
        
        var setProps = {};

        for(i=0;i<propNames.length;i++) {
            var name = propNames.eq(i);
            var value = propValues.eq(i);
                 
            setProps[name.val()] = value.val();
        }

        this.properties = {
            'set' : setProps
        };
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
        
        // If we are updating an element from list view, reset selected items
        if (this.viewKind == 'list') {
            this.resetSelectedItems();
        }
        
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

            if (callResponse == 200 && response.status == STATUS_SUCCESS) {
                that.message = messages.success;
                that.messageType = 'success';
            }
            else {
                that.message = messages.error;
                that.messageType = 'error';
            }

            if (that.dialog) {
                Wat.I.closeDialog(that.dialog);
            }
                        
            var messageParams = {
                message: that.message,
                messageType: that.messageType
            };
            
            that.retrievedData = response;
            successCallback(that);
            
            Wat.I.showMessage(messageParams, response);
        });
    },
    
    openNewElementDialog: function (e) {
        var that = this;
        
        this.templateEditor = Wat.TPL['editorNew_' + that.qvdObj];
        
        this.dialogConf.buttons = {
            Cancel: function (e) {
                Wat.I.closeDialog($(this));
            },
            Create: function (e) {
                that.dialog = $(this);
                that.createElement($(this));
            }
        };

        this.dialogConf.button1Class = 'fa fa-ban';
        this.dialogConf.button2Class = 'fa fa-plus-circle';
        
        this.dialogConf.fillCallback = this.fillEditor;

        this.editorElement(e);
    },
    
    openEditElementDialog: function (e) {
        var that = this;
        
        this.templateEditor = Wat.TPL['editor_' + that.qvdObj];
        
        this.dialogConf.buttons = {
            Cancel: function () {
                Wat.I.closeDialog($(this));
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
    },
    
    stopVM: function (filters, messages) {        
        var messages = messages || {
            'success': 'Stop request successfully performed',
            'error': 'Error stopping Virtual machine'
        };
        
        Wat.A.performAction ('vm_stop', {}, filters, messages, function(){}, this);
    },
    
    disconnectVMUser: function (filters, messages) {        
        var messages = messages || {
            'success': 'User successfully disconnected from VM',
            'error': 'Error disconnecting user from Virtual machine'
        };
        
        Wat.A.performAction ('vm_user_disconnect', {}, filters, messages, this.fetchList, this);
    },
    
    openRelatedDocsDialog: function () {
        var that = this;
        
        var dialogConf = {};

        dialogConf.title = $.i18n.t("Related documentation");

        dialogConf.buttons = {
            "Read full documentation": function (e) {
                Wat.I.closeDialog($(this));
                window.location = '#documentation';
            },
            Close: function (e) {
                Wat.I.closeDialog($(this));
            }
        };

        dialogConf.button1Class = 'fa fa-book';
        dialogConf.button2Class = 'fa fa-check';

        dialogConf.fillCallback = function (target, that) {
            // Back scroll of the div to top position
            target.html('');
            $('.js-dialog-container').animate({scrollTop:0});

            var sectionDoc = [];
            sectionDoc[this.qvdObj] = "This section step by step";
            this.relatedDoc = $.extend({}, sectionDoc, that.relatedDoc);
            
            if (this.relatedDoc) {
                var that = this;

                that.template = _.template(
                        Wat.TPL.relatedDoc, {
                            relatedDoc: that.relatedDoc,
                        }
                    );

                target.html(that.template);
            }
        };


        Wat.I.dialog(dialogConf, this);          
    },
    
    // Fetch details or list depending on the current view kind
    fetchAny: function (that) {
        switch (that.viewKind) {
            case 'list':
                that.fetchList();
                break;
            case 'details':
                that.fetchDetails();
                break;
        }
    }
});
