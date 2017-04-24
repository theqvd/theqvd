Wat.Views.ConfigQvdView = Wat.Views.MainView.extend({  
    setupOption: 'administrators',
    secondaryContainer: '.bb-setup',
    qvdObj: 'config',
    selectedTenant: COMMON_TENANT_ID,
    
    tokensQueue: {
        edit: [],
        delete: []
    },
    
    setupOption: 'profile',
    
    limitByACLs: true,
    
    setActionAttribute: 'admin_attribute_view_set',
    setActionProperty: 'admin_property_view_set',
    
    viewKind: 'admin',
    currentTokensPrefix: '',
    
    currentSearch: {},
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'QVD Management',
            'next': {
                'screen': 'QVD Config'
            }
        }
    },
    
    events: {
        'click .lateral-menu-option': 'clickPrefixOption',
        'click .js-button-new': 'openNewElementDialog',
        'click .js-restore-token-default': 'restoreTokenDefault',
        'click .js-reset-token': 'resetToken',
        'click .js-delete-token': 'clickDeleteToken',
        'click .js-button-save': 'clickSaveTokens',
        'input input.js-token-value': 'editToken',
        'keypress [name="config_search"]': 'clickOnSearch',
        'change [name="tenant_id"]': 'changeTenant',
        'click #tenant_search_chosen': 'clickOpenTenantSelect'
    },
    
    initialize: function (params) {
        // Initialize tokensQueue to avoid errors
        this.tokensQueue = {
            edit: [],
            delete: []
        };
        
        // If user have not access to main section, redirect to home
        if (!Wat.C.checkACL('config.qvd.')) {
            Wat.Router.watRouter.trigger('route:defaultRoute');
            return;
        }
        
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        params.id = Wat.C.adminID;
        this.id = Wat.C.adminID;
        if (params.currentTokensPrefix != undefined) {
            this.currentTokensPrefix = params.currentTokensPrefix;
        }
        
        this.model = new Wat.Models.Admin(params);
                    
        var templates = Wat.I.T.getTemplateList('qvdConfig');
        
        // The templates will be charged asynchronously
        Wat.A.getTemplates(templates, this.getPrefixes, this); 
    },
    
    // Get the token prefixes from API
    getPrefixes: function (that) {
        var filter = {};
        if (Wat.C.isSuperadmin()) {
            filter['tenant_id'] = that.selectedTenant;
        }
            
        Wat.A.performAction('config_get', {}, filter, {}, that.processPrefixes, that, null, {"field": "key", "order":"-asc"});
    },
    
    // Process prefixes after be retrieved from API to support unclassified tokens and curren prefix
    processPrefixes: function (that) {
        if (that.retrievedData.statusText == 'abort') {
            return;
        }
        
        that.prefixes = [];
        var unclassifiedCount = 0;
        $.each(that.retrievedData.rows, function (iConfig, config) {
            var firstDotPos = config.key.indexOf('.');
            if(firstDotPos > -1) {
                var prefix = config.key.substring(0,firstDotPos);
                
                if ($.inArray(prefix, that.prefixes) == -1) {
                    that.prefixes.push(prefix);
                }
            }
            else {
                unclassifiedCount++;
            }
        });
        
        that.prefixes.sort();
        
        if (unclassifiedCount) {
            that.prefixes.push(UNCLASSIFIED_CONFIG_CATEGORY);
        }

        var filter = {};
        if (Wat.C.isSuperadmin()) {
            filter['tenant_id'] = that.selectedTenant;
        }
                
        // If current Token is not among the recovered fixes, set first one
        if ($.inArray(that.currentTokensPrefix, that.prefixes) == -1) {
            that.currentTokensPrefix = that.prefixes[0];
        }
        
        if (that.currentTokensPrefix == UNCLASSIFIED_CONFIG_CATEGORY) {
            filter['-not'] = {key : {'~':'%.%'}};
        }
        else {
            filter['key'] = {'~': that.currentTokensPrefix + '.%'};
        }
        
        // Retrieve from API current prefix tokens
        Wat.A.performAction('config_get', {}, filter, {}, that.processBeforeRender, that);
    },
    
    // Hook executed before render complete view
    // Sort retrieved tokens and render (Necessary step due API doesnt support order_by parameter for config tokens)
    processBeforeRender: function (that) {
        that.configTokens = Wat.U.sortObjectByField(that.retrievedData.rows, 'key');
        that.render();
    },
    
    // Render view
    render: function () {
        this.template = _.template(
            Wat.TPL.qvdConfig, {
                cid: this.cid,
                configTokens: this.configTokens,
                prefixes: this.prefixes,
                selectedPrefix: this.currentTokensPrefix
            }
        );

        $('.bb-content').html(this.template);
        
        if (Wat.C.isSuperadmin()) { 
            var params = {
                'actionAuto': 'tenant',
                'selectedId': this.selectedTenant,
                'controlId': 'tenant_search',
                'chosenType': 'advanced100',
                'startingOptions': {
                },
            };
            
            params['startingOptions'][COMMON_TENANT_ID] = 'Global (Default)';
            
            Wat.A.fillSelect(params, function () {
                // There are not tokens in supertenat context by the moment, so we delete the supertenant from tenant selector
                $('select#tenant_search option[value="0"]').remove();

                Wat.I.updateChosenControls('select#tenant_search');

            });
        }
        
        this.renderList();
    },
    
    // Process tokens after being retrieved from API when only list will be rendered
    // If last token of a prefix was deleted, render all view again
    processBeforeRenderList: function (that) {
        that.configTokens = Wat.U.sortObjectByField(that.retrievedData.rows, 'key');
        
        // If there are not tokens in this prefix, render everything again selecting first prefix
        if (that.configTokens.length == 0 && $('input[name="config_search"]').val() == '') {
            that.currentTokensPrefix = '';
            
            var filter = {};
            if (Wat.C.isSuperadmin()) {
                filter['tenant_id'] = that.selectedTenant;
            }
            Wat.A.performAction('config_get', {}, filter, {}, that.processPrefixes, that);
        }
        else {
            that.renderList();
        }
    },
    
    // Render tokens list
    renderList: function () {
        this.template = _.template(
            Wat.TPL.qvdConfigTokens, {
                configTokens: this.configTokens,
                selectedPrefix: this.currentTokensPrefix
            }
        );

        $('.bb-config-tokens').html(this.template);
                
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        Wat.I.chosenConfiguration();
        
        Wat.I.chosenElement('.token-action-select', 'single');
        
        Wat.T.translateAndShow();
        
        // If pushState is available in browser, modify hash with current token
        if (history.pushState) {
            history.pushState(null, null, '#/config/' + this.currentTokensPrefix);
        }
    },
    
    ////////////////////////////////////////////////////
    // Triggered functions by form and menu interaction
    ////////////////////////////////////////////////////
    
        // If there is some field without save when open tenant filter, show warning
        clickOpenTenantSelect: function (e) {
            if (this.tokensQueue.edit.length > 0 || this.tokensQueue.delete.length > 0) {
                this.noSavedWarning(function () {
                    $('select[name="tenant_id"]').trigger("chosen:open");
                });
                setTimeout(function () {
                    $('select[name="tenant_id"]').trigger("chosen:close");
                }, 100);
            }
        },
    
        // Filter by tenant
        changeTenant: function (e) {
            this.selectedTenant = $(e.target).val();

            // Show loading animation while get tokens
            $('.bb-config-tokens').html(HTML_MINI_LOADING);
            $('.secondary-menu ul').remove();
            $('.secondary-menu').append(HTML_MINI_LOADING);

            this.getPrefixes(this);
        },
    
        // When push carriage return on search box, filter
        // If there is some field without save when write on search box, show warning
        clickOnSearch: function (e) {
            if (e.keyCode == 13) {
                if (this.tokensQueue.edit.length > 0 || this.tokensQueue.delete.length > 0) {
                    this.noSavedWarning(this.clickOnSearch, e);
                    return;
                }

                $('.bb-config-tokens').html(HTML_MINI_LOADING);

                var search = $(e.target).val();

                Wat.C.currentSearch = search;

                if (search == '') {
                    $('.lateral-menu-option').eq(0).trigger('click');
                }
                else {
                    $('.lateral-menu-option').removeClass('lateral-menu-option--selected');

                    // If pushState is available in browser, modify hash with current token
                    if (history.pushState) {
                        history.pushState(null, null, '#/config');
                    }

                    var filter = {};
                    if (Wat.C.isSuperadmin()) {
                        filter['tenant_id'] = this.selectedTenant;
                    }

                    // Search substrings into key and operative_value
                    filter['-or'] = [
                        "key", {'~': '%' + search + '%'},
                        "operative_value", {'~': '%' + search + '%'}
                    ];

                    // Pass typed search with context to avoid concurrency problems 
                    Wat.A.performAction('config_get', {}, filter, {}, this.processBeforeRenderList, this);
                }
            }
        },
    
        // Open new dialog for token creation
        openNewElementDialog: function (e) {
            if (this.tokensQueue.edit.length > 0 || this.tokensQueue.delete.length > 0) {
                this.noSavedWarning(this.openNewElementDialog, e);
                return;
            }

            this.dialogConf.title = $.i18n.t('New configuration token');
            Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);

            Wat.I.chosenElement('[name="tenant"]', 'single100');

            // Set initial prefix to the current one
            $('[name="key"]').val(this.currentTokensPrefix + '.');
        },
    
        // Click on menu option
        clickPrefixOption: function (e) {
            if (this.tokensQueue.edit.length > 0 || this.tokensQueue.delete.length > 0) {
                this.noSavedWarning(this.clickPrefixOption, e);
                return;
            }

            // Restore current Search to empty
            Wat.C.currentSearch = '';

            // Get new hash from data-prefix attribute of clicked menu option
            var newHash = '#/config/' + $(e.target).attr('data-prefix');

            // If pushState is not available in browser, redirect to new hash reloading page
            if (!history.pushState) {
                window.location.hash = newHash;
                return;
            }

            history.pushState(null, null, newHash);

            this.selectPrefixMenu($(e.target).attr('data-prefix'));

            this.currentTokensPrefix = $(e.target).attr('data-prefix');
            $('.bb-config-tokens').html(HTML_MINI_LOADING);

            var filter = {};
            if (Wat.C.isSuperadmin()) {
                filter['tenant_id'] = this.selectedTenant;
            }

            if (this.currentTokensPrefix == UNCLASSIFIED_CONFIG_CATEGORY) {
                filter['-not'] = { key : {'~':'%.%'} };
                Wat.A.performAction('config_get', {}, filter, {}, this.processBeforeRenderList, this);
            }
            else {
                filter['key'] = {'~': this.currentTokensPrefix + '.%'};
                Wat.A.performAction('config_get', {}, filter, {}, this.processBeforeRenderList, this);
            }
        },
    
    ////////////////////////////////////////////////////
    
    // Set menu option as selected
    selectPrefixMenu: function (prefix) {
        $('.lateral-menu-option').removeClass('lateral-menu-option--selected');
        $('.lateral-menu-option[data-prefix="' + prefix + '"]').addClass('lateral-menu-option--selected');
        
        // Go to start of the page
        $('html, body').animate({ scrollTop: 0 }, 'slow');
        
        // Empty search input
        $('input[name="config_search"]').val('');
    },
    
    // Set token value to default value on system
    // Show indicators of not saved field and store token in delete queue
    restoreTokenDefault: function (e) {
        var token = $(e.target).attr('data-token');
        var defaultValue = $(e.target).attr('data-default-value');
        
        $('input.js-token-value[data-token="' + token + '"]').val(defaultValue);
        $('div.js-not-saved[data-token="' + token + '"]').show();
        $('.js-restore-token-default[data-token="' + token + '"]').hide();
        $('div.js-default-value[data-token="' + token + '"]').show();
        
        // Delete token from edited queue if exists
        if ($.inArray(token, this.tokensQueue.edit) != -1) {
            var index = this.tokensQueue.edit.indexOf(token);
            this.tokensQueue.edit.splice(index, 1);
        }
        
        // Add token to setToDefault queue if not exists
        if ($.inArray(token, this.tokensQueue.delete) == -1) {
            this.tokensQueue.delete.push(token);
        }
    },
    
    // Reset token value to saved value
    // Delete indicators of not saved field and delete token in edition queue
    resetToken: function (e) {
        var token = $(e.target).attr('data-token');
        var value = $(e.target).attr('data-value');
        var isDefault = parseInt($(e.target).attr('data-is-default'));
        var isCreated = parseInt($(e.target).attr('data-is-created'));
        
        $('input.js-token-value[data-token="' + token + '"]').val(value);
        $('div.js-not-saved[data-token="' + token + '"]').hide();
        
        if (isDefault) {
            $('div.js-default-value[data-token="' + token + '"]').show();
        }
        else {
            $('.js-restore-token-default[data-token="' + token + '"]').show();
            $('div.js-default-value[data-token="' + token + '"]').hide();
        }
        
        if (isCreated) {
            $('div.js-will-delete[data-token="' + token + '"]').hide();
            $('.js-delete-token[data-token="' + token + '"]').show();
            $('input.js-token-value[data-token="' + token + '"]').removeAttr('disabled');
        }
        
        // Delete token from queue arrays
        var index = this.tokensQueue.edit.indexOf(token);
        if (index != -1) {
            this.tokensQueue.edit.splice(index, 1);
        }
        
        var index = this.tokensQueue.delete.indexOf(token);
        if (index != -1) {
            this.tokensQueue.delete.splice(index, 1);
        }
    },
    
    // Hook triggered when any token value is modified writing into text input.
    // Show indicators of not saved field and store token in edition
    editToken: function (e) {
        var token = $(e.target).attr('data-token');
        var isDefault = parseInt($(e.target).attr('data-is-default'));
        
        $('div.js-not-saved[data-token="' + token + '"]').show();
        $('div.js-default-value[data-token="' + token + '"]').hide();
        
        if (!isDefault) {
            $('.js-restore-token-default[data-token="' + token + '"]').show();
        }
        
        // Delete token from setToDefault queue if exist
        if ($.inArray(token, this.tokensQueue.delete) != -1) {
            var index = this.tokensQueue.delete.indexOf(token);
            this.tokensQueue.delete.splice(index, 1);
        }
        
        // Add token to edit queue if not exists
        if ($.inArray(token, this.tokensQueue.edit) == -1) {
            this.tokensQueue.edit.push(token);
        }
    },
    
    // Show indicators of field that will be deleted and store token in deletion queue
    clickDeleteToken: function (e) {
        var token = $(e.target).attr('data-token');
        
        $('div.js-will-delete[data-token="' + token + '"]').show();
        $('.js-delete-token[data-token="' + token + '"]').hide();
        $('input.js-token-value[data-token="' + token + '"]').attr('disabled','disabled');
        
        // Delete token from edited queue if exists
        if ($.inArray(token, this.tokensQueue.edit) != -1) {
            var index = this.tokensQueue.edit.indexOf(token);
            this.tokensQueue.edit.splice(index, 1);
        }
        
        // Add token to setToDefault queue if not exists
        if ($.inArray(token, this.tokensQueue.delete) == -1) {
            this.tokensQueue.delete.push(token);
        }
    },
    
    ////////////////////////////////////////////////////
    // Functions for perform actions over tokens
    ////////////////////////////////////////////////////
    
        // Create new token
        createElement: function () {
            var valid = Wat.Views.ListView.prototype.createElement.apply(this);

            if (!valid) {
                return;
            }

            var context = $('.' + this.cid + '.editor-container');

            var key = context.find('input[name="key"]').val();
            var value = context.find('input[name="value"]').val();

            var arguments = {
                "key": key,
                "value": value
            };

            this.createdKey = key;

            if (Wat.C.isSuperadmin()) {
                arguments['tenant_id'] = this.selectedTenant;
            }

            Wat.A.performAction('config_set', arguments, {}, {'error': i18n.t('Error creating'), 'success': i18n.t('Successfully created')}, this.afterCreateToken, this);
        },
    
        // Hook executed after create token (executed before change hook)
        afterCreateToken: function (that) {
            Wat.I.closeDialog(that.dialog);

            var keySplitted = that.createdKey.split('.');

            if (keySplitted.length > 1) {
                that.currentTokensPrefix = keySplitted[0];
            }
            else {
                that.currentTokensPrefix = UNCLASSIFIED_CONFIG_CATEGORY;
            }

            that.selectPrefixMenu(that.currentTokensPrefix);

            that.afterChangeToken(that);
        },
    
        // Update token value
        saveToken: function (token, callBack) {
            var value = $('input.js-token-value[data-token="' + token + '"]').val();
            
            this.configActionArguments = {
                "key": token,
                "value": value
            };

            if (Wat.C.isSuperadmin()) {
                this.configActionArguments['tenant_id'] = this.selectedTenant;
            }

            Wat.A.performAction('config_set', this.configActionArguments, {}, {'error': i18n.t('Error updating'), 'success': 'Successfully updated'}, callBack, this);
        },

        // Delete token
        deleteToken: function (tokensToDelete, callBack) {
            this.configActionFilters = {
                "key": tokensToDelete,
            };

            if (Wat.C.isSuperadmin()) {
                this.configActionFilters['tenant_id'] = this.selectedTenant;
            }

            Wat.A.performAction('config_delete', {}, this.configActionFilters, {'error': i18n.t('Error deleting'), 'success': 'Successfully deleted'}, callBack, this);
        },

        // Hook executed after any kind of change on tokens (creation, update or delete)
        afterChangeToken: function (that) {
            var filter = {};
            if (Wat.C.isSuperadmin()) {
                filter['tenant_id'] = that.selectedTenant;
            }

            if (that.currentTokensPrefix == UNCLASSIFIED_CONFIG_CATEGORY && $('[data-prefix="unclassified"]').length > 0) {
                // If changed token is unclassified (no prefix) and exist others of same kind, use special filter
                filter['-not'] = { key : {'~':'%.%'} };
                Wat.A.performAction('config_get', {}, filter, {}, that.processBeforeRenderList, that);
            }
            else if (that.currentTokensPrefix == UNCLASSIFIED_CONFIG_CATEGORY) {
                // If changed token is first unclassified (no prefix), process prefixes again to add new option in side menu
                Wat.A.performAction('config_get', {}, filter, {}, that.processPrefixes, that);
            }
            else if ($.inArray(that.currentTokensPrefix, that.prefixes) != -1) {
                if (!$.isEmptyObject(Wat.C.currentSearch)) {
                    // Search substrings into key and operative_value
                    filter['-or'] = [
                        "key", {'~': '%' + Wat.C.currentSearch + '%'},
                        "operative_value", {'~': '%' + Wat.C.currentSearch + '%'}
                    ];
                }
                else {
                    // If there is a current search, filter by it. Otherwise filter by current selected prefix    
                    filter['key'] = {'~': that.currentTokensPrefix + '.%'};
                }

                // If the prefix of the changed token exist, render it after change
                Wat.A.performAction('config_get', {}, filter, {}, that.processBeforeRenderList, that);
            }
            else {
                // If the prefix of the changed token doesnt exist, render all to create this new prefix in side menu
                Wat.A.performAction('config_get', {}, filter, {}, that.processPrefixes, that);
            }

            if (that.retrievedData.rows) {
                // Any time one token were deleted or any api.pulblic.* token were created/updated, refresh public configuration from API and render footer
                if (!that.retrievedData.rows[0] || that.retrievedData.rows[0].key.substring(0,11) == 'api.public.') {
                    Wat.A.apiInfo(function (that) {
                        // Store public configuration 
                        Wat.C.publicConfig = that.retrievedData.public_configuration || {};

                        Wat.I.renderFooter();
                    }, that);
                }
            }
        },
    
    ////////////////////////////////////////////////////
    
    // Hook triggered when any token value is modified writing into text input.
    clickSaveTokens: function (e) {
        if (this.tokensQueue.edit.length > 0 || this.tokensQueue.delete.length > 0) {
            Wat.I.confirm('dialog/config-change', this.processTokenQueue, this);
        }
        else {
            Wat.I.M.showMessage({message: 'No tokens were updated - Nothing to do', messageType: 'info'});
        }
    },
    
    // Process tokens queue
    // Edition elements will be done one by one (massive edition is not supported by API)
    // Deletion elements will be done in one step
    processTokenQueue: function (that) {
        var that = that || this;
        
        // Process edition queue until is empty.
        if (that.tokensQueue.edit.length > 0) {
            // Edition is done token by token
            var tokenToEdit = that.tokensQueue.edit[0];
            that.tokensQueue.edit.splice(0, 1);
            
            that.saveToken(tokenToEdit, that.processTokenQueue);
        }
        // If edition queue is empty, process deletion queue
        else if (that.tokensQueue.delete.length > 0) {
            // Deletion is done in one step
            var tokensToDelete = that.tokensQueue.delete;
            that.tokensQueue.delete = [];
            
            that.deleteToken(tokensToDelete, that.processTokenQueue);
        }
        // After all, call hook
        else {
            that.afterChangeToken(that);
        }
    },
    
    // Show warning about any field is not saved. If accept, execute callback function passed as parameter
    noSavedWarning: function (callBack, params) {
        var that = this;
        
        Wat.I.confirm('dialog/config-no-saved', function () {
            $('.js-reset-token').trigger('click');
            $.proxy(callBack, that)(params);
        });
    }
});