Wat.Views.SetupCustomizeView = Wat.Views.MainView.extend({
    setupCommonTemplateName: 'setup-common',
    setupCustomizeTemplateName: 'setup-customize',
    setupCustomizeFormTemplateName: 'setup-customize-form',
    sideContainer: '.bb-setup-side',
    setupContainer: '.bb-setup',
    setupFormContainer: '.bb-customize-form',
    setupOption: 'customize',
    selectedSection: 'user',

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
        'click a.button-update-customize': 'updateCustomize'
    },
    
    changeSection: function (e) {
        this.selectedSection = $(e.target).val();
        this.renderForm();
    },
    
    updateCustomize: function (e) {
        return;
        
        var qvdObj = this.selectedSection;
                    
        var newCustomization = {};

        // Get the columns checked and compare with current ones
            var currentColumns = Wat.I.getListColumns(qvdObj);
            var columnsByField = {};
            $.each($('.customize-columns input[type="checkbox"]'), function (iCheckbox, checkbox) { 
                var checked = $(checkbox).is(':checked');
                var fieldName = $(checkbox).parent().attr('data-name');
                var fields = $(checkbox).parent().attr('data-fields').split(',');
                $.each(fields, function (iField, field) {
                    columnsByField[field] = columnsByField[field] || {};
                    columnsByField[field][fieldName] = checked;
                    
                    newCustomization[field] = newCustomization[field] || {};
                    newCustomization[field]['listFields'] = newCustomization[field]['listFields'] || {};
                    newCustomization[field]['listFields'][fieldName] = checked;
                });
            });
        
        // Get the filters checked and compare with current ones
            var currentFilters = Wat.I.getFormFilters(qvdObj);
            var currentFiltersByField = Wat.I.getFormFiltersByField(qvdObj);

            // Mobile
                var mobileFiltersByField = {};
                $.each($('.customize-filters .js-mobile-fields input[type="checkbox"]'), function (iCheckbox, checkbox) { 
                    var checked = $(checkbox).is(':checked');
                    var fieldName = $(checkbox).parent().attr('data-name');
                    var field = $(checkbox).parent().attr('data-field');

                    mobileFiltersByField[field] = mobileFiltersByField[field] || {};
                    mobileFiltersByField[field][fieldName] = checked;
                    
                    newCustomization[field] = newCustomization[field] || {};
                    newCustomization[field]['mobileFilters'] = newCustomization[field]['mobileFilters'] || {};
                    newCustomization[field]['mobileFilters'][fieldName] = checked;
                });
        
            // Desktop
                var desktopFiltersByField = {};
                $.each($('.customize-filters .js-desktop-fields input[type="checkbox"]'), function (iCheckbox, checkbox) { 
                    var checked = $(checkbox).is(':checked');
                    var fieldName = $(checkbox).parent().attr('data-name');
                    var field = $(checkbox).parent().attr('data-field');
                    
                    desktopFiltersByField[field] = desktopFiltersByField[field] || {};
                    desktopFiltersByField[field][fieldName] = checked;
                    
                    newCustomization[field] = newCustomization[field] || {};
                    newCustomization[field]['desktopFilters'] = newCustomization[field]['desktopFilters'] || {};
                    newCustomization[field]['desktopFilters'][fieldName] = checked;
                });
        
        // Compare new customization with current customization to perform changes
            var currentCustomization = Wat.I.getCurrentCustomization(qvdObj);
            var customizationChanges = {}
            
            $.each(newCustomization, function (nameColumn, column) {
                var somethingChanges = false;
                $.each(column, function (nameSection, section) {
                    if (JSON.stringify(currentCustomization[nameColumn][nameSection]) != JSON.stringify(section)) {
                        somethingChanges = true;
                        // If we find any difference, we break out the loop (not olny this iteration)
                        return false;
                    }
                });
                       
                if (somethingChanges) {
                    customizationChanges[nameColumn] = column;
                }
            });

        // Perform changes
            if ($.isEmptyObject(customizationChanges)) {
                Wat.I.showMessage({message: i18n.t('No changes were detected') + '. ' + i18n.t('Nothing to do'), messageType: 'info'});
            }
            else {
                var that = this;
                
                that.temp = that.temp || {};
                that.temp.customModifications = Object.keys(customizationChanges).length;

                $.each (customizationChanges, function (fieldName, field) {   
                    var params = {
                        fieldName: fieldName,
                        fieldOptions: JSON.stringify(field),
                        that: that,
                        qvdObj: qvdObj
                    };

                    Wat.A.performAction('config_field_get_list', {}, {qvd_obj: qvdObj, name: fieldName}, {}, that.updateCustomField, params);
                });
            }

    },
    
    updateCustomField: function (params) {
        var that = params.that;
        
        var id = 0;
        var name = '';
        var qvdObj = '';
        
        // The search by name is substring, so in example for 'id' search, it retrieve host_id, name_id...
        $.each(params.retrievedData.result.rows, function(iRow, row) {
            if (row.name == params.fieldName) {
                id = row.id;
                name = row.name;
                qvdObj = row.qvd_obj;
                return false;
            }
        });            
        
        var newOptions = params.fieldOptions;

        Wat.A.performAction('config_field_update', {'filter_options': newOptions}, {id: id}, {}, that.updateCustomFieldDiscount, params, false);
    },
    
    updateCustomFieldDiscount: function (params) {
        var that = params.that;
        
        if (params.retrievedData.status != 0) {
            Wat.I.showMessage({message: 'Error updating', messageType: "error"});
            return;
        }
        
        that.temp.customModifications--;

        if (that.temp.customModifications == 0) {
            delete that.temp.customModifications;
            
            // Update interface data using database
            Wat.I.setCustomizationFields(params.qvdObj);

            Wat.I.showMessage({message: 'Successfully updated', messageType: "success"});
        }
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
                filters: Wat.I.getFormFilters(this.selectedSection),
                columns: Wat.I.getListColumns(this.selectedSection)
            }
        );
        
        $(this.setupFormContainer).html(this.template);
        
        Wat.T.translate();
        
        this.printBreadcrumbs(this.breadcrumbs, '');
    }
});