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
        
        this.setFilters();
        this.setColumns();
        this.setSelectedActions();
        this.setListActionButton();
        this.setBreadCrumbs();
                
        // Templates
        this.templateListCommonList = Wat.A.getTemplate('list-common');
        this.templateListCommonBlock = Wat.A.getTemplate('list-common-block');
        this.listTemplate = Wat.A.getTemplate(this.listTemplateName);
        
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
        'click input[class="check_all"]': 'checkAll',
        'click .first': 'paginationFirst',
        'click .prev': 'paginationPrev',
        'click .next': 'paginationNext',
        'click .last': 'paginationLast',
        'click a[name="filter_button"]': 'filter',
        //'keyup .filter-control input': 'filter',
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
                    if (filterControl.val() == '-1') {
                        return true;
                    }
                    break;
                case 'text':
                    if (filterControl.val() == '') {
                        return true;
                    }
                    break;
            }
            
            filters[filterControl.attr('data-filter-field')] = filterControl.val();
        });
        
        this.collection.setFilters(filters);

        // When we came from a view without elements pagination doesnt exist
        var existsPagination = $('.' + this.cid + ' .pagination .first').length > 0;

        // If the current offset is not the first page, trigger click on first button of pagination to go to the first page. 
        // This button render the list so is not necessary render in this case
        if (this.collection.offset != 1 && existsPagination) {
            $('.' + this.cid + ' .pagination .first').trigger('click');
        }
        else {
            this.fetchList();
        }
    },
    
    // Set as checked all the checkboxes of a list
    checkAll: function (e) {
        if ($(e.target).is(":checked")) {
            $('.js-check-it').prop("checked", true);
        } else {
            $('.js-check-it').prop("checked", false);
        }
    },
    
    setFilters: function () {
        this.formFilters = Wat.I.getFormFilters(this.qvdObj);

        // The superadmin have an extra filter: tenant
        
        // Every element but the hosts has tenant
        if (Wat.C.isSuperadmin() && this.collection.actionPrefix != 'host') {
            this.formFilters.tenant = {
                    'filterField': 'tenant',
                    'type': 'select',
                    'text': 'Tenant',
                    'displayDesktop': true,
                    'displayMobile': false,
                    'class': 'chosen-single',
                    'options': [
                        {
                            'value': -1,
                            'text': 'All',
                            'selected': true
                        },
                        {
                            'value': '1',
                            'text': 'Madrid',
                            'selected': false
                        },
                        {
                            'value': '3',
                            'text': 'Lisboa',
                            'selected': false
                        }
                                ]
                };
        }
    },
    
    setColumns: function () {
        this.columns = Wat.I.getListColumns(this.qvdObj);
        
        // The superadmin have an extra field on lists: tenant
        
        // Every element but the hosts has tenant
        if (Wat.C.isSuperadmin() && this.collection.actionPrefix != 'host') {
            this.columns.tenant = {
                'text': 'Tenant',
                'displayDesktop': true,
                'displayMobile': false,
                'noTranslatable': true
            };
        }
    },
    
    setSelectedActions: function () {
        this.selectedActions = Wat.I.getSelectedActions(this.qvdObj);
    },
    

    setListActionButton: function () {
        this.listActionButton = Wat.I.getListActionButton(this.qvdObj);
    },
    
    setBreadCrumbs: function () {
        this.breadcrumbs = Wat.I.getListBreadCrumbs(this.qvdObj);
    },
    
    // Fetch collection and render list
    fetchList: function (that) {
        var that = that || this;        
        
        that.collection.fetch({      
            complete: function () {
                that.renderList(that.listContainer);
                Wat.I.updateSortIcons(that);
                Wat.I.updateChosenControls();
            }
        });
    },

    // Render view with two options: all and only list with controls (list block)
    render: function () {
        var that = this;
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

        // Recursive call until target is ready
        if (!targetReady) {
            console.log('lag');
            that.interval = setInterval(that.renderListBlock, 500, that);
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
                columns: this.columns
            }
        );
        
        $(this.listContainer).html(template);
        this.paginationUpdate();
        this.shownElementsLabelUpdate();
        this.selectedActionControlsUpdate();
    },
    
    // Fill filter selects 
    fetchFilters: function () {
        var that = this;
        $.each(this.formFilters, function(name, filter) {
            if (filter.type == 'select' && filter.fillable) {
                var params = {
                    'action': name + '_tiny_list',
                    'selectedId': that.filters[filter.filterField],
                    'controlName': name
                };
                
                Wat.A.fillSelect(params);
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
        
        this.dialogConf.buttons = {
            Cancel: function () {
                $(this).dialog('close');
            },
            Create: function () {
                that.dialog = $(this);
                that.createElement($(this));
            }
        };
        
        this.dialogConf.button1Class = 'fa fa-ban';
        this.dialogConf.button2Class = 'fa fa-plus-circle';
        
        this.dialogConf.fillCallback = this.fillEditor;

        this.editorElement(e);
    },
    
    applySelectedAction: function () {
        var action = $('select[name="selected_actions_select"]').val();
        var selectedIds = [];
        $.each($('.check-it:checked'), function (iCheck, check) {
            selectedIds.push($(check).attr('data-id'));
        });
        
        if (!selectedIds.length) {
            Wat.I.showMessage({message: i18n.t('No items were selected') + '. ' + i18n.t('Nothing to do'), messageType: 'info'});
            return;
        }
        
        var filters = {
            id: selectedIds
        };
                
        switch(action) {
            case 'delete':
                var auxModel = new this.collection.model();
                this.deleteModel(filters, this.fetchList, auxModel);
                break;
            case 'block':
                var auxModel = new this.collection.model();
                this.updateModel({blocked: 1}, filters, this.fetchList, auxModel);
                break;
            case 'unblock':
                var auxModel = new this.collection.model();
                this.updateModel({blocked: 0}, filters, this.fetchList, auxModel);
                break;
            // Used in VMs
            case 'start':
                this.startVM (filters);
                break;
            case 'stop':
                this.stopVM (filters);
                break;
            case 'disconnect':
                this.disconnectVMUser (filters);
                break;
            // Used in Nodes
            case 'stop_all':
                // TODO
                break;
            // Used in Users
            case 'disconnect_all':
                // TODO
                break;
        }
    }
});
