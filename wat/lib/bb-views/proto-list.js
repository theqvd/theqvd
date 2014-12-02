Wat.Views.ListView = Wat.Views.MainView.extend({
    collection: {},
    sortedBy: '',
    sortedOrder: '',
    selectedActions: {},
    formFilters: {},
    columns: [],
    elementsShown: '',
    listContainer: '.bb-list',
    listBlockContainer: '.bb-list-block',
    whatRender: 'all',
    filters: {},
    selectedItems: [],
    selectedAll: false,
    listTemplateName: '',
    editorTemplateName: '',
    massiveEditorTemplateName: '',
    customCollection: false,
    infoRestrictions: false,
    
    viewKind: 'list',
    
    /*
    ** params:
    **  whatRender (string): What part of view render (all/list). Default 'all'
    **  listContainer (string): Selector of list container. Default '.bb-list'
    **  forceListColumns (object): List of columns that will be shown on list ignoring configuration. Format {checks: true, id: true, ...}
    **  forceListSelectedActions (object): List of actions to be performed over selected items that will be able ignoring configuration. Format {delete: true, block: true, ...}
    **  forceListActionButton (object): Override list action button with other button or with null value to not show it. Format {name: 'name of the button', value: 'text into button', link: 'href value'}
    **  filters (object): Conditions under the list will be filtered. Format {user: 23, ...}
    */
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this);

        // Define template names from qvd Object type
        this.listTemplateName = 'list-' + this.qvdObj;
        this.editorTemplateName = 'creator-' + this.qvdObj;
        this.massiveEditorTemplateName = 'massive-editor-' + this.qvdObj;
        
        this.setFilters();
        this.setColumns();
        this.setSelectedActions();
        this.setListActionButton();
        this.setBreadCrumbs();
                
        this.resetSelectedItems();
        
        // Templates
        this.templateListCommonList = Wat.A.getTemplate('list-common');
        this.templateListCommonBlock = Wat.A.getTemplate('list-common-block');
        this.listTemplate = Wat.A.getTemplate(this.listTemplateName);
        this.templateSelectChecks = Wat.A.getTemplate('dialog-select-checks');
        
        this.context = $('.' + this.cid);
        
        this.readParams(params);
        
        this.render();
        
        // Extend the common events with the list events and events of the specific view
        this.extendEvents(this.commonListEvents);
        this.extendEvents(this.listEvents);
        
    },
    
    readParams: function (params) {
        params = params || {};
        
        this.filters = params.filters || {};
        this.block = params.block || this.block;
        this.offset = params.offset || {};
              
        if (params.autoRender !== undefined) {
            this.autoRender = params.autoRender;
        }            
        if (params.whatRender !== undefined) {
            this.whatRender = params.whatRender;
        }            
        if (params.listContainer !== undefined) {
            this.listBlockContainer = params.listContainer;
            this.listContainer = this.listBlockContainer + ' ' + this.listContainer;
        }                  
        if (params.forceInfoRestrictions !== undefined) {
            this.infoRestrictions = params.forceInfoRestrictions;
        }
        if (params.forceListActionButton !== undefined) {
            this.listActionButton = params.forceListActionButton;
        }            
        if (params.forceListColumns !== undefined) {
            var that = this;
            
            $.each(this.columns, function(cName, column) {
                if (params.forceListColumns[cName] !== undefined && params.forceListColumns[cName]) {
                    that.columns[cName].display = true;
                }
                else {
                    that.columns[cName].display = false;
                }
            });
        }
        if (params.forceSelectedActions !== undefined) {
            var that = this;
            var selectedActions = [];
            $(this.selectedActions).each(function(index, action) {
                if (params.forceSelectedActions[action.value] !== undefined) {
                    selectedActions.push(action);
                }
            });

            this.selectedActions = selectedActions;
        }
    },
    
    commonListEvents: {
        'click th.sortable': 'sort',
        'click input.check_all': 'checkAll',
        'click input.check-it': 'checkOne',
        'click .first': 'paginationFirst',
        'click .prev': 'paginationPrev',
        'click .next': 'paginationNext',
        'click .last': 'paginationLast',
        'click a[name="filter_button"]': 'filter',
        'input .filter-control>input': 'filter',
        'change .filter-control select': 'filter',
        'click .js-button-new': 'openNewElementDialog',
        'click [name="selected_actions_button"]': 'applySelectedAction'
    },
    
    // Render list sorted by a column
    sort: function (e) { 
        // Find the TH cell, because sometimes you can click on the icon
        if ($(e.target).get(0).tagName == 'TH') {
            var sortCell = $(e.target).get(0);    
        }
        else {
            // If click on the icon, we get the parent
            var sortCell = $(e.target).parent().get(0);    
        }
        
        var sortedBy = $(sortCell).attr('data-sortby');
        
        if (sortedBy !== this.sortedBy || this.sortedOrder == '-desc') {
            this.sortedOrder = '-asc';
        }
        else {
            this.sortedOrder = '-desc';
        }
        

        this.sortedBy = sortedBy;
                
        var sort = {'field': this.sortedBy, 'order': this.sortedOrder};

        this.collection.setSort(sort);
        
        // If the current offset is not the first page, trigger click on first button of pagination to go to the first page. 
        // This button render the list so is not necessary render in this case
        if (this.collection.offset != 1) {
            $('.' + this.cid + ' .pagination .first').trigger('click');
        }
        else {   
            this.fetchList();
        }
    },
    
    // Get filter parameters of the form, set in collection, fetch list and render it
    filter: function (e) {
        if ($(e.target).hasClass('mobile-filter')) {
            var filtersContainer = '.' + this.cid + ' .filter-mobile';
        }
        else {
            var filtersContainer = '.' + this.cid + ' .filter';
        }
        
        var filters = {};
        $.each(this.formFilters, function(name, filter) {
            var filterControl = $(filtersContainer + ' [name="' + name + '"]');
            // If input text box is empty or selected option in a select is All (-1) skip filter control
            switch(filter.type) {
                case 'select':
                    if (filterControl.val() == '-1' || filterControl.val() == undefined) {
                        return true;
                    }
                    break;
                case 'text':
                    if (filterControl.val() == '' || filterControl.val() == undefined) {
                        return true;
                    }
                    break;
            }
            
            filters[filterControl.attr('data-filter-field')] = filterControl.val();
        });
        
        this.collection.setFilters(filters);

        // When we came from a view without elements pagination doesnt exist
        var existsPagination = $('.' + this.cid + ' .pagination .first').length > 0;

        this.resetSelectedItems ();
        
        // If the current offset is not the first page, trigger click on first button of pagination to go to the first page. 
        // This button render the list so is not necessary render in this case
        if (this.collection.offset != 1 && existsPagination) {
            $('.' + this.cid + ' .pagination .first').trigger('click');
        }
        else {
            this.fetchList();
        }
    },
    
    updateFilterNotes: function () {
        // Show-Hide filter notes only when view is not embeded
        if (this.cid == Wat.CurrentView.cid) {
            var filtersContainer = '.' + this.cid + ' .filter';
            
            var filterNotes = {};
            $.each(this.formFilters, function(name, filter) {
                var filterControl = $(filtersContainer + ' [name="' + name + '"]');
                // If input text box is empty or selected option in a select is All (-1) skip filter control
                switch(filter.type) {
                    case 'select':
                        if (filterControl.val() == '-1' || filterControl.val() == undefined) {
                            return true;
                        }
                        filterNotes[filterControl.attr('name')] = {
                            'label': $('label[for="' + filterControl.attr('name') + '"]').html(),
                            'value': filterControl.find('option:selected').html(),
                            'type': filter.type
                        };
                        break;
                    case 'text':
                        if (filterControl.val() == '' || filterControl.val() == undefined) {
                            return true;
                        }
                        filterNotes[filterControl.attr('name')] = {
                            'label': $('label[for="' + filterControl.attr('name') + '"]').html(),
                            'value': filterControl.val(),
                            'type': filter.type
                        };
                        break;
                }
            });
        
            if ($.isEmptyObject(filterNotes)) {
                $('.js-filter-notes').hide();
            }
            else {
                $('.filter-notes-list li').remove();
                $.each(filterNotes, function(fNoteName, fNote) {
                    $('.js-filter-notes-list').append('<li><a href="javascript:" class="js-delete-filter-note fa fa-trash" data-filter-name="' + fNoteName + '" data-filter-type="' + fNote.type + '"></a>' + fNote.label + ': ' + fNote.value + '</li>');
                });
                $('.js-filter-notes').show();
            }
        }
    },
    
    checkOne: function (e) {
        var itemId = $(e.target).attr('data-id');
        if ($(e.target).is(":checked")) {
            this.selectedItems.push(parseInt(itemId));
        }
        else {
            var posItem = $.inArray(parseInt(itemId), this.selectedItems);
            this.selectedItems.splice( posItem, 1 );
        }
        
        if (this.selectedItems.length == this.collection.elementsTotal) {
            this.selectedAll = true;
            $('.check_all').prop("checked", true);
        }
        else {
            this.selectedAll = false;
            $('.check_all').prop("checked", false);
        }
        
        Wat.I.updateSelectedItems(this.selectedItems.length);
    },
    
    // Set as checked all the checkboxes of a list and store the IDs
    checkAll: function (e) {        
        if ($(e.target).is(":checked")) {
            var hiddenElements = this.collection.elementsTotal > this.collection.length;
            var that = this;
            
            if (hiddenElements) {
                var dialogConf = {
                    title: '<i class="fa fa-question"></i>',
                    buttons : {
                        "Select only visible items": function () {
                            $('.js-check-it').prop("checked", true);
                            that.selectedItems = [];
                            $.each($('.js-check-it'), function (iCheckbox, checkbox) {
                                that.selectedItems.push(parseInt($(checkbox).attr('data-id')));
                            });
                            $(this).dialog('close');
                            Wat.I.updateSelectedItems(that.selectedItems.length);
                        },
                        "Select all": function () {
                            $('.js-check-it').prop("checked", true);
                            Wat.A.performAction(that.qvdObj + '_all_ids', {}, that.collection.filters, {}, that.storeAllSelectedIds, that, false);
                            $(this).dialog('close');
                            Wat.I.updateSelectedItems(that.selectedItems.length);
                            that.selectedAll = true;
                        }
                    },
                    button1Class : 'fa fa-eye',
                    button2Class : 'fa fa-th',
                    fillCallback : this.fillCheckSelector
                }

                Wat.I.dialog(dialogConf);
            }
            else {
                $('.js-check-it').prop("checked", true);
                that.selectedItems = [];
                $.each($('.js-check-it'), function (iCheckbox, checkbox) {
                    that.selectedItems.push(parseInt($(checkbox).attr('data-id')));
                });
                Wat.I.updateSelectedItems(that.selectedItems.length);
            }
        } else {
            $('.js-check-it').prop("checked", false);
            this.resetSelectedItems ();
            Wat.I.updateSelectedItems(this.selectedItems.length);
        }
        
        Wat.I.updateSelectedItems(this.selectedItems.length);
    },
    
    storeAllSelectedIds: function (that) {
        var maxSelectableItems = 2000;
        if (that.retrievedData.rows.length > maxSelectableItems) {
            that.selectedItems = that.retrievedData.rows.slice(0, maxSelectableItems);
        }
        else {
            that.selectedItems = that.retrievedData.rows;
        }
    },
    
    fillCheckSelector: function (target) {
        var that = Wat.CurrentView;
        
        // Add common parts of editor to dialog
        that.template = _.template(
                    that.templateSelectChecks, {
                    }
                );

        target.html(that.template);
    },
    
    setFilters: function () {
        // Get Filters from configuration
        this.formFilters = Wat.I.getFormFilters(this.qvdObj);

        // Check filters on columns to remove forbidden ones
        Wat.C.purgeConfigData(this.formFilters);
        
        // The superadmin have an extra filter: tenant
        
        // Every element but the hosts has tenant
        var classifiedByTenant = $.inArray(this.qvdObj, QVD_OBJS_CLASSIFIED_BY_TENANT) != -1;
        if (Wat.C.isSuperadmin() && classifiedByTenant) {
            var tenantFilter = { tenant: 
                                    {
                                        'filterField': 'tenant_id',
                                        'type': 'select',
                                        'text': 'Tenant',
                                        'displayDesktop': true,
                                        'displayMobile': false,
                                        'class': 'chosen-single',
                                        'fillable': true,
                                        'options': [
                                            {
                                                'value': -1,
                                                'text': 'All',
                                                'selected': true
                                            }
                                                    ]
                                    }
                               };
            
            // Add tenant filter at the begining
            this.formFilters = $.extend (tenantFilter, this.formFilters);
        }
    },
    
    setColumns: function () {
        // Get Columns from configuration
        this.columns = Wat.I.getListColumns(this.qvdObj);
                
        // Check acls on columns to remove forbidden ones
        Wat.C.purgeConfigData(this.columns);
        
        // The superadmin have an extra field on lists: tenant
        
        // Every element but the hosts has tenant
        var classifiedByTenant = $.inArray(this.qvdObj, QVD_OBJS_CLASSIFIED_BY_TENANT) != -1;
        if (Wat.C.isSuperadmin() && classifiedByTenant) {
            this.columns.tenant = {
                'text': 'Tenant',
                'displayDesktop': true,
                'displayMobile': false,
                'noTranslatable': true
            };
        }
    },
    
    setSelectedActions: function () {
        // Get Actions from configuration
        this.selectedActions = Wat.I.getSelectedActions(this.qvdObj);
        
        // Check actions on columns to remove forbidden ones
        Wat.C.purgeConfigData(this.selectedActions);
    },

    setListActionButton: function () {
        // Get Action button from configuration
        this.listActionButton = Wat.I.getListActionButton(this.qvdObj);
        
        // Check actions on columns to remove forbidden ones
        Wat.C.purgeConfigData(this.listActionButton);
    },
    
    setBreadCrumbs: function () {
        this.breadcrumbs = Wat.I.getListBreadCrumbs(this.qvdObj);
    },
    
    // Fetch collection and render list
    fetchList: function (that) {
        var that = that || this;        
        
        that.collection.fetch({      
            complete: function () {
                // If loaded page is not the first one and is empty, go to previous page
                if (that.collection.offset > 1 && that.collection.length == 0) {
                    that.collection.offset--;
                    that.fetchList(that);
                    return;
                }
                
                that.renderList(that.listContainer);
                Wat.I.updateSortIcons(that);
                Wat.I.updateChosenControls();
            }
        });
    },

    // Render view with two options: all and only list with controls (list block)
    render: function () {
        var that = this;
        
        // If user have not access to main section, redirect to home
        if (that.whatRender && !Wat.C.checkACL(that.qvdObj + '.see-main.')) {
            Wat.Router.app_router.trigger('route:defaultRoute');
            return;
        }
        
        this.collection.fetch({      
            complete: function () {
                switch(that.whatRender) {
                    case 'all':
                        that.renderAll();
                        break;
                    case 'list':
                        that.renderListBlock();
                        break;
                }
            }
        });
    },
    
    // Render common elements of lists and then render list with controls (list block)
    renderAll: function () {
        // Fill the html with the template and the collection
        var template = _.template(
            this.templateListCommonList, {
                formFilters: this.formFilters,
                cid: this.cid
            });
        
        $(this.el).html(template);

        this.printBreadcrumbs(this.breadcrumbs, '');
        
        this.renderListBlock();
    },
    
    //Render list with controls (list block)
    renderListBlock: function (that) {
        var that = that || this;

        var targetReady = $(that.listBlockContainer).length != 0;
        
        // Target is not ready
        if (!targetReady) {
            return;
        }
        
        clearInterval(that.interval);

        // Fill the list
        var template = _.template(
            that.templateListCommonBlock, {
                formFilters: that.formFilters,
                selectedActions: that.selectedActions,
                listActionButton: that.listActionButton,
                cid: this.cid
            }
        );

        $(that.listBlockContainer).html(template);
        $(that.listBlockContainer).html(template);
        $(that.listBlockContainer).html(template);
                        
        this.fetchFilters();

        that.renderList();
        
        // Translate the strings rendered. 
        // This translation is only done here, in the first charge. 
        // When the list were rendered in actions such as sorting, filtering or pagination, 
        // the strings will be individually translated
        Wat.T.translate();
    },    
    
    // Render only the list. Usefull to functions such as pagination, sorting and filtering where is not necessary render controls
    renderList: function () {
        // Fill the list
        var template = _.template(
            this.listTemplate, {
                models: this.collection.models,
                filters: this.collection.filters,
                columns: this.columns,
                selectedItems: this.selectedItems,
                selectedAll: this.selectedAll,
                infoRestrictions: this.infoRestrictions
            }
        );
        
        $(this.listContainer).html(template);
        this.paginationUpdate();
        this.shownElementsLabelUpdate();
        this.selectedActionControlsUpdate();
        
        Wat.I.updateSelectedItems(this.selectedItems.length);
        
        // Open websockets for live fields
        if (this.liveFields) {
            Wat.WS.openListWebsockets(this.qvdObj, this.collection.models, this.liveFields, this.cid);
        }
        
        this.updateFilterNotes();
    },
    
    // Fill filter selects 
    fetchFilters: function () {
        var that = this;
                
        var existsInSupertenant = $.inArray(that.qvdObj, QVD_OBJS_EXIST_IN_SUPERTENANT) != -1;

        $.each(this.formFilters, function(name, filter) {
            if (filter.type == 'select' && filter.fillable) {
                var params = {
                    'action': name + '_tiny_list',
                    'selectedId': that.filters[filter.filterField],
                    'controlName': name
                };
                
                Wat.A.fillSelect(params);

                // In tenant case (except in admins list) has not sense show supertenant in filters
                if (!existsInSupertenant && name == 'tenant') {
                    // Remove supertenant from tenant selector
                    $('select[name="tenant"] option[value="0"]').remove();
                }
            }
        });
    },
    
    shownElementsLabelUpdate: function () {
        var context = $('.' + this.cid);

        var elementsShown = this.collection.length;
        var elementsTotal = this.collection.elementsTotal;

        context.find(' .shown-elements .elements-shown').html(elementsShown);
        context.find(' .shown-elements .elements-total').html(elementsTotal);
    },
    
    selectedActionControlsUpdate: function () {
        // Depend on the number of elements shown, we enabled/disabled selected elements controls
        if (this.elementsShown > 0) {
            $('a[name="selected_actions_button"]').removeClass('disabled chosen-disabled');
            $('select[name="selected_actions_select"]').removeAttr('disabled');
            $('select[name="selected_actions_select"]').next().removeClass('chosen-disabled');
        }
        else {
            $('a[name="selected_actions_button"]').addClass('disabled');
            $('select[name="selected_actions_select"]').attr('disabled', 'disabled');
            $('select[name="selected_actions_select"]').next().addClass('chosen-disabled');
        }
    },
    
    paginationUpdate: function () {  
        Wat.WS.closeViewWebsockets(this.cid);

        this.elementsShown = this.collection.length;
        var totalPages = Math.ceil(this.collection.elementsTotal/this.collection.block);
        var currentPage = this.collection.offset;

        var context = $('.' + this.cid);

        context.find('.pagination_current_page').html(currentPage || 1);
        context.find('.pagination_total_pages').html(totalPages || 1);
        
        context.find('.pagination a').removeClass('disabled');
        
        if (totalPages <= 1) {
            context.find('.pagination a').addClass('disabled');
        }
        else if (currentPage == 1){
            context.find('.pagination a.first').addClass('disabled');
            context.find('.pagination a.prev').addClass('disabled');
        }
        else if (currentPage == totalPages) {
            context.find('.pagination a.next').addClass('disabled');
            context.find('.pagination a.last').addClass('disabled');
        }
    },

    paginationNext: function (e) {
        this.paginationMove($(e.target), 'next');
    },

    paginationPrev: function (e) {
        this.paginationMove($(e.target), 'prev');
    },

    paginationFirst: function (e) {
        this.paginationMove($(e.target), 'first');
    },

    paginationLast: function (e) {
        this.paginationMove($(e.target), 'last');
    },
    
    paginationMove: function (context, dir, render) {
        var totalPages = Math.ceil(this.collection.elementsTotal/this.collection.block);
        var currentPage = this.collection.offset;
        
        // Check if the current page is first or last one to avoid out of limits situation
        switch (dir) {
            case 'first':
            case 'prev':
                // Check if the current page is the first one
                if (currentPage == 1) {
                    return;
                }
                break;
            case 'next':
            case 'last':
                if (currentPage == totalPages) {
                    return;
                }
                break;
        }
        
        // Make pagination move
        switch (dir) {
            case 'first':
                this.collection.offset = 1;
                break;
            case 'prev':
                this.collection.offset--;
                break;
            case 'next':
                this.collection.offset++;
                break;
            case 'last':
                this.collection.offset = totalPages;
                break;
        }
                             
        this.fetchList();        
    },
    
    openNewElementDialog: function (e) {
        var that = this;
        
        this.templateEditor = Wat.A.getTemplate(this.editorTemplateName);
        
        this.dialogConf.buttons = {
            Cancel: function (e) {
                $(this).dialog('close');
            },
            Create: function (e) {
                if (Wat.CurrentView.qvdObj == 'di') {
                    Wat.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
                }
                that.dialog = $(this);
                that.createElement($(this));
            }
        };

        this.dialogConf.button1Class = 'fa fa-ban';
        this.dialogConf.button2Class = 'fa fa-plus-circle';
        
        this.dialogConf.fillCallback = this.fillEditor;

        this.editorElement(e);
    },
    
    openMassiveChangesDialog: function (that) {        
        that.templateEditor = Wat.A.getTemplate(that.massiveEditorTemplateName);
        
        that.dialogConf.buttons = {
            Cancel: function () {
                $(this).dialog('close');
            },
            Update: function () {
                that.dialog = $(this);
                that.updateMassiveElement($(this), that.selectedItems);
            }
        };
        
        that.dialogConf.button1Class = 'fa fa-ban';
        that.dialogConf.button2Class = 'fa fa-save';
        
        that.dialogConf.fillCallback = that.fillMassiveEditor;
        that.dialogConf.title = i18n.t('Massive changes over __counter__ elements', {counter: that.selectedItems.length});

        that.editorElement();
    },
    
    fillMassiveEditor: function (target) {
        var that = Wat.CurrentView;

        var enabledProperties = $.inArray(that.qvdObj, QVD_OBJS_WITH_PROPERTIES) != -1;
        var enabledCreateProperties = true;
        var enabledUpdateProperties = false;
        var enabledDeleteProperties = false;
        
        // Add common parts of editor to dialog
        that.template = _.template(
                    that.templateEditorCommon, {
                        classifiedByTenant: 0,
                        editorMode: 'massive_edit',
                        isSuperadmin: Wat.C.isSuperadmin(), 
                        enabledProperties: enabledProperties, 
                        enabledCreateProperties: enabledCreateProperties,
                        enabledUpdateProperties: enabledUpdateProperties,
                        enabledDeleteProperties: enabledDeleteProperties,
                        blocked: undefined,
                        properties: [],
                        cid: that.cid
                    }
                );
        
        target.html(that.template);

        this.templateEditorCommon = Wat.A.getTemplate('editor-common');

        // Add specific parts of editor to dialog
        that.template = _.template(
                    that.templateEditor, {
                        model: that.model
                    }
                );

        $(that.editorContainer).html(that.template);
        
        that.configureMassiveEditor (that);
    },
    
    applySelectedAction: function () { 
        var action = $('select[name="selected_actions_select"]').val();

        if (!this.selectedItems.length) {
            Wat.I.showMessage({message: i18n.t('No items were selected') + '. ' + i18n.t('Nothing to do'), messageType: 'info'});
            return;
        }

        this.applyFilters = {
            id: this.selectedItems
        };

        var elementsOutOfView = false;
        if (this.collection.block < this.selectedItems.length) {
            elementsOutOfView = true;
        }
        else {
            $.each(this.selectedItems, function (iId, item) {
                if ($('.check-it[data-id="' + item + '"]').html() == undefined) {
                    elementsOutOfView = true;
                    return false;
                }
            });
        }

        var that = this;
        switch(action) {
            case 'delete':
                Wat.I.confirm('dialog-confirm-undone', that.applyDelete, that);
                break;
            case 'block':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog-confirm-out-of-view', that.applyBlock, that);
                }
                else {
                    that.applyBlock(that);
                }
                break;
            case 'unblock':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog-confirm-out-of-view', that.applyUnblock, that);
                }
                else {
                    that.applyUnblock(that);
                }
                break;
            case 'massive_changes':
                // The function that will open the Massive changes dialog is: openMassiveChangesDialog
                // Each qvd object have the option of do things before with setupMassiveChangesDialog and after with configureMassiveEditor                
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog-confirm-out-of-view', that.setupMassiveChangesDialog, that);
                }
                else {
                    that.setupMassiveChangesDialog(that);
                }
                break;
            // Used in VMs
            case 'start':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog-confirm-out-of-view', that.applyStart, that);
                }
                else {
                    that.applyStart(that);
                }
                break;
            case 'stop':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog-confirm-out-of-view', that.applyStop, that);
                }
                else {
                    that.applyStop(that);
                }
                break;
            case 'disconnect':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog-confirm-out-of-view', that.applyDisconnect, that);
                }
                else {
                    that.applyDisconnect(that);
                }
                break;
            // Used in Hosts
            case 'stop_all':
                // TODO
                break;
            // Used in Users
            case 'disconnect_all':
                // TODO
                break;
            case 'delete_acl':
                Wat.I.confirm('dialog-confirm-undone', that.applyDeleteACL, that);
                break;
        };
    },
                                               
    applyDelete: function (that) {
        var auxModel = new that.collection.model();  
        that.resetSelectedItems ();
        that.deleteModel(that.applyFilters, that.fetchList, auxModel);
    },
                                               
    applyBlock: function (that) {
        var auxModel = new that.collection.model();
        that.resetSelectedItems ();
        that.updateModel({blocked: 1}, that.applyFilters, that.fetchList, auxModel);
    },
                                               
    applyUnblock: function (that) {
        var auxModel = new that.collection.model();
        that.resetSelectedItems ();
        that.updateModel({blocked: 0}, that.applyFilters, that.fetchList, auxModel);
    },
    
    resetSelectedItems: function () {
        this.selectedAll = false;
        this.selectedItems = [];
        $('.js-check-it').prop('checked', false);
        $('.check_all').prop('checked', false);
    },
    
    setupMassiveChangesDialog: function (that) {
        that.openMassiveChangesDialog(that);
        // Overrided from specific list view if necessary
    },
    
    configureMassiveEditor: function (that) {
        // Overrided from specific list view if necessary
    },
    
    updateMassiveElement: function (dialog, id) {
        var valid = Wat.Views.ListView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
        
        var arguments = {};
        
        if (properties.delete.length > 0 || !$.isEmptyObject(properties.set)) {
            arguments['__properties_changes__'] = properties;
        }
        
        var filters = {"id": id};

        this.resetSelectedItems();
        
        var auxModel = {};
        
        switch (this.qvdObj) {
            case 'user':
                auxModel = new Wat.Models.User();
                break;
            case 'vm':
                auxModel = new Wat.Models.VM();
                break;
            case 'host':
                auxModel = new Wat.Models.Host();
                break;
            case 'osf':
                auxModel = new Wat.Models.OSF();
                break;
            case 'di':
                auxModel = new Wat.Models.DI();
                break;
        }
        
        this.updateModel(arguments, filters, this.fetchList, auxModel);
    },
});
