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
        
        // Chosen controls hack
        this.bindEvent('click', '.not_valid', this.formBinds.pressValidatedField);
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
        
            // Delete positive ACL
            this.bindEvent('click', '.js-delete-positive-acl-button', this.roleEditorBinds.deleteAcl, 'positive');

            // Add positive ACL
            this.bindEvent('click', '.js-add-positive-acl-button', this.roleEditorBinds.addAcl, 'positive'); 
        
            // Delete negative ACL
            this.bindEvent('click', '.js-delete-negative-acl-button', this.roleEditorBinds.deleteAcl, 'negative');

            // Add negative ACL
            this.bindEvent('click', '.js-add-negative-acl-button', this.roleEditorBinds.addAcl, 'negative');

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
        this.bindEvent('click', '.menu-option[data-target]', this.navigationBinds.clickMenu);
        
        this.bindEvent('click', '.js-submenu-option', this.navigationBinds.clickSubMenu);
        
        this.bindEvent('click', '.js-mobile-menu-hamburger', this.navigationBinds.clickMenuMobile);
        
        this.bindEvent('click', '.js-delete-filter-note', this.navigationBinds.clickDeleteFilterNote);
        
        // Show/hide the corner menu
        this.bindEvent('mouseenter', '.js-menu-corner li:has(ul)', this.navigationBinds.cornerMenuHoverIn);
        
        this.bindEvent('mouseleave', '.js-menu-corner li:has(ul)', this.navigationBinds.cornerMenuHoverOut);
        
        // Documentation menu option (workaround because backbone events dont work)
        this.bindEvent('click', '.js-doc-option', this.navigationBinds.clickDocOption);
        this.bindEvent('click', '#toc a', this.navigationBinds.clickToc);
        
        // Screen help button
        this.bindEvent('click', 'a[data-docsection]', this.navigationBinds.clickScreenHelp);
        
        // Back to top button
        this.bindEvent('click', '.js-back-top-button', this.navigationBinds.goDocTop);
        
        // On any scroll
        $(window).off('scroll');
        $(window).on('scroll', this.navigationBinds.onScroll);
        
        // Kind of image source in DI creation
        this.bindEvent('change', 'select[name="images_source"]', this.navigationBinds.toggleImagesource);
    },
    
    bindLoginEvents: function () {
        this.bindEvent('click', '.js-login-button', this.loginBinds.tryLogIn);
        
        this.bindEvent('keydown', 'input[name="admin_user"], input[name="admin_password"], input[name="admin_tenant"]', this.loginBinds.pushKeyOnLoginInput);
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
            
            // Chosen controls hack
            if ($(e.target).parent().hasClass('not_valid')) {
                $(e.target).parent().removeClass('not_valid');
                $(e.target).parent().parent().parent().find('.validation-message').remove();
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
        
        // When click on a submenu option, show properly subsection
        clickSubMenu: function() {
            var submenu = $(this).attr('data-show-submenu');
            
            $(this).parent().find('li').removeClass('menu-option--selected');
            $('table.acls-management').hide();
            $(this).addClass('menu-option--selected');
            $('table.' + submenu).show();
        },
        
        clickMenuMobile: function () {
            $('.js-menu-mobile').slideToggle();
        },
        
        cornerMenuHoverIn: function (e) {
            $(this).find('ul').css({display: "block"});
            
            // If the submenu layer has overflow in the screen, add negative margin left to adapt to the visible area
            var divRigth = $(this).find('ul').offset().left + $(this).find('ul').width();
            var winWidth = $(window).width();

            if (divRigth > winWidth) {
                $(this).find('ul').css('margin-left', (winWidth - divRigth - 5) + 'px');
            }
        },
        
        cornerMenuHoverOut: function (e) {
            $(this).find('ul').css({display: "none"});
        },
        
        clickDocOption: function (e) {
            var guideKey = $(e.target).attr('data-guide');
            
            window.location = '#documentation/' + guideKey;
        },
        
        clickToc: function (e) {
            e.preventDefault();
            
            var targetId = $(e.target).attr('href');
            
            $('html,body').animate({
                scrollTop: $(targetId).offset().top
            }, 'fast');
            
            // Remove prefix '#_' from id
            targetId = targetId.substring(2, targetId.length+1);
            
            var currentHash = '#documentation/' + Wat.CurrentView.selectedGuide + '/' + targetId;

            // If pushState is available in browser, modify hash with current section
            if (history.pushState) {
                history.pushState(null, null, currentHash);
            }
        },
        
        goDocTop: function () {
            Wat.I.goTop();    
            
            var currentHash = '#documentation/' + Wat.CurrentView.selectedGuide;

            // If pushState is available in browser, modify hash with current section
            if (history.pushState) {
                history.pushState(null, null, currentHash);
            }
        },
        
        toggleImagesource: function (e) {
            var selectedSource = $(e.target).val();
            
            switch (selectedSource) {
                case 'computer':
                    $('.image_computer_row').show();
                    $('.image_staging_row').hide();
                    break;
                case 'staging':
                    $('.image_computer_row').hide();
                    $('.image_staging_row').show();
                    break;
            }
        },
        
        onScroll: function () {
            if ($('.js-back-top-button').length) {
                if ($(window).scrollTop() > ($(window).height() / 2)) {
                    $('.js-back-top-button').show();
                }
                else {
                    $('.js-back-top-button').hide();
                }
            }
            
            // When move scroll, minify header
            if ($(window).scrollTop() > 0) {
                $('.js-header-wrapper').addClass('header-wrapper--mini');
            }
            else {
                $('.js-header-wrapper').removeClass('header-wrapper--mini');
            }

        },
        
        clickScreenHelp: function (e) {
            var docSection = $(e.target).attr('data-docsection');
            
            var section = Wat.I.docSections[docSection].es;
            var guide = Wat.I.docSections[docSection].guide;
            
            var guideSection = [
                {
                    section: section,
                    guide: guide
                }
            ];
            
            var docSectionMultitenant = docSection + '_multitenant';
            if (Wat.I.docSections[docSectionMultitenant] != undefined) {
                guideSection.push({
                    section: Wat.I.docSections[docSectionMultitenant].es,
                    guide: Wat.I.docSections[docSectionMultitenant].guide
                });
            }
            
            Wat.I.loadDialogDoc(guideSection);
            
            $('html,body').animate({
                scrollTop: 0
            }, 'fast');
        },
        
        clickDeleteFilterNote: function (e) {
            var name = $(e.target).attr('data-filter-name');
            var type = $(e.target).attr('data-filter-type');
            
            switch(type) {
                case 'select':
                    $('[name="' + name + '"]').val(-1);
                    $('[name="' + name + '"]').trigger('chosen:updated');
                    
                    Wat.CurrentView.cleanFilter($('[name="' + name + '"]').attr('data-filter-field'));
                    
                    $('[name="' + name + '"]:not(.mobile-filter)').trigger('change');
                    break;
                case 'text':
                    $('[name="' + name + '"]').val('');
                    $('[name="' + name + '"]:not(.mobile-filter)').trigger('input');
                    break;
                case 'filter':
                    Wat.CurrentView.cleanFilter(name);
                    
                    Wat.CurrentView.fetchList();
                    break;
            }           
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
            window.location = '#/' + target;
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
                'nameAsId': true,
                'chosenType': 'advanced100'
            };

            Wat.A.fillSelect(params);
        },
        
        filterTenantOSFs: function () {
            var params = {
                'action': 'osf_tiny_list',
                'selectedId': '',
                'controlName': 'osf_id',
                
            };
            
            if ($(this).val() > 0) {
                params.filters =  {
                    'tenant_id': $(this).val()
                };
            }

            // Remove all osf options and fill filtering with new selected tenant
            $('[name="osf_id"] option').remove();
            
            Wat.A.fillSelect(params, function () {
                // Update chosen control for osf
                Wat.I.updateChosenControls('[name="osf_id"]');

                // Trigger change event to update tags
                $('[name="osf_id"]').trigger('change');
            }); 
        },
        
        filterTenantUsers: function () {
            var params = {
                'action': 'user_tiny_list',
                'selectedId': '',
                'controlName': 'user_id'
            };

            if ($(this).val() > 0) {
                params.filters =  {
                    'tenant_id': $(this).val()
                };
            }
            
            // Remove all osf options and fill filtering with new selected tenant
            $('[name="user_id"] option').remove();
            
            Wat.A.fillSelect(params, function () {
                // Update chosen control for user
                Wat.I.updateChosenControls('[name="user_id"]');
            }); 
        }
    },
    
    userEditorBinds: {
        toggleNewPassword: function () {
            $('.new_password_row').toggle();
        }
    },
    
    roleEditorBinds: {
        deleteAcl: function (e) {
            // Disabled buttons have no effect
            if ($(this).hasClass('disabled')) {
                return;
            }
            
            // type can be 'positive' or 'negative'
            var type = e.data;
            
            var acls = $('select[name="acl_' + type + '_on_role"]').val();
            
            if (!acls) {
                Wat.I.showMessage({message: 'No items were selected - Nothing to do', messageType: 'info'});
                return;
            }
            
            var filters = {
                id: Wat.CurrentView.id
            };
            
            var changes = {};
            changes["unassign_acls"] = acls;
            
            var arguments = {
                "__acls_changes__": changes
            };
            
            Wat.CurrentView.updateModel(arguments, filters, function() {
                Wat.CurrentView.model.fetch({      
                    complete: function () {
                        Wat.CurrentView.afterUpdateAcls();
                    }
                });
            });
        },
        addAcl: function (e) {
            // type can be 'positive' or 'negative'
            var type = e.data;
            
            var acls = $('select[name="acl_available"]').val();
            
            if (!acls) {
                Wat.I.showMessage({message: 'No items were selected - Nothing to do', messageType: 'info'});
                return;
            }
            
            var filters = {
                id: Wat.CurrentView.id
            };
            
            var changes = {};
            changes["assign_acls"] = acls;
            
            var arguments = {
                "__acls_changes__": changes
            };
            
            Wat.CurrentView.updateModel(arguments, filters, function() {
                Wat.CurrentView.model.fetch({      
                    complete: function () {
                        Wat.CurrentView.afterUpdateAcls();
                    }
                });
            });
        },
        deleteRole: function () {
            var roleId = $(this).attr('data-id');
            
            var filters = {
                id: Wat.CurrentView.id
            };
            var arguments = {
                "__roles_changes__": {
                    unassign_roles: [roleId]
                }
            };

            
            Wat.CurrentView.updateModel(arguments, filters, function() {
                Wat.CurrentView.model.fetch({      
                    complete: function () {
                        Wat.CurrentView.afterUpdateRoles();
                    }
                });
            });
        },
        addRole: function () {
            var roleId = $('select[name="role"]').val();
            
            var filters = {
                id: Wat.CurrentView.id
            };
            var arguments = {
                "__roles_changes__": {
                    assign_roles: [roleId]
                }
            };
            
            Wat.CurrentView.updateModel(arguments, filters, function() {
                Wat.CurrentView.model.fetch({      
                    complete: function () {
                        Wat.CurrentView.afterUpdateRoles();
                    }
                });
            });
        },
    }
}