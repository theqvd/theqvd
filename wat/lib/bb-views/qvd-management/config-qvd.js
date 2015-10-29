Wat.Views.ConfigQvdView = Wat.Views.MainView.extend({  
    setupOption: 'administrators',
    secondaryContainer: '.bb-setup',
    qvdObj: 'config',
    selectedTenant: -1,
    
    setupOption: 'profile',
    
    limitByACLs: true,
    
    setAction: 'admin_view_set',
    
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
    
    initialize: function (params) {
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
        
        // The templates will be charged asynchronously. 
        Wat.A.getTemplates(templates, this.getPrefixes, this); 
    },
    
    getPrefixes: function (that) {
        var filter = {};
        if (Wat.C.isSuperadmin()) {
            filter['tenant_id'] = that.selectedTenant;
        }
            
        Wat.A.performAction('config_preffix_get', {}, filter, {}, that.processPrefixes, that);
    },
    
    processPrefixes: function (that) {
        if (that.retrievedData.statusText == 'abort') {
            return;
        }
        
        that.prefixes = that.retrievedData.rows;
                

        var filter = {};
        if (Wat.C.isSuperadmin) {
            filter['tenant_id'] = that.selectedTenant;
        }
                
        // If current Token is not among the recovered fixes, set first one
        if ($.inArray(that.currentTokensPrefix, that.prefixes) == -1) {
            that.currentTokensPrefix = that.prefixes[0];
        }
        
        if (that.currentTokensPrefix == UNCLASSIFIED_CONFIG_CATEGORY) {
            filter['key_re'] = UNCLASSIFIED_CONFIG_REGEXP;
            Wat.A.performAction('config_get', {}, filter, {}, that.processTokensRender, that);
        }
        else {
            filter['key_re'] = '^' + that.currentTokensPrefix + '\\.';
            Wat.A.performAction('config_get', {}, filter, {}, that.processTokensRender, that);
        }
    },
    
    processTokensRender: function (that) {
        that.configTokens = that.retrievedData.rows
        that.render();
    },  
    
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
                'action': 'tenant_tiny_list',
                'selectedId': this.selectedTenant,
                'controlId': 'tenant_search',
                'chosenType': 'single100',
                'startingOptions': {
                    '-1' : 'All',
                },
            };
            
            Wat.A.fillSelect(params);
        }
        
        this.renderConfigurationTokens();
    },
    
    processTokensRenderTokens: function (that) {
        // If search typed when searching was started is different to the current search in text box, do nothing
        if (that.typedSearch != undefined && that.typedSearch != $('input[name="config_search"]').val()) {
            return;
        }
        
        that.configTokens = that.retrievedData.rows
        
        // If there are not tokens in this prefix, render everything again selecting first prefix
        if (that.configTokens.length == 0 && $('input[name="config_search"]').val() == '') {
            that.currentTokensPrefix = '';
            
            var filter = {};
            if (Wat.C.isSuperadmin()) {
                filter['tenant_id'] = that.selectedTenant;
            }
            Wat.A.performAction('config_preffix_get', {}, filter, {}, that.processPrefixes, that);
        }
        else {
            that.renderConfigurationTokens();
        }
    },
    
    renderConfigurationTokens: function () {        
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
    
    events: {
        'click .js-token-header': 'clickTokenHeader',
        'click .lateral-menu-option': 'clickPrefixOption',
        'click .js-button-new': 'openNewElementDialog',
        'click .actions_button': 'performTokenAction',
        'input [name="config_search"]': 'filter',
        'change [name="tenant_id"]': 'changeTenant'
    },
    
    changeTenant: function (e) {
        this.selectedTenant = $(e.target).val();
        
        this.getPrefixes(this);
    },
    
    filter: function (e) {
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
            if (Wat.C.isSuperadmin) {
                filter['tenant_id'] = this.selectedTenant;
            }
            
            filter['key'] = search;

            // Pass typed search with context to avoid concurrency problems 
            Wat.A.performAction('config_get', {}, filter, {}, this.processTokensRenderTokens, $.extend({}, this, {typedSearch: $('input[name="config_search"]').val()}));
        }
    },
    
    clickPrefixOption: function (e) {
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
        if (Wat.C.isSuperadmin) {
            filter['tenant_id'] = this.selectedTenant;
        }
        
        if (this.currentTokensPrefix == UNCLASSIFIED_CONFIG_CATEGORY) {
            filter['key_re'] = UNCLASSIFIED_CONFIG_REGEXP;
            Wat.A.performAction('config_get', {}, filter, {}, this.processTokensRenderTokens, this);
        }
        else {
            filter['key_re'] = '^' + this.currentTokensPrefix + '\\.';
            Wat.A.performAction('config_get', {}, filter, {}, this.processTokensRenderTokens, this);
        }
    },
    
    selectPrefixMenu: function (prefix) {
        $('.lateral-menu-option').removeClass('lateral-menu-option--selected');
        $('.lateral-menu-option[data-prefix="' + prefix + '"]').addClass('lateral-menu-option--selected');
        
        // Go to start of the page
        $('html, body').animate({ scrollTop: 0 }, 'slow');
        
        // Empty search input
        $('input[name="config_search"]').val('');
    },
    
    clickTokenHeader: function (e) {
        if ($(e.target).is('i')) {
            $(e.target).parent().trigger('click');
            return false;
        }
        
        var prefix = $(e.target).attr('data-prefix');
        var status = $(e.target).attr('data-status');
        
        switch(status) {
            case 'open':
                $('.js-token-row[data-prefix="' + prefix + '"]').addClass('hidden');
                $(e.target).find('i').addClass('fa-plus-square-o');
                $(e.target).find('i').removeClass('fa-minus-square-o');
                $(e.target).attr('data-status', 'closed');
                break;
            case 'closed':
                $('.js-token-row[data-prefix="' + prefix + '"]').removeClass('hidden');
                $(e.target).find('i').addClass('fa-minus-square-o');
                $(e.target).find('i').removeClass('fa-plus-square-o');
                $(e.target).attr('data-status', 'open');
                break;
        }
    },
    
    performTokenAction: function (e) {
        var token = $(e.target).attr('data-token');
        var action = $('.token-action-select[data-token="' + token + '"]').val();
        var value = $('.token-value[data-token="' + token + '"]').val();
        
        switch(action) {
            case 'save':
                this.configActionArguments = {
                    "key": token,
                    "value": value
                };
                
                if (Wat.C.isSuperadmin) {
                    this.configActionArguments['tenant_id'] = this.selectedTenant;
                }
                
                Wat.I.confirm('dialog/config-change', this.applySave, this);
                
                break;
            case 'set_default':
                this.configActionFilters = {
                    "key": token,
                };
                
                if (Wat.C.isSuperadmin) {
                    this.configActionFilters['tenant_id'] = this.selectedTenant;
                }
                
                Wat.I.confirm('dialog/config-change', this.applySetDefault, this);
                break;
            case 'delete':
                this.configActionFilters = {
                    "key": token,
                };
                
                if (Wat.C.isSuperadmin) {
                    this.configActionFilters['tenant_id'] = this.selectedTenant;
                }
                
                Wat.I.confirm('dialog/config-change', this.applyDelete, this);
                break;
        }
    },
    
    applySave: function (that) {
        Wat.A.performAction('config_set', that.configActionArguments, {}, {'error': i18n.t('Error updating'), 'success': 'Successfully updated'}, that.afterChangeToken, that);
    },
        
    applySetDefault: function (that) {
        Wat.A.performAction('config_default', {}, that.configActionFilters, {'error': i18n.t('Error updating'), 'success': 'Successfully updated'}, that.afterChangeToken, that);
    },
        
    applyDelete: function (that) {
        Wat.A.performAction('config_delete', {}, that.configActionFilters, {'error': i18n.t('Error deleting'), 'success': 'Successfully deleted'}, that.afterChangeToken, that);
    },
    
    openNewElementDialog: function (e) {
        
        this.dialogConf.title = $.i18n.t('New configuration token');
        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
        
        Wat.I.chosenElement('[name="tenant"]', 'single100');
        
        // Set initial prefix to the current one
        $('[name="key"]').val(this.currentTokensPrefix + '.');
    },
    
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
        
        if (Wat.C.isSuperadmin) {
            arguments['tenant_id'] = this.selectedTenant;
        }
        
        Wat.A.performAction('config_set', arguments, {}, {'error': i18n.t('Error creating'), 'success': i18n.t('Successfully created')}, this.afterCreateToken, this);
    },
    
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
    
    afterChangeToken: function (that) {
        var filter = {};
        if (Wat.C.isSuperadmin) {
            filter['tenant_id'] = that.selectedTenant;
        }
        
        if (that.currentTokensPrefix == UNCLASSIFIED_CONFIG_CATEGORY) {
            filter['key_re'] = UNCLASSIFIED_CONFIG_REGEXP;
            Wat.A.performAction('config_get', {}, filter, {}, that.processTokensRenderTokens, that);
        }
        else if ($.inArray(that.currentTokensPrefix, that.prefixes) != -1) {
            // If there is a current search, filter by it. Otherwise filter by current selected prefix    
            filter['key_re'] = '^' + that.currentTokensPrefix + '\\.';
            
            if (!$.isEmptyObject(Wat.C.currentSearch)) {
                filter['key'] = Wat.C.currentSearch;
            }
            
			// If the prefix of the changed token exist, render it after change
            Wat.A.performAction('config_get', {}, filter, {}, that.processTokensRenderTokens, that);
        }
        else {
			// If the prefix of the changed token doesnt exist, render all to create this new prefix in side menu
            Wat.A.performAction('config_preffix_get', {}, filter, {}, that.processPrefixes, that);
        }
    }
});