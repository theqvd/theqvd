Up.B = {
    bindCommonEvents: function () {
        this.bindMessageEvents();  
        this.bindEditorEvents();  
        this.bindNavigationEvents();  
        this.bindFormEvents(); 
    },
    
    bindListEvents: function () {
        // Share folders and usb
        this.bindEvent('change', '.js-share-folders-check', this.listBinds.clickShareFolders);
        this.bindEvent('change', '.js-share-usb-check', this.listBinds.clickShareUsb);        
    },    
    
    bindDesktopsEvents: function () {
        // Enable-Disable settings on form
        this.bindEvent('change', '.js-disable-settings-check', this.desktopsBinds.changeDisableSettings);      
    },
    
    desktopsBinds: {
        changeDisableSettings: function (e) {
            var enable = $(e.target).is(':checked');
                                 
            if (enable) {
                $('.js-form-field--setting').removeAttr('disabled');
                $('.js-form-field--settingrow').removeClass('disabled-row');
                
                // When enable settings trigger change events on shared switchers to preserve disabled shared lists if necessary
                $('.js-share-folders-check').trigger('change');
                $('.js-share-usb-check').trigger('change');
            }
            else {
                $('.js-form-field--setting').attr('disabled', 'disabled');
                $('.js-form-field--settingrow').addClass('disabled-row');
            }
            
            $('select.js-form-field--setting').trigger('chosen:updated');
        }
    },
    
    listBinds: {
        clickShareFolders: function (e) {
            var enable = $(e.target).is(':checked');
            
            if (enable) {
                $('.js-form-field--folders').removeAttr('disabled');
                $('.js-form-field--foldersrow').removeClass('disabled-row');
            }
            else {
                $('.js-form-field--folders').attr('disabled', 'disabled');
                $('.js-form-field--foldersrow').addClass('disabled-row');
            }
        },
        
        clickShareUsb: function (e) {
            var enable = $(e.target).is(':checked');
            
            if (enable) {
                $('.js-form-field--usb').removeAttr('disabled');
                $('.js-form-field--usbrow').removeClass('disabled-row');
            }
            else {
                $('.js-form-field--usb').attr('disabled', 'disabled');
                $('.js-form-field--usbrow').addClass('disabled-row');
            }
        }
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
        
        // When open a chosen selector into a dialog, check if dialog size changes to make auto-scroll to bottom
        this.bindEvent('click', '.js-dialog-container .chosen-container', this.formBinds.checkDialogSizeChange);
    },
    
    bindEditorEvents: function () {
        // Common Editor  
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
    
    bindNavigationEvents: function () {
        this.bindEvent('click', '.menu-option[data-target]', this.navigationBinds.clickMenu);
        
        this.bindEvent('click', '.js-menu-corner .menu-option', this.navigationBinds.clickCornerMenu);
        
        this.bindEvent('click', '.js-submenu-option', this.navigationBinds.clickSubMenu);
        
        this.bindEvent('touchstart', '.needsclick', this.navigationBinds.tapNeedsClick);
        
        this.bindEvent('touchstart', 'body', this.navigationBinds.tapAny);
        
        this.bindEvent('click', '.js-mobile-menu-hamburger', this.navigationBinds.clickMenuMobile);
        
        // Show/hide the corner menu
        this.bindEvent('mouseenter', '.js-menu-corner li:has(ul)', this.navigationBinds.cornerMenuHoverIn);
        
        this.bindEvent('mouseleave', '.js-menu-corner li:has(ul)', this.navigationBinds.cornerMenuHoverOut);
        
        // Documentation menu option (workaround because backbone events dont work)
        this.bindEvent('click', '.js-doc-option', this.navigationBinds.clickDocOption);
        this.bindEvent('click', '#toc a', this.navigationBinds.clickToc);
        
        // Screen help button
        this.bindEvent('click', '.js-header-logo-desktop', this.navigationBinds.clickLogoDesktop);  
        this.bindEvent('click', '.js-back-button', this.navigationBinds.clickLoadBack);  
        
        // Screen help button
        this.bindEvent('click', 'a[data-docsection]', this.navigationBinds.clickScreenHelp);
        
        // Back to top button
        this.bindEvent('click', '.js-back-top-doc-button', this.navigationBinds.goDocTop);
        this.bindEvent('click', '.js-back-top-generic-button', this.navigationBinds.goSimpleTop);
        
        // Switch desktop-mobile modes
        this.bindEvent('click', '.js-force-desktop', this.navigationBinds.forceDesktopMode);
        this.bindEvent('click', '.js-unforce-desktop', this.navigationBinds.unforceDesktopMode);

        // On any scroll
        $(window).off('scroll');
        $(window).on('scroll', this.navigationBinds.onScroll);
        
        // Kind of image source in DI creation
        this.bindEvent('change', 'select[name="images_source"]', this.navigationBinds.toggleImagesource);   
        
        // Propagate click in cells with links
        this.bindEvent('mouseenter', 'td.cell-link', function (e) { 
            var firstLink = $(e.target).find('a')[0];
            if (firstLink) {
                $(firstLink).trigger('mouseenter');
            }            

            $(e.target).find('.show-when-hover').show();
            
            var bgcolor = $(e.target).css('background-color');
            var color = $(e.target).css('color');
            $(e.target).parent().children().css('background-color', bgcolor).css('color', color);
            $(e.target).parent().children().find('*').css('color', color);
        });
        this.bindEvent('mouseleave', 'td.cell-link', function (e) { 
            var firstLink = $(e.target).find('a')[0];
            if (firstLink) {
                $(firstLink).trigger('mouseleave');
            }
            
            $(e.target).find('.show-when-hover').hide();
            $(e.target).parent().children().css('background-color', '').css('color', '');
            $(e.target).parent().children().find('*').css('color', '');
        });
        this.bindEvent('click', 'td.cell-link', function (e) { 
            var firstLink = $(e.target).find('a')[0];
            if (firstLink) {
                location = $(firstLink).attr('href');
                $(firstLink).trigger('click');
            }
            
            var firstCheckbox = $(e.target).find('input[type="checkbox"]')[0];
            if (firstCheckbox) {
                $(firstCheckbox).trigger('click');
            }
            
        });
        this.bindEvent('click', 'td.cell-check, th.cell-check', function (e) { 
            var firstCheckbox = $(e.target).find('input[type="checkbox"]')[0];
            if (firstCheckbox) {
                $(firstCheckbox).trigger('click');
            }
            var firstRadiobutton = $(e.target).find('input[type="radio"]')[0];
            if (firstRadiobutton) {
                $(firstRadiobutton).trigger('click');
            }
        });
        
        // Propagate events to click on sections from widget click on homepage
        this.bindEvent('click', '.js-home-cell', function (e) { 
            $(e.target).find('a>i').trigger('click');
            $(e.target).find('.js-pie-chart').trigger('click');
        });
        
        this.bindEvent('click', '.js-home-cell>div', function (e) { 
            $(e.target).parent().find('a>i').trigger('click');
            $(e.target).find('.js-pie-chart').trigger('click');
        });
        
        this.bindEvent('mouseenter mouseleave', '.js-home-cell', function (e) { 
            $(e.target).find('canvas').trigger(e.type);
        });
        
    },
    
    bindLoginEvents: function () {
        this.bindEvent('click', '.js-login-button', this.loginBinds.tryLogIn);
        
        this.bindEvent('keydown', 'input[name="admin_user"], input[name="admin_password"], input[name="admin_tenant"]', this.loginBinds.pushKeyOnLoginInput);
    },
    
    loginBinds: {
        tryLogIn: function() {
            $('.js-login-form').submit();
            Up.L.tryLogin();
        },
        
        pushKeyOnLoginInput: function (e) {
            // If press enter, trigger login button
            if (e.which == 13 ) {
                $('.js-login-button').trigger('click');
            }
        }
    },
    
    formBinds: {
        pressValidatedField: function (e) {
            if ($(e.target).hasClass('not_valid')) {
                $(e.target).removeClass('not_valid');
                $(e.target).parent().find('.validation-message').remove();
            }
            
            // Chosen controls hack
            if ($(e.target).parent().hasClass('not_valid')) {
                $(e.target).parent().removeClass('not_valid');
                $(e.target).parent().parent().parent().find('.validation-message').remove();
            }
        },
        
        checkDialogSizeChange: function (e) {
            var container = $(e.target).closest('.chosen-container');
            var containerOpen = $(container).hasClass('chosen-width-drop');
            
            if (Up.I.dialogScrollHeight < $('.ui-dialog .js-dialog-container')[0].scrollHeight && !containerOpen) {
                Up.I.dialogScrollHeight = $('.ui-dialog .js-dialog-container')[0].scrollHeight;
                $('.ui-dialog .js-dialog-container')[0].scrollTop = $('.ui-dialog .js-dialog-container')[0].scrollHeight;
            }
        }
    },
    
    navigationBinds: {
        // When click on a menu option, redirect to this section
        clickMenu: function(e) {
            // If in mobule mode, hide menu when click
            if (Up.I.isMobile()) {
                $('.menu').slideUp();
            }
            
            var dataTarget = $(e.target).attr('data-target') || $(e.target).parent().attr('data-target');
            Up.I.Mobile.loadSection(dataTarget);
            
            var id = $(this).attr('data-target');
            window.location = '#/' + id;
            Up.I.M.closeMessage();
        }, 
        
        // When click on a corner menu option
        clickCornerMenu: function(e) {
            Up.I.Mobile.loadSection('profile');
        },        
        
        // When click on a submenu option, show properly subsection
        clickSubMenu: function() {
            var submenu = $(this).attr('data-show-submenu');
            
            $(this).parent().find('li').removeClass('menu-option--selected');
            $('table.acls-management').hide();
            $(this).addClass('menu-option--selected');
            $('table.' + submenu).show();
        },
        
        // When click on elements that FastClick library ignore, trigger hover but prevent click
        tapNeedsClick: function (e) {
            if ($(e.target).hasClass('needsclick')) {
                // Walk along the DOM tree until find UL of submenu to know if is visible or not
                // This swich have not "beak;" willfully
                var element = $(e.target);
                switch ($(e.target).prop('tagName')) {
                    case "I":
                    case "SPAN":
                        element = element.parent();
                    case "LI":
                        element = element.parent();
                    default:
                        var isAlreadyShown = element.find('ul').css('display') != 'none';
                }
                
                // Close submenus for touch devices compatibility
                $('.js-menu-corner li ul').hide();
                
                if (!isAlreadyShown) {
                    // Trigger hover event
                    $(e.target).trigger('mouseover');
                }
                
                // Prevent click event triggering
                e.preventDefault();
                e.stopPropagation();
            }
        },
        
        // When tap in any part of the screen but the "needsClick" elements because this behavior is prevent
        tapAny: function (e) {
            // Close submenus for touch devices compatibility
            setTimeout( function() { 
                $('.js-menu-corner li ul').hide();
            }, 100);
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
                scrollTop: $(targetId).offset().top - 50
            }, 'fast');
            
            // Remove prefix '#_' from id
            targetId = targetId.substring(2, targetId.length+1);
            
            var currentHash = '#documentation/' + Up.CurrentView.selectedGuide + '/' + targetId;

            // If pushState is available in browser, modify hash with current section
            if (history.pushState) {
                history.pushState(null, null, currentHash);
            }
        },
        
        goSimpleTop: function () {
            Up.I.goTop();
        }, 
        
        goDocTop: function () {
            Up.I.goTop();    
            
            var currentHash = '#documentation/' + Up.CurrentView.selectedGuide;

            // If pushState is available in browser, modify hash with current section
            if (history.pushState) {
                history.pushState(null, null, currentHash);
            }
        },
        
        forceDesktopMode: function () {
            $.cookie('forceDesktop', "1", { expires: 7, path: '/' });
            window.location.reload();
        },   
        
        unforceDesktopMode: function () {
            $.removeCookie('forceDesktop', { path: '/' });
            window.location.reload();
        },
        
        toggleImagesource: function (e) {
            var selectedSource = $(e.target).val();
            
            switch (selectedSource) {
                case 'computer':
                    $('.image_computer_row').show();
                    $('.image_staging_row').hide();
                    $('.image_url_row').hide();
                    break;
                case 'staging':
                    $('.image_computer_row').hide();
                    $('.image_staging_row').show();
                    $('.image_url_row').hide();
                    break;
                case 'url':
                    $('.image_computer_row').hide();
                    $('.image_staging_row').hide();
                    $('.image_url_row').show();
                    break;
            }
        },
        
        onScroll: function () {
            if ($('.js-back-top-button').length) {
                if ($(window).scrollTop() > $(window).height()) {
                    $('.js-back-top-button').show();
                }
                else {
                    $('.js-back-top-button').hide();
                }
            }
            
            $('.js-header-wrapper').css('left', -$(window).scrollLeft());
        },
        
        clickScreenHelp: function (e) {
            var docSection = $(e.target).attr('data-docsection');
            
            var section = Up.I.docSections[docSection].es;
            var guide = Up.I.docSections[docSection].guide;
            
            var guideSection = [
                {
                    section: section,
                    guide: guide
                }
            ];
            
            var docSectionMultitenant = docSection + '_multitenant';
            
            if (Up.I.docSections[docSectionMultitenant] != undefined) {
                guideSection.push({
                    section: Up.I.docSections[docSectionMultitenant].es,
                    guide: Up.I.docSections[docSectionMultitenant].guide
                });
            }
            
            // If doc dialog is opened from breadcrumbs link and there are not relate docs, open directly doc about current section step by step
            if ($(e.target).hasClass('screen-help') && Up.CurrentView.relatedDoc != undefined) {
                Up.CurrentView.openRelatedDocsDialog();
            }
            // Otherwise, open related doc options
            else {
                Up.I.loadDialogDoc(guideSection);
            }
            
            $('html,body').animate({
                scrollTop: 0
            }, 'fast');
        },
        
        clickLogoDesktop: function () {
            window.location = '#';
        }, 
        
        clickLoadBack: function () {
            if (Up.I.isDialogOpen()) {
                Up.I.closeLastDialog();
            }
            else {
                Up.I.Mobile.loadSection(Up.CurrentView.backLink);
                
                Up.CurrentView.backLink = 'menu';
            }
        },
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
            Up.I.M.closeMessage();
        },
        
        toggleExtendedMessage: function () { 
            var extendedMessage = $(this).parent().find('article');
            Up.I.M.clearMessageTimeout();
            
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
            Up.I.M.clearMessageTimeout();
        },
        
        hoverOutMessage: function (e) {
            if ($(e.target).find('.expandedMessage').css('display') != 'none') {
                return;
            }
                        
            // Error messages need to be closed manually
            if (!$(e.target).hasClass('error')) {
                Up.I.M.setMessageTimeout();
            }
        }
    },
    
    // Callbacks of the events binded on editor
    editorBinds: {
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

            Up.A.fillSelect(params);
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
            
            Up.A.fillSelect(params, function () {
                // Update chosen control for osf
                Up.I.updateChosenControls('[name="osf_id"]');

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
            
            Up.A.fillSelect(params, function () {
                // Update chosen control for user
                Up.I.updateChosenControls('[name="user_id"]');
            }); 
        },
        
        updatePropertyRows: function () {
            $('.js-editor-property-row').hide();
            $('.js-editor-property-row[data-tenant-id="' + $('[name="tenant_id"]').val() + '"]').show();
            $('.js-editor-property-row[data-tenant-id="' + SUPERTENANT_ID + '"]').show();
        },
    },
    
    userEditorBinds: {
        toggleNewPassword: function () {
            $('.new_password_row').toggle();
        }
    },
}
