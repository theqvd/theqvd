Wat.Views.MainView = Backbone.View.extend({
    el: '.bb-content',
    editorContainer: '.bb-editor',
    breadcrumbs: {},
    message: 'Unknown problem',
    // error/success/info
    messagetype: 'error',
    dialogConf: {},
    
    initialize: function () {
        _.bindAll(this, 'render');
        
        this.templateEditorCommon = Wat.A.getTemplate('editor-common');
        
        if (this.editorTemplateName) {
            this.templateEditor = Wat.A.getTemplate(this.editorTemplateName);
        }
        
        
        // Binding events manually because backbone doesnt allow bind events to dialogs loaded dinamically
        Wat.B.bindEvents();
        
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
            bcHTML += '<a href="' + bc.link + '" data-i18n>' + bc.screen + '</a>';
        }
        else {
            bcHTML += '<span data-i18n>' + bc.screen + '</span>';
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
        var that = this;
        Wat.I.dialog(that.dialogConf);           
    },
    
    fillEditor: function (target) {
        var that = Wat.CurrentView;
        
        // Add common parts of editor to dialog
        that.template = _.template(
                    that.templateEditorCommon, {
                        model: that.model,
                        cid: that.cid
                    }
                );

        target.html(that.template);

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
    },  
    
    createElement: function () {
        this.parseProperties();
    },
    
    // Parse properties from create/edit forms
    parseProperties: function () {
        var propNames = $('.' + this.cid + '.editor-container input.custom-prop-name');
        var propValues = $('.' + this.cid + '.editor-container input.custom-prop-value');
        
        var deletedProps = [];
        var addedProps = {};
        var updatedProps = {};
        
        for(i=0;i<propNames.length;i++) {
            var name = propNames.eq(i);
            var value = propValues.eq(i);
            
            if (!name.val()) {
                continue;
            }
                        
            // If the element has not data-current attribute means that it's new
            // New properties with empty name will be ignored
            if (name.val() !== '' && value.attr('data-current') === undefined) {
                addedProps[name.val()] = value.val();
            }
            else {
                // If the value is different of the data-current attribute means that it's different
                if (value.attr('data-current') != value.val()) {
                    updatedProps[name.val()] = value.val();
                }
            }
        }
        
        // Store deleted properties from serialized list
        var deletedPropsList = $('.' + this.cid + ' .deleted-properties').val();
        if (deletedPropsList) {
            deletedProps = JSON.parse(deletedPropsList.replace(/&quot;/g, '"'));
        }
        
        this.properties = {
            'create' : addedProps, 
            'update': updatedProps, 
            'delete': deletedProps
        };
    },
    
    createModel: function (arguments) {
        this.model.setOperation('create');
        
        var messages = {
            'success': 'Successfully created',
            'error': 'Error creating'
        };
        
        this.saveModel(arguments, {}, messages, this.fetchList);
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
        model.save(arguments, {filters: filters}).complete(function(e) {
            var callResponse = e.status;
            var response = JSON.parse(e.responseText);
            
            if (callResponse == 200 && response.status == SUCCESS) {
                successCallback(that);
                
                that.message = messages.success;
                that.messageType = 'success';
            }
            else {
                that.message = message.error;
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
    }
});
