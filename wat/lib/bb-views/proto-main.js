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
    },
    
    afterRender: function () {
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
        
        // Get enabled properties value from constant. Properties could be disabled by variable
        if (that.enabledProperties != undefined) {
            var enabledProperties =  that.enabledProperties;
            // Clean enabledProperties variable
            delete that.enabledProperties;
        }
        else {
            var enabledProperties =  $.inArray(that.qvdObj, QVD_OBJS_WITH_PROPERTIES) != -1;
        }
        
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
                    Wat.TPL.editorCommon, {
                        classifiedByTenant: editorMode == 'create' ? classifiedByTenant : 0,
                        isSuperadmin: isSuperadmin,
                        editorMode: editorMode,
                        blocked: that.model ? that.model.attributes.blocked : 0,
                        properties: that.model ? that.model.attributes.properties : {},
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
                'controlId': 'tenant_editor',
                'chosenType': 'single100'
            };
            
            Wat.A.fillSelect(params, function () {
                // Remove supertenant from tenant selector
                var existsInSupertenant = $.inArray(that.qvdObj, QVD_OBJS_EXIST_IN_SUPERTENANT) != -1;

                if (!existsInSupertenant) {
                    $('select[name="tenant_id"] option[value="0"]').remove();
                    
                    Wat.I.updateChosenControls('[name="tenant_id"]');
                    $('[name="tenant_id"]').trigger('change');
                }
            });
        }
        
        // Add specific parts of editor to dialog
        that.template = _.template(
                    that.templateEditor, {
                        model: that.model || that.collection.where({id: that.selectedItems[0]})[0]
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
        
        this.templateEditor = Wat.TPL['editor_' + that.qvdObj];
        
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
    
    renderRelatedDocs: function () {
        // The related doc links only will be render for not embeded views
        if (Wat.CurrentView.qvdObj != this.qvdObj) {
            return;
        }
        
        var sectionDoc = [];
        sectionDoc[this.qvdObj] = "This section step by step";
        this.relatedDoc = $.extend({}, sectionDoc, this.relatedDoc);
        
        if (this.relatedDoc) {
            var that = this;
            
            that.template = _.template(
                    Wat.TPL.relatedDoc, {
                        relatedDoc: that.relatedDoc,
                    }
                );

            $('.bb-related-docs').html(that.template);
        }
    },
    
    openRelatedDocsDialog: function () {
        var that = this;
        
        var dialogConf = {};

        dialogConf.title = $.i18n.t("Related documentation");

        dialogConf.buttons = {
            "Read full documentation": function (e) {
                $(this).dialog('close');
                window.location = '#documentation';
            },
            Close: function (e) {
                $(this).dialog('close');
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
