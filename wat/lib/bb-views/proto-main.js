Wat.Views.MainView = Backbone.View.extend({
    el: '.bb-content',
    editorContainer: '.bb-editor',
    config: {},
    breadcrumbs: {},
    message: 'Unknown problem',
    // error/success/info
    messagetype: 'error',
    dialogConf: {},
    
    initialize: function () {
        _.bindAll(this, 'render');
        
        this.templateEditorCommon = Wat.A.getTemplate('editor-common');
        this.templateEditor = Wat.A.getTemplate(this.editorTemplateName);
        
        
        // Binding events manually because backbone doesnt allow bind events to dialogs loaded dinamically
        this.bindEditorEvents();
        this.bindOtherEvents();
        
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

    // Events binded in classic way to works in special places like jQueryUI dialog where Backbone events doesnt work
    bindOtherEvents: function () {         
        // Close message layer
        this.bindEvent('click', '.message-close', this.otherBinds.closeMessage);
    },
    
    bindEditorEvents: function () { 
        // Delete custom property
        this.bindEvent('click', '.delete-property-button', this.editorBinds.deleteProperty);
        
        // Add custom property
        this.bindEvent('click', '.add-property-button', this.editorBinds.addProperty);        
        
        // Hide property help when write on text input
        this.bindEvent('focus', '.custom-properties>tr>td input', this.editorBinds.hidePropertyHelp);
        
        // Active focus on property input when click on help message becaus it is over it
        this.bindEvent('click', '.property-help', this.editorBinds.focusPropertyField);
        
        // Toggle controls for expire fields (it's only needed for vm form, but it can be accesible from two views: list and details)
        this.bindEvent('change', 'input[name="expire"]', this.editorBinds.toggleExpire);
        
        // Toggle controls for disk images tags retrieving when select osf (it's only needed for vm form, but it can be accesible from two views: list and details)
        this.bindEvent('change', 'select[name="osf_id"]', this.editorBinds.fillDITags, this);
    },
    
    // Generic function to bind events receiving the event, the selector and the callback function to be called when event is triggered
    bindEvent: function (event, selector, callback, params) {
        // First unbind event to avoid duplicated bindings
        $(document).off(event, selector);
        $(document).on(event, selector, params, callback);
    },
    
    // Callbacks of the events binded on editor
    otherBinds: {
        closeMessage: function () {
            if (typeof messageTimeout != 'undefined') {
                clearTimeout(messageTimeout);
            }
            $('.message-container').slideUp(500);
        }
    },
    
    // Callbacks of the events binded on editor
    editorBinds: {
        addProperty: function () {
            var newRow = $('.template-property').clone();
            newRow.attr('class', 'new-property');
            newRow.insertBefore('.template-property');
        },

        deleteProperty: function () {
            // Store the name of the deleted property in a hidden field of serialized names by commas
            var deletedProp = $(this).parent().find('input.custom-prop-name');
            var deletedPropName = deletedProp.val();
            var deletedPropType = deletedProp.attr('type');

            // The current porperties are stored in hidden fields and the new properties in text fields
            // We will only store the current properties in a serialized list to remove them
            if (deletedPropType === 'hidden') {   
                var deletedProps = $(this).parent().parent().parent().find('input.deleted-properties');

                if (deletedProps.val() == "") {
                    var deletedPropsList = [];
                }
                else {
                    var deletedPropsList = JSON.parse(deletedProps.val().replace(/&quot;/g, '"'));
                }
            
                deletedPropsList.push(deletedPropName);
                deletedProps.val(JSON.stringify(deletedPropsList).replace(/"/g, '&quot;'));
            }
            
            // Remove two levels above the button (tr)
            $(this).parent().parent().remove();
        },

        hidePropertyHelp: function () {
            $(this).parent().find('.property-help').hide();
        },

        focusPropertyField: function () {
            $(this).parent().find('input').focus();
        },
        
        toggleExpire: function () {
            $('.expiration_row').toggle();
        },
        
        fillDITags: function (event, selected, fillSelect) {
            var that = event.data;
            
            $('[name="di_tag"]').find('option').remove();
            
            // Fill DI Tags select on virtual machines creation form
            var params = {
                'action': 'tag_tiny_list',
                'selectedId': '',
                'controlName': 'di_tag',
                'filters': {
                    'osf_id': $('[name="osf_id"]').val()
                },
                'nameAsId': true
            };

            that.fillSelect(params);

            $('[name="di_tag"]').trigger('chosen:updated');
        }
    },

    createModel: function (arguments) {
        this.model.setOperation('create');
        
        var messages = {
            'success': 'Successfully created',
            'error': 'Error creating'
        };
        
        this.saveModel(arguments, {}, messages, function(){});
    },
    
    updateModel: function (arguments, filters) {
        this.model.setOperation('update');
        
        var messages = {
            'success': 'Successfully updated',
            'error': 'Error updating'
        };
        
        this.saveModel(arguments, filters, messages, this.fetchDetails);
    },
    
    saveModel: function (arguments, filters, messages, successCallback) {
        var that = this;
        this.model.save(arguments, {filters: filters}).complete(function(e) {
            var callResponse = e.status;
            var response = JSON.parse(e.responseText);
            
            if (callResponse == 200 && response.status == SUCCESS) {
                successCallback(that);
                
                that.message = messages.success;
                that.messageType = 'success';
            }
            else {
                that.message = message.e;
                that.messageType = 'error';
            }

            that.dialog.dialog('close');
            Wat.I.showMessage({message: that.message, messageType: that.messageType});
        });
    },
    
    // Fill filter selects 
    fillSelect: function (params) {  
        var jsonUrl = 'http://172.20.126.12:3000/?login=benja&password=benja&action=' + params.action;
        
        if (params.filters) {
            jsonUrl += '&filters=' + JSON.stringify(params.filters);
        }
        
        $.ajax({
            url: jsonUrl,
            type: 'POST',
            async: false,
            dataType: 'json',
            processData: false,
            parse: true,
            success: function (data) {
                $(data.result.rows).each(function(i,option) {
                    var selected = '';
                    
                    var id = option.id;
                    var name = option.name;
                    
                    if (params.nameAsId) {
                        id = name;
                    }
                    
                    if (params.selectedId !== undefined && params.selectedId == id) {
                        selected = 'selected="selected"';
                    }
                    
                    $('select[name="' + params.controlName + '"]').append('<option value="' + id + '" ' + selected + '>' + 
                                                                   name + 
                                                                   '<\/option>');
                });
            }
        });
    }
});
