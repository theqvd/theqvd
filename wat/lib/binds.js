Wat.B = {
    bindEvents: function () {
        this.bindMessageEvents();  
        this.bindEditorEvents();  
    },
    
    // Events binded in classic way to works in special places like jQueryUI dialog where Backbone events doesnt work
    bindMessageEvents: function () {         
        // Close message layer
        this.bindEvent('click', '.js-message-close', this.messageBinds.closeMessage);
        
        // Expand message
        this.bindEvent('click', '.js-expand-message', this.messageBinds.toggleExtendedMessage);
        
        // Expand message
        this.bindEvent('mouseenter', '.js-message-container', this.messageBinds.hoverInMessage);
        
        // Expand message
        this.bindEvent('mouseleave', '.js-message-container', this.messageBinds.hoverOutMessage);
    },
    
    bindEditorEvents: function () {
        // Common Editor
        
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
        
        // Virtual Machines Editor
        
            // Toggle controls for disk images tags retrieving when select osf (it's only needed for vm form, but it can be accesible from two views: list and details)
            this.bindEvent('change', 'select[name="osf_id"]', this.editorBinds.fillDITags, this);
        
        // User editor
                
            // Toggle controls for new password
            this.bindEvent('change', 'input[name="change_password"]', this.userEditorBinds.toggleNewPassword);
    },
    
    // Generic function to bind events receiving the event, the selector and the callback function to be called when event is triggered
    bindEvent: function (event, selector, callback, params) {
        // First unbind event to avoid duplicated bindings
        $(document).off(event, selector);
        $(document).on(event, selector, params, callback);
    },

    // Callbacks of the events binded for messages system
    messageBinds: {
        closeMessage: function () {
            Wat.I.closeMessage();
        },
        
        toggleExtendedMessage: function () { 
            var extendedMessage = $(this).parent().find('article');
            Wat.I.clearMessageTimeout();
            
            if (extendedMessage.css('display') == 'none') {
                $(this).removeClass('fa-plus-square-o');
                $(this).addClass('fa-minus-square-o');
            }
            else {
                $(this).removeClass('fa-minus-square-o');
                $(this).addClass('fa-plus-square-o');
            }
            
            extendedMessage.toggle();
        },
        
        hoverInMessage: function (e) {
            $(e.target).css('opacity', 1);
            Wat.I.clearMessageTimeout();
        },
        
        hoverOutMessage: function (e) {
            if ($(e.target).find('.expandedMessage').css('display') != 'none') {
                return;
            }
            
            $(e.target).css('opacity', 0.8);
            
            // Error messages need to be closed manually
            if (!$(e.target).hasClass('error')) {
                Wat.I.setMessageTimeout();
            }
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
        
        // Fill the select combo with the available tags in the disk images of an OSF
        fillDITags: function (event) {
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

            Wat.A.fillSelect(params);

            Wat.I.updateChosenControls('[name="di_tag"]');
        }
    },
    
    userEditorBinds: {
        toggleNewPassword: function () {
            $('.new_password_row').toggle();
        }
    }
}