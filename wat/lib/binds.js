Wat.B = {
    bindCommonEvents: function () {
        this.bindMessageEvents();  
        this.bindEditorEvents();  
        this.bindNavigationEvents();  
        this.bindFormEvents();  
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
    
    bindFormEvents: function () {
        this.bindEvent('keydown', '[data-required]', this.formBinds.pressValidatedField);
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
        
        // Roles editor
        
            // Delete ACL
            this.bindEvent('click', '.js-delete-acl-button', this.roleEditorBinds.deleteAcl);

            // Add ACL
            this.bindEvent('click', '.js-add-acl-button', this.roleEditorBinds.addAcl);

            // Add inherited Role
            this.bindEvent('click', '.js-add-role-button', this.roleEditorBinds.addRole);

            // Delete inherited Role
            this.bindEvent('click', '.js-delete-role-button', this.roleEditorBinds.deleteRole);
    },
    
    bindHomeEvents: function () {
        // Pie charts events
        this.bindEvent('mouseenter', '.js-pie-chart', this.homeBinds.pieHoverIn);
        
        this.bindEvent('mouseleave', '.js-pie-chart', this.homeBinds.pieHoverOut);
        
        this.bindEvent('click', '.js-pie-chart', this.homeBinds.pieClick);
    },
    
    bindNavigationEvents: function () {
        this.bindEvent('click', '.menu-option', this.navigationBinds.clickMenu);
        
        this.bindEvent('click', '.js-mobile-menu-hamburger', this.navigationBinds.clickMenuMobile);
        
        // Show/hide the corner menu
        this.bindEvent('mouseenter', '.js-menu-corner li:has(ul)', this.navigationBinds.cornerMenuHoverIn);
        
        this.bindEvent('mouseleave', '.js-menu-corner li:has(ul)', this.navigationBinds.cornerMenuHoverOut);
                
    },
    
    bindLoginEvents: function () {
        this.bindEvent('click', '.js-login-button', this.loginBinds.tryLogIn);
        
        this.bindEvent('keydown', 'input[name="admin_user"], input[name="admin_password"]', this.loginBinds.pushKeyOnLoginInput);
    },
    
    loginBinds: {
        tryLogIn: function() {
            Wat.C.tryLogin();
        },
        
        pushKeyOnLoginInput: function (e) {
            // If press enter, trigger login button
            if (e.which == 13 ) {
                $('.js-login-button').trigger('click');
            }
        }
    },
    
    formBinds: {
        pressValidatedField : function (e) {
            if ($(e.target).hasClass('not_valid')) {
                $(e.target).removeClass('not_valid');
                $(e.target).parent().find('.validation-message').remove();
            }
        }
    },
    
    navigationBinds: {
        // When click on a menu option, redirect to this section
        clickMenu: function() {
            // If in mobule mode, hide menu when click
            if ($('.js-mobile-menu-hamburger').css('display') != 'none') {
                $('.menu').slideUp();
            }
            
            var id = $(this).attr('data-target');
            window.location = '#/' + id;
            Wat.I.closeMessage();
        },
        
        clickMenuMobile: function () {
            $('.js-menu-mobile').slideToggle();
        },
        
        cornerMenuHoverIn: function (e) {
            $(this).find('ul').css({display: "block"});
        },
        
        cornerMenuHoverOut: function (e) {
            $(this).find('ul').css({display: "none"});
        }
    },
    
    homeBinds: {
        pieHoverIn: function (e) {
            var percentLabel = $(e.target).parent().parent().find('.home-percent');
            percentLabel.css('opacity', '1');
            percentLabel.css('font-weight', 'bold');
        },
            
        pieHoverOut: function (e) {
            var percentLabel = $(e.target).parent().parent().find('.home-percent');
            percentLabel.css('opacity', '0.5');
            percentLabel.css('font-weight', 'normal');
        },
        
        pieClick: function (e) {
            var target = $(e.target).parent().attr('data-target');
            $('.menu-option[data-target="' + target + '"]').trigger('click');
        }
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
            Wat.I.clearMessageTimeout();
        },
        
        hoverOutMessage: function (e) {
            if ($(e.target).find('.expandedMessage').css('display') != 'none') {
                return;
            }
                        
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
                Wat.CurrentView.deleteProps.push(deletedPropName);
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
    },
    
    roleEditorBinds: {
        deleteAcl: function () {
            // Add deleted item to the select
            var aclId = $(this).attr('data-id');
            var aclName = $(this).attr('data-name');
            
            $('select[name="role_acls"]').append('<option value="' + aclId + '">' + 
                                                               aclName + 
                                                               '<\/option>');
            
            $('select[name="role_acls"]').trigger('chosen:updated');
            
            // If item was previously added, delete from add list. Otherwise, push to delete list
            if ($.inArray(aclId, Wat.CurrentView.addACLs) != -1) {
                Wat.CurrentView.addACLs.splice( $.inArray(aclId, Wat.CurrentView.addACLs), 1 );
            }
            else {
                Wat.CurrentView.deleteACLs.push(aclId);
            }
            
            // Remove item
            $(this).parent().parent().remove();
        },
        addAcl: function () {
            var aclId = $('select[name="role_acls"]').val();
            var aclName = $('select[name="role_acls"] option:selected').html();
            
            var cellContent = '<i class="delete-acl-button js-delete-acl-button fa fa-trash-o" data-id="' + aclId + '" data-name="' + aclName + '"></i>\n' + aclName;
            
            $('<tr><td>' + cellContent + '</td></tr>').insertAfter('.manage-acls tr:first-child');
            
            $('select[name="role_acls"] option:selected').remove();
            $('select[name="role_acls"]').trigger('chosen:updated');
            
            Wat.CurrentView.addACLs.push(aclId);
        },
        deleteRole: function () {
            var roleId = $(this).attr('data-id');
            
            var filters = {
                id: Wat.CurrentView.id
            };
            var arguments = {
                "__acls_changes__": {
                    unassign_roles: [roleId]
                }
            };

            Wat.CurrentView.updateModel(arguments, filters, function() {Wat.CurrentView.embedContent()});
        },
        addRole: function () {
            var roleId = $('select[name="role"]').val();
            
            var filters = {
                id: Wat.CurrentView.id
            };
            var arguments = {
                "__acls_changes__": {
                    assign_roles: [roleId]
                }
            };
            
            Wat.CurrentView.updateModel(arguments, filters, function() {Wat.CurrentView.embedContent()});
        },
    }
}