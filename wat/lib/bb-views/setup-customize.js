Wat.Views.SetupCustomizeView = Wat.Views.MainView.extend({
    setupCommonTemplateName: 'setup-common',
    setupCustomizeTemplateName: 'setup-customize',
    setupCustomizeFormTemplateName: 'setup-customize-form',
    sideContainer: '.bb-setup-side',
    setupContainer: '.bb-setup',
    setupFormContainer: '.bb-customize-form',
    setupOption: 'customize',
    selectedSection: 'user',
    selectedTenant: '0',

    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Setup',
            'link': '#/setup',
            'next': {
                'screen': 'Views'
            }
        }
    },
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);

        this.render();
    },
    
    events: {
        'change select[name="obj-qvd-select"]': 'changeSection',
        'change select[name="tenant-select"]': 'changeSection',
        'change .js-desktop-fields>input': 'checkDesktopFilter',
        'change .js-mobile-fields>input': 'checkMobileFilter',
        'change .js-field-check>input': 'checkListColumn',
    },
    
    checkDesktopFilter: function (e) {
        var checked = $(e.target).is(':checked');
        var fieldName = $(e.target).parent().attr('data-name');
        
        var qvdObj = this.selectedSection;
        var tenantId = this.selectedTenant;
        var currentFilters = this.currentFormFilters;
        
        if (!currentFilters[fieldName] || currentFilters[fieldName].displayDesktop != checked) {
            var args = {
                'tenant_id': tenantId,
                'field': fieldName,
                'view_type': 'filter',
                'device_type': 'desktop',
                'visible': checked,
                'qvd_object': qvdObj,
                'property': !currentFilters[fieldName] || currentFilters[fieldName].property
            };

            Wat.A.performAction('tenant_view_set', args, {}, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, function () {}, this, false);
            
            if (this.retrievedData.status == STATUS_SUCCESS) {
                // If update is perfermed successfuly, update in memory
                if (currentFilters[fieldName]) {
                    this.currentFormFilters[fieldName].displayDesktop = checked;
                }
                else {
                    this.currentFormFilters[fieldName] = {
                        acls: qvdObj + ".see.properties",
                        displayDesktop: checked,
                        displayMobile: 0,
                        filterField: fieldName,
                        noTranslatable: true,
                        property: true,
                        text: fieldName,
                        type: "select",
                    };
                }
            }
            else {
                // If update fails, change ckeckbox to previous state
                $(e.target).prop('checked', !checked);
            }
        }
    },
    
    checkMobileFilter: function (e) {
        var checked = $(e.target).is(':checked');
        var fieldName = $(e.target).parent().attr('data-name');
        
        var qvdObj = this.selectedSection;
        var tenantId = this.selectedTenant;
        var currentFilters = this.currentFormFilters;
        
        if (!currentFilters[fieldName] || currentFilters[fieldName].displayMobile != checked) {
            var args = {
                'tenant_id': tenantId,
                'field': fieldName,
                'view_type': 'filter',
                'device_type': 'mobile',
                'visible': checked,
                'qvd_object': qvdObj,
                'property': !currentFilters[fieldName] || currentFilters[fieldName].property
            };

            Wat.A.performAction('tenant_view_set', args, {}, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, function () {}, this, false);
            
            if (this.retrievedData.status == STATUS_SUCCESS) {
                // If update is perfermed successfuly, update in memory
                if (currentFilters[fieldName]) {
                    this.currentFormFilters[fieldName].displayMobile = checked;
                }
                else {
                    this.currentFormFilters[fieldName] = {
                        acls: qvdObj + ".see.properties",
                        displayDesktop: 0,
                        displayMobile: checked,
                        filterField: fieldName,
                        noTranslatable: true,
                        property: true,
                        text: fieldName,
                        type: "select",
                    };
                }
            }
            else {
                // If update fails, change ckeckbox to previous state
                $(e.target).prop('checked', !checked);
            }
        }
    },
    
    checkListColumn: function (e) {
        var checked = $(e.target).is(':checked');
        var fieldName = $(e.target).parent().attr('data-name');
        
        var qvdObj = this.selectedSection;
        var tenantId = this.selectedTenant;
        var currentColumns = this.currentListColumns;
        
        if (!currentColumns[fieldName] || currentColumns[fieldName].display != checked) {
            var args = {
                'tenant_id': tenantId,
                'field': fieldName,
                'view_type': 'list_column',
                'device_type': 'desktop',
                'visible': checked,
                'qvd_object': qvdObj,
                'property': !currentColumns[fieldName] || currentColumns[fieldName].property
            };

            Wat.A.performAction('tenant_view_set', args, {}, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, function () {}, this, false);
            
            if (this.retrievedData.status == STATUS_SUCCESS) {
                // If update is perfermed successfuly, update in memory
                if (currentColumns[fieldName]) {
                    this.currentListColumns[fieldName].display = checked;
                }
                else {
                    this.currentListColumns = {
                        acls: qvdObj + ".see.properties",
                        display: checked,
                        fields: [fieldName],
                        noTranslatable: true,
                        property: true,
                        text: fieldName,
                    };
                }
            }
            else {
                // If update fails, change ckeckbox to previous state
                $(e.target).prop('checked', !checked);
            }
        }
    },
    
    changeSection: function (e) {
        this.selectedSection = $('select[name="obj-qvd-select"]').val();
        this.selectedTenant = $('select[name="tenant-select"]').val();
        this.renderForm();
    },
    
    render: function () {
        this.templateSetupCommon = Wat.A.getTemplate(this.setupCommonTemplateName);
        var cornerMenu = Wat.I.getCornerMenu();
        
        // Fill the html with the template and the model
        this.template = _.template(
            this.templateSetupCommon, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: cornerMenu.setup.subMenu
            }
        );
        
        $(this.el).html(this.template);
        
        this.renderBlock();
    },
    
    renderBlock: function () {
        this.templateSetupCustomize = Wat.A.getTemplate(this.setupCustomizeTemplateName);
        
        this.template = _.template(
            this.templateSetupCustomize, {
                selectedSection: this.selectedSection
            }
        );
        
        $(this.setupContainer).html(this.template);
        
        // Fill OSF select on virtual machines creation form
        var params = {
            'action': 'tenant_tiny_list',
            'controlName': 'tenant-select'
        };
        
        Wat.A.fillSelect(params);  
        
        this.renderForm();
    },
    
    renderForm: function () {
        this.templateSetupFormCustomize = Wat.A.getTemplate(this.setupCustomizeFormTemplateName);
                
        this.template = _.template(
            this.templateSetupFormCustomize, {
                filters: Wat.I.getTenantFormFilters (this.selectedSection, this.selectedTenant, this),
                columns: Wat.I.getTenantListColumns (this.selectedSection, this.selectedTenant, this)
            }
        );
        
        $(this.setupFormContainer).html(this.template);
        
        Wat.T.translate();
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        Wat.A.performAction('properties_by_qvd_object', {}, {qvd_object: this.selectedSection}, {}, this.addProperties, this, false);
    },
    
    addProperties: function (that) {
        var objProperties = that.retrievedData.result.rows;
        
        // Add properties retrieved from QVD Objects
        var templatePropertiesColumns = $('.js-column-property-template');
        var templatePropertiesFilters = $('.js-filter-property-template');
        
        $.each(objProperties, function (iProp, prop) {  
            // If any property doesnt exist in database configuration, we add it to the editor
            if (!that.currentListColumns[prop]) {    
                // Add property to columns table
                var propRow = templatePropertiesColumns.clone();
                propRow.removeClass('hidden');
                propRow.find('.js-prop-name').html(prop);
                propRow.attr('data-name', prop);
                propRow.find('.js-field-check').attr('data-name', prop);
                propRow.find('.js-field-check').attr('data-fields', prop);
                propRow.insertBefore(templatePropertiesColumns);
            }

            // If any property doesnt exist in database configuration, we add it to the editor
            if (!that.currentFormFilters[prop]) {    
                // Add property to filters table
                var propRow = templatePropertiesFilters.clone();
                propRow.removeClass('hidden');
                propRow.find('.js-prop-name').html(prop);
                propRow.attr('data-name', prop);
                propRow.find('.js-desktop-fields').attr('data-name', prop);
                propRow.find('.js-mobile-fields').attr('data-name', prop);
                propRow.find('.js-desktop-fields').attr('data-fields', prop);
                propRow.find('.js-mobile-fields').attr('data-fields', prop);
                propRow.insertBefore(templatePropertiesFilters);
            }
        });
    }
});