Wat.Views.ViewsView = Wat.Views.MainView.extend({
    sideContainer: '.bb-setup-side',
    setupContainer: '.bb-setup',
    setupFormContainer: '.bb-customize-form',
    setupOption: 'customize',
    selectedSection: 'user',
    selectedTenant: '0',

    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        // If administrator is superadmin, use selected tenant. Otherwise, his tenant
        if (!Wat.C.isSuperadmin()) {
            this.selectedTenant = undefined;
        }
    },
    
    events: {
        'change select[name="obj-qvd-select"]': 'changeSection',
        'change select[name="tenant-select"]': 'changeSection',
        'change .js-desktop-fields>input': 'checkDesktopFilter',
        'change .js-mobile-fields>input': 'checkMobileFilter',
        'change .js-field-check>input': 'checkListColumn',
        'click .js-reset-views': 'resetViews'
    },
    
    resetViews: function () {
        var that = this;
        
        var dialogConf = {};

        dialogConf.title = "Reset views to default configuration";

        dialogConf.buttons = {
            Cancel: function (e) {
                $(this).dialog('close');
            },
            "Reset": function (e) {
                that.performResetViews ();
                $(this).dialog('close');
            }
        };
        
        dialogConf.button1Class = 'fa fa-ban';
        dialogConf.button2Class = 'fa fa-eraser';

        dialogConf.fillCallback = that.fillResetViewsEditor;


        Wat.I.dialog(dialogConf, this);
    },
    
    showViewsMessage: function (response) {
        var messageParams = {};

        switch (this.retrievedData.status) {
            case STATUS_SUCCESS:
                messageParams.message = $.i18n.t("Successfully resetted");
                messageParams.messageType = 'success';
                break;
            case STATUS_ZERO_SELECTED:
                messageParams.message = $.i18n.t("Nothing to do");
                messageParams.messageType = 'info';
                break;
            default:
                messageParams.message = $.i18n.t("Error resetting");
                messageParams.messageType = 'error';
                break;
        }

        Wat.I.showMessage(messageParams, response);
    },
    
    checkDesktopFilter: function (e) {
        this.targetClicked = e.target;

        var checked = $(this.targetClicked).is(':checked');
        var fieldName = $(this.targetClicked).parent().attr('data-name');
        
        var qvdObj = this.selectedSection;

        if (!this.currentFilters[fieldName] || this.currentFilters[fieldName].displayDesktop != checked) {
            var args = {
                'field': fieldName,
                'view_type': 'filter',
                'device_type': 'desktop',
                'visible': checked,
                'qvd_object': qvdObj,
                'property': !this.currentFilters[fieldName] || this.currentFilters[fieldName].property
            };
            
            this.addIDToArgs(args);

            Wat.A.performAction(this.setAction, args, {}, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, this.processCheckDesktopFilter, this);
        }
    },
    
    processCheckDesktopFilter: function (that) {  
        var checked = $(that.targetClicked).is(':checked');
        var fieldName = $(that.targetClicked).parent().attr('data-name');
        var qvdObj = that.selectedSection;

        if (that.retrievedData.status == STATUS_SUCCESS) {
            // If update is performed successfuly, update in memory
            if (that.currentFilters[fieldName]) {
                that.currentFilters[fieldName].displayDesktop = checked;
            }
            else {
                that.currentFilters[fieldName] = {
                    acls: qvdObj + ".see.properties",
                    displayDesktop: checked,
                    displayMobile: 0,
                    filterField: fieldName,
                    noTranslatable: true,
                    property: true,
                    text: fieldName,
                    type: "text",
                };
            }

            if (that.viewKind == 'admin') {
                Wat.I.formFilters[qvdObj][fieldName] = that.currentFilters[fieldName];
            }
        }
        else {
            // If update fails, change ckeckbox to previous state
            $(e.target).prop('checked', !checked);
        }
    },
    
    checkMobileFilter: function (e) {
        this.targetClicked = e.target;

        var checked = $(this.targetClicked).is(':checked');
        var fieldName = $(this.targetClicked).parent().attr('data-name');
        
        var qvdObj = this.selectedSection;
        
        if (!this.currentFilters[fieldName] || this.currentFilters[fieldName].displayMobile != checked) {
            var args = {
                'field': fieldName,
                'view_type': 'filter',
                'device_type': 'mobile',
                'visible': checked,
                'qvd_object': qvdObj,
                'property': !this.currentFilters[fieldName] || this.currentFilters[fieldName].property
            };
            
            this.addIDToArgs(args);

            Wat.A.performAction(this.setAction, args, {}, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, this.processCheckMobileFilter, this);
        }
    },

    processCheckMobileFilter: function (that) { 
        var checked = $(that.targetClicked).is(':checked');
        var fieldName = $(that.targetClicked).parent().attr('data-name');
        var qvdObj = that.selectedSection;

        if (that.retrievedData.status == STATUS_SUCCESS) {
            // If update is perfermed successfuly, update in memory
            if (that.currentFilters[fieldName]) {
                that.currentFilters[fieldName].displayMobile = checked;
            }
            else {
                that.currentFilters[fieldName] = {
                    acls: qvdObj + ".see.properties",
                    displayDesktop: 0,
                    displayMobile: checked,
                    filterField: fieldName,
                    noTranslatable: true,
                    property: true,
                    text: fieldName,
                    type: "text",
                };
            }

            if (that.viewKind == 'admin') {
                Wat.I.formFilters[qvdObj][fieldName] = that.currentFilters[fieldName];
            }
        }
        else {
            // If update fails, change ckeckbox to previous state
            $(e.target).prop('checked', !checked);
        }
    },
    
    checkListColumn: function (e) {
        this.targetClicked = e.target;

        var checked = $(this.targetClicked).is(':checked');
        var fieldName = $(this.targetClicked).parent().attr('data-name');
        
        var qvdObj = this.selectedSection;
        
        if (!this.currentColumns[fieldName] || this.currentColumns[fieldName].display != checked) {
            var args = {
                'field': fieldName,
                'view_type': 'list_column',
                'device_type': 'desktop',
                'visible': checked,
                'qvd_object': qvdObj,
                'property': !this.currentColumns[fieldName] || this.currentColumns[fieldName].property
            };
            
            this.addIDToArgs(args);

            Wat.A.performAction(this.setAction, args, {}, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, this.processCheckListColumn, this);
        }
    },
    
    processCheckListColumn: function (that) { 
        var checked = $(that.targetClicked).is(':checked');
        var fieldName = $(that.targetClicked).parent().attr('data-name');
        var qvdObj = that.selectedSection;

        if (that.retrievedData.status == STATUS_SUCCESS) {
            // If update is perfermed successfuly, update in memory
            if (that.currentColumns[fieldName]) {
                that.currentColumns[fieldName].display = checked;
            }
            else {
                that.currentColumns[fieldName] = {
                    acls: qvdObj + ".see.properties",
                    display: checked,
                    fields: [fieldName],
                    noTranslatable: true,
                    property: true,
                    text: fieldName,
                };
            }
            
            if (that.viewKind == 'admin') {
                Wat.I.listFields[qvdObj][fieldName] = that.currentColumns[fieldName];
            }
        }
        else {
            // If update fails, change ckeckbox to previous state
            $(e.target).prop('checked', !checked);
        }
    },
    
    changeSection: function (e) {
        $('.js-customize-columns').html('<i class="fa fa-spin fa-gear loading-mid"></i>');
        $('.js-customize-filters').html('<i class="fa fa-spin fa-gear loading-mid"></i>');
        this.selectedSection = $('select[name="obj-qvd-select"]').val();

        if (Wat.C.isSuperadmin()) {
            this.selectedTenant = $('select[name="tenant-select"]').val();
        }
        else {
            this.selectedTenant = undefined;
        }
        
        this.getDataAndRender();
    },
    
    render: function () {
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.setupCommon, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: this.sideMenu
            }
        );
        
        $(this.el).html(this.template);
        
        this.renderBlock();
    },
    
    renderBlock: function () {
        this.template = _.template(
            Wat.TPL.setupCustomize, {
                selectedSection: this.selectedSection,
                limitByACLs: this.limitByACLs,
                viewKind: this.viewKind,
            }
        );
        
        $(this.setupContainer).html(this.template);
        
        // Store as selected the current selected section
        this.selectedSection = $('select[name="obj-qvd-select"]').val();
        
        if (Wat.C.isSuperadmin()) {
            // Fill Tenant select on viees customization view
            var params = {
                'action': 'tenant_tiny_list',
                'controlName': 'tenant-select',
            };

            Wat.A.fillSelect(params, function () {
                Wat.I.updateChosenControls('[name="tenant-select"]');
            });  
        }
        
        this.getDataAndRender();
    },
    
    renderForm: function () {        
        this.template = _.template(
            Wat.TPL.setupFormCustomize, {
                filters: this.currentFilters,
                columns: this.currentColumns,
                limitByACLs: this.limitByACLs
            }
        );
        
        $(this.setupFormContainer).html(this.template);
                
        this.printBreadcrumbs(this.breadcrumbs, '');
        this.renderRelatedDocs();
        
        $('.js-custom-views-container').show();
        
        Wat.T.translate();
    },
    
    addIDToArgs: function (args) {
        switch (this.viewKind) {
            case 'tenant':
                // If administrator is superadmin, use selected tenant. Otherwise, no tenant filter will be used
                if (Wat.C.isSuperadmin()) {
                    args['tenant_id'] = this.selectedTenant;
                }
                break;
        }        
    }

});