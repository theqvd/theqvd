Wat.B = {
    bindCommonEvents: function () {
        this.bindMessageEvents();  
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
        this.bindEvent('click', '.js-back-top-doc-button', this.navigationBinds.goDocTop);
        this.bindEvent('click', '.js-back-top-generic-button', this.navigationBinds.goSimpleTop);
        
        // On any scroll
        $(window).off('scroll');
        $(window).on('scroll', this.navigationBinds.onScroll);
        
        // Dialogs
        this.bindEvent('click' ,'.js-change-password', this.navigationBinds.openChangePasswordDialog);
        this.bindEvent('click' ,'.js-profiles', this.navigationBinds.openProfilesDialog);
        this.bindEvent('change' ,'.js-profile-select', this.navigationBinds.openProfileChangeDialog);

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
                scrollTop: $(targetId).offset().top - 50
            }, 'fast');
            
            // Remove prefix '#_' from id
            targetId = targetId.substring(2, targetId.length+1);
            
            var currentHash = '#documentation/' + Wat.CurrentView.selectedGuide + '/' + targetId;

            // If pushState is available in browser, modify hash with current section
            if (history.pushState) {
                history.pushState(null, null, currentHash);
            }
        },
        
        goSimpleTop: function () {
            Wat.I.goTop();
        }, 
        
        goDocTop: function () {
            Wat.I.goTop();    
            
            var currentHash = '#documentation/' + Wat.CurrentView.selectedGuide;

            // If pushState is available in browser, modify hash with current section
            if (history.pushState) {
                history.pushState(null, null, currentHash);
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
            
            // When move scroll, minify header
            if ($(window).scrollTop() > 0) {
                $('.js-header-wrapper').addClass('header-wrapper--mini');
                $('.js-mobile-menu-hamburger').addClass('mobile-menu--mini');
            }
            else {
                $('.js-header-wrapper').removeClass('header-wrapper--mini');
                $('.js-mobile-menu-hamburger').removeClass('mobile-menu--mini');
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
                    Wat.CurrentView.cleanFilter($('[name="' + name + '"]').attr('data-filter-field'));
                    
                    $('[name="' + name + '"]').val(-1);
                    $('[name="' + name + '"]').trigger('chosen:updated');
                    break;
                case 'text':
                    Wat.CurrentView.cleanFilter($('[name="' + name + '"]').attr('data-filter-field'));
                    
                    $('[name="' + name + '"]').val('');
                    break;
                case 'filter':
                    // If is fussion note clean both filters
                    if (name.indexOf('__') > -1) {
                        var fussionNames = name.split('__');
                        $.each(fussionNames, function (iFN, fName) {
                            Wat.A.cleanFussionFilter(fName);
                        });
                    }
                    else {
                        Wat.CurrentView.cleanFilter(name);
                    }
                    break;
            }
            
            Wat.CurrentView.updateFilterNotes();
            Wat.CurrentView.filter();
        },
        
        openChangePasswordDialog: function (e) {        
            var dialogConf = {
                title: 'Change password',
                buttons : {
                    "Save": function () {
                        $(this).dialog('close');
                    }
                },
                button1Class : 'fa fa-save',
                fillCallback : Wat.CurrentView.fillChangePasswordDialog
            }

            Wat.I.dialog(dialogConf, this); 
        },
        
        openProfilesDialog: function (e) {  
            Wat.CurrentView.openProfilesDialog(e);
        }, 
        
        openProfileChangeDialog: function (e) {  
            Wat.CurrentView.openProfileChangeDialog(e);
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
}