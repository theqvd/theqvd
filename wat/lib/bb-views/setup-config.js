Wat.Views.SetupConfigView = Wat.Views.MainView.extend({  
    setupCommonTemplateName: 'setup-common',
    setupOption: 'admins',
    secondaryContainer: '.bb-setup',
    qvdObj: 'config',
    
    setupOption: 'profile',
    
    limitByACLs: true,
    
    setAction: 'admin_view_set',
    
    viewKind: 'admin',
    currentTokensPrefix: '',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'QVD Config'
        }
    },
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        params.id = Wat.C.adminID;
        this.id = Wat.C.adminID;
        
        this.model = new Wat.Models.Admin(params);
        
        this.editorTemplateName = 'creator-conf-token',
        
        Wat.A.performAction('config_preffix_get', {}, {}, {}, this.processPrefixes, this);
    },
    
    processPrefixes: function (that) {
        that.prefixes = that.retrievedData.rows;
        
        that.prefixes.push(UNCLASSIFIED_CONFIG_CATEGORY);
        
        if (that.currentTokensPrefix == '') {
            that.currentTokensPrefix = that.prefixes[0];
        }
        
        Wat.A.performAction('config_get', {}, {'key_re':'^' + that.currentTokensPrefix + '\\.'}, {}, that.processTokensRender, that);
    },
    
    processTokensRender: function (that) {
        that.configTokens = that.retrievedData.rows
        that.render();
    },  
    
    render: function () {
        this.templateProfile = Wat.A.getTemplate('qvd-config');
        
        this.template = _.template(
            this.templateProfile, {
                cid: this.cid,
                configTokens: this.configTokens,
                prefixes: this.prefixes,
                selectedPrefix: this.currentTokensPrefix
            }
        );

        $('.bb-content').html(this.template);
        
        this.renderConfigurationTokens();
    },
    
    processTokensRenderTokens: function (that) {
        that.configTokens = that.retrievedData.rows
        
        // If there are not tokens in this prefix, render everything again selecting first prefix
        if (that.configTokens.length == 0) {
            that.currentTokensPrefix = '';
            Wat.A.performAction('config_preffix_get', {}, {}, {}, that.processPrefixes, that);
            return;
        }
        
        that.renderConfigurationTokens();
    },
    
    renderConfigurationTokens: function () {
        this.templateProfile = Wat.A.getTemplate('qvd-config-tokens');
        
        this.template = _.template(
            this.templateProfile, {
                configTokens: this.configTokens,
                selectedPrefix: this.currentTokensPrefix
            }
        );

        $('.bb-config-tokens').html(this.template);
                
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        Wat.I.chosenConfiguration();
        
        Wat.I.chosenElement('.token-action-select', 'single');
        
        Wat.T.translate();
    },
    
    events: {
        'click .js-token-header': 'clickTokenHeader',
        'click .token-prefix-option': 'clickPrefixOption',
        'click .js-button-new': 'openNewElementDialog',
        'click .actions_button': 'performTokenAction',
    },
    
    clickPrefixOption: function (e) {
        this.selectPrefixMenu($(e.target).attr('data-prefix'));
        
        this.currentTokensPrefix = $(e.target).attr('data-prefix');
        $('.bb-config-tokens').html(HTML_MINI_LOADING);
        
        if (this.currentTokensPrefix == UNCLASSIFIED_CONFIG_CATEGORY) {
            Wat.A.performAction('config_get', {}, {'key_re': UNCLASSIFIED_CONFIG_REGEXP}, {}, this.processTokensRenderTokens, this);
        }
        else {
            Wat.A.performAction('config_get', {}, {'key_re':'^' + this.currentTokensPrefix + '\\.'}, {}, this.processTokensRenderTokens, this);
        }
    },
    
    selectPrefixMenu: function (prefix) {
        $('.token-prefix-option').removeClass('token-prefix-option--selected');
        $('.token-prefix-option[data-prefix="' + prefix + '"]').addClass('token-prefix-option--selected');
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
                var arguments = {
                    "key": token,
                    "value": value
                };

                Wat.A.performAction('config_set', arguments, {}, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, this.afterChangeToken, this, false);
                break;
            case 'set_default':
                var filters = {
                    "key": token,
                };

                Wat.A.performAction('config_default', {}, filters, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, this.afterChangeToken, this, false);
                break;
            case 'delete':
                var filters = {
                    "key": token,
                };

                Wat.A.performAction('config_delete', {}, filters, {'error': i18n.t('Error deleting'), 'success': i18n.t('Successfully deleted')}, this.afterChangeToken, this, false);
                break;
        }
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
        
        Wat.A.performAction('config_set', arguments, {}, {'error': i18n.t('Error creating'), 'success': i18n.t('Successfully created')}, this.afterCreateToken, this, false);
    },
    
    afterCreateToken: function (that) {
        that.dialog.dialog('close');
        
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
        if (that.currentTokensPrefix == UNCLASSIFIED_CONFIG_CATEGORY) {
            Wat.A.performAction('config_get', {}, {'key_re': UNCLASSIFIED_CONFIG_REGEXP}, {}, that.processTokensRenderTokens, that);
        }
        else if ($.inArray(that.currentTokensPrefix, that.prefixes) != -1) {
			// If the prefix of the changed token exist, render it after change
            Wat.A.performAction('config_get', {}, {'key_re':'^' + that.currentTokensPrefix + '\\.'}, {}, that.processTokensRenderTokens, that);
        }
        else {
			// If the prefix of the changed token doesnt exist, render all to create this new prefix in side menu
            Wat.A.performAction('config_preffix_get', {}, {}, {}, that.processPrefixes, that);
        }
    }
});