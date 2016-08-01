Up.Views.ListView = Up.Views.MainView.extend({
    collection: {},
    sortedBy: '',
    sortedOrder: '',
    formFilters: {},
    columns: [],
    listContainer: '.bb-list',
    listBlockContainer: '.bb-list-block',
    whatRender: 'all',
    filters: {},
    selectedItems: [],
    selectedAll: false,
    customCollection: false,
    infoRestrictions: false,
    initFilters: {},
    
    viewKind: 'list',
    
    /*
    ** params:
    **  whatRender (string): What part of view render (all/list). Default 'all'
    **  listContainer (string): Selector of list container. Default '.bb-list'
    **  forceListColumns (object): List of columns that will be shown on list ignoring configuration. Format {checks: true, id: true, ...}
    **  forceListActionButton (object): Override list action button with other button or with null value to not show it. Format {name: 'name of the button', value: 'text into button', link: 'href value'}
    **  filters (object): Conditions under the list will be filtered. Format {user: 23, ...}
    */
    
    initialize: function (params) {    
		// If there are fixed filters, add them to collection
        if (!$.isEmptyObject(Up.I.fixedFilters)) {
            params.filters = $.extend({}, params.filters, Up.I.fixedFilters);
            this.collection.filters = $.extend({}, this.collection.filters, Up.I.fixedFilters);
            
            var classifiedByTenant = $.inArray(this.qvdObj, QVD_OBJS_CLASSIFIED_BY_TENANT) != -1;
            if (!classifiedByTenant && this.collection.filters['tenant_id']) {
                delete this.collection.filters['tenant_id'];
            }
        }
        
        Up.Views.MainView.prototype.initialize.apply(this);
                
        this.context = $('.' + this.cid);
        
        this.readParams(params);
    
        // Extend the common events with the list events and events of the specific view
        this.extendEvents(this.commonListEvents);
        this.extendEvents(this.listEvents);
        this.addListTemplates();
        
        Up.A.getTemplates(this.templates, this.render); 
    },
    
    addListTemplates: function () {
        var templates = Up.I.T.getTemplateList('list', {qvdObj: this.qvdObj});
        
        templates["list-grid_" + this.qvdObj] = {
            name: 'list/' + this.qvdObj + '-grid'
        };  
        
        templates["list-list_" + this.qvdObj] = {
            name: 'list/' + this.qvdObj + '-list'
        };
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    readParams: function (params) {
        params = params || {};
        
        this.filters = params.filters || {};
        this.initFilters = $.extend({}, this.filters);
        
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
    },
    
    commonListEvents: {
        'click input.check-it': 'checkOne',
        'click .first': 'paginationFirst',
        'click .prev': 'paginationPrev',
        'click .next': 'paginationNext',
        'click .last': 'paginationLast',
        'click a[name="filter_button"]': 'filter',
        'change .filter-control select': 'filter',
        'input .filter-control input.date-filter': 'filter',
        'input .pagination input.js-current-page': 'typePage',
        'keypress .pagination input.js-current-page': 'pressPage',
        'click .js-unckeck-all': 'resetSelectedItems'
    },
    
    // Get filter parameters of the form, set in collection, fetch list and render it
    filter: function (e) {
        var that = this;
        
        $('.list').html(HTML_MID_LOADING);

        if (e && $(e.target).hasClass('mobile-filter')) {
            var filtersContainer = '.' + this.cid + ' .filter-mobile';
        }
        else {
            var filtersContainer = '.' + this.cid + ' .filter';
        }
        
        // Solve dependences in case of fussioned filters
        if (e) {
            Up.I.solveFilterDependences($(e.target).attr('name'), $(e.target).attr('data-filter-field'));
        }
        
        var filters = {};
        $.each(this.formFilters, function(name, filter) {
            var filterControl = $(filtersContainer + ' [name="' + name + '"]');
            
            // If current field exist in initFilters, delete it to avoid use it when "All" option is selected
            if (that.initFilters && that.initFilters[filterControl.attr('data-filter-field')]) {
                delete that.initFilters[filterControl.attr('data-filter-field')];
            }
            
            // If input text box is empty or selected option in a select is All skip filter control
            switch(filter.type) {
                case 'select':
                    if (filterControl.val() == FILTER_ALL || filterControl.val() == undefined) {
                        return true;
                    }
                    
                    // If is a "not" filter, store it with negation operation
                    if (filterControl.find('option:selected[data-not]').length == 1) {
                        filters[filterControl.attr('data-filter-field')] = {
                            "!=": filterControl.val()
                        };
                    }
                    else if (filter.transform) {
                        switch (filter.transform) {
                            case 'dateLessThanPast':
                                filters[filterControl.attr('data-filter-field')] = {
                                    "<": Up.U.getRelativeDate(filterControl.val() * -1)
                                };
                                break;
                            case 'dateGreatThanPast':
                                filters[filterControl.attr('data-filter-field')] = {
                                    ">": Up.U.getRelativeDate(filterControl.val() * -1)
                                };
                                break;
                            case 'dateLessThanFuture':
                                filters[filterControl.attr('data-filter-field')] = {
                                    "<": Up.U.getRelativeDate(filterControl.val())
                                };
                                break;
                            case 'dateGreatThanFuture':
                                filters[filterControl.attr('data-filter-field')] = {
                                    ">": Up.U.getRelativeDate(filterControl.val())
                                };
                                break;
                        }
                    }
                    else {
                        filters[filterControl.attr('data-filter-field')] = filterControl.val();
                    }
                    break;
                case 'text':
                    if (filterControl.val() == '' || filterControl.val() == undefined) {
                        return true;
                    }
                    
                    if (filter.transform) {
                        switch (filter.transform) {
                            case 'dateMin':
                                if (filters[filterControl.attr('data-filter-field')] == undefined) {
                                    filters[filterControl.attr('data-filter-field')] = {};
                                }
                                
                                filters[filterControl.attr('data-filter-field')][">="] = filterControl.val() + ' 00:00:00';
                                break;
                            case 'dateMax':
                                if (filters[filterControl.attr('data-filter-field')] == undefined) {
                                    filters[filterControl.attr('data-filter-field')] = {};
                                }
                                
                                filters[filterControl.attr('data-filter-field')]["<="] = filterControl.val() + ' 23:59:59';
                                break;
                        }
                        
                        // If dateMin and dateMax were defined, change them by -between special operator
                        switch (filter.transform) {
                            case 'dateMin':
                            case 'dateMax':
                                if (filters[filterControl.attr('data-filter-field')]["<="] != undefined && filters[filterControl.attr('data-filter-field')][">="] != undefined) {
                                    filters[filterControl.attr('data-filter-field')]["-between"] = [filters[filterControl.attr('data-filter-field')][">="], filters[filterControl.attr('data-filter-field')]["<="]];
                                    delete filters[filterControl.attr('data-filter-field')][">="];
                                    delete filters[filterControl.attr('data-filter-field')]["<="];
                                }
                                break;
                        }
                    }
                    else {
                        // Substring search syntax
                        filters[filterControl.attr('data-filter-field')] = {
                            "~" : '%' + filterControl.val() + '%'
                        };
                    }
                    break;
            }
        });
        
        // Add the init filters to filters
        filters = $.extend({}, this.initFilters, filters);
        
        this.collection.setFilters(filters);

        // When we came from a view without elements pagination doesnt exist
        var existsPagination = $('.' + this.cid + ' .pagination .first').length > 0;

        this.resetSelectedItems ();
        
        var searchHash = Up.U.transformFiltersToSearchHash(filters);
        var currentHash = '#' + this.qvdObj + 's/' + searchHash;

        // If pushState is available in browser, modify hash with current section
        if (history.pushState) {
            history.pushState(searchHash, null, currentHash);
        }
        
        // If the current offset is not the first page, trigger click on first button of pagination to go to the first page. 
        // This button render the list so is not necessary render in this case
        if (this.collection.offset != 1 && existsPagination) {
            $('.' + this.cid + ' .pagination .first').trigger('click');
        }
        else {
            var params = {};
                
            // If there are free search filters, send parameters with container and typed search to compare with search 
            // on input when search been done and control concurrency
            if ($(filtersContainer).find('.filter-control>input[type="text"]').length > 0) {
                params.filtersContainer = filtersContainer;
                params.typedSearch = $(filtersContainer).find('.filter-control>input[type="text"]').val();
            }

            this.fetchList($.extend({}, this, params));
        }
    },
    
    /* Clean filter from object memory and collection */
    cleanFilter: function (fKey) {
        delete Up.CurrentView.filters[fKey];
        delete Up.CurrentView.initFilters[fKey];
        Up.CurrentView.collection.deleteFilter(fKey);
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
        
        Up.I.updateSelectedItems(this.selectedItems.length);
    },
    
    storeAllSelectedIds: function (that) {
        var maxSelectableItems = 2000;
        
        if (that.retrievedData.rows.length > maxSelectableItems) {
            that.selectedItems = that.retrievedData.rows.slice(0, maxSelectableItems);
        }
        else {
            that.selectedItems = that.retrievedData.rows;
        }
        
        Up.I.closeDialog(that.dialog);
        Up.I.updateSelectedItems(that.selectedItems.length);
        that.selectedAll = true;
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
                Up.I.updateSortIcons(that);
                Up.I.updateChosenControls();
            }
        });
    },
    
    // Render view with two options: all and only list with controls (list block)
    render: function () {
        var that = this;
        
        var embeddedView = that.cid != Up.CurrentView.cid;
        
        // If user have not access to main section, redirect to home
        if (!embeddedView && that.whatRender && !Up.C.checkACL(that.qvdObj + '.see-main.')) {
            Up.Router.upRouter.trigger('route:defaultRoute');
            return;
        }
        
        this.collection.fetch({      
            success: function () {
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
            Up.TPL.listCommonList, {
                formFilters: this.formFilters,
                currentFilters: this.collection.filters,
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
            Up.TPL.listCommonBlock, {
                formFilters: that.formFilters,
                listActionButton: that.listActionButton,
                cid: this.cid,
                qvdObj: this.qvdObj,
                pagination: false,
                viewMode: this.viewMode,
            }
        );
        
        $(that.listBlockContainer).html(template);

        that.renderList();
                
        // Translate the strings rendered. 
        // This translation is only done here, in the first charge. 
        // When the list were rendered in actions such as sorting, filtering or pagination, 
        // the strings will be individually translated
        
        Up.T.translate();
        Up.I.enableDataPickers();
    },    
    
    // Render only the list. Usefull to functions such as pagination, sorting and filtering where is not necessary render controls
    renderList: function () {
        // Fill the list
        var template = _.template(
            Up.TPL['list-' + this.viewMode + '_' + this.qvdObj], {
                models: this.collection.models,
                checkBox: false
            }
        );
        
        $(this.listContainer).html(template);
        this.paginationUpdate();
        this.shownElementsLabelUpdate();
        
        Up.I.updateSelectedItems(this.selectedItems.length);
        
        // Open websockets for live fields
        if (this.liveFields) {
            Up.WS.openListWebsockets(this.qvdObj, this.collection, this.liveFields, this.cid);
        }
        
        Up.T.translateAndShow();
                
        Up.I.addSortIcons(this.cid);
                
        Up.I.addOddEvenRowClass(this.listContainer);
    },
    
    shownElementsLabelUpdate: function () {
        var context = $('.' + this.cid);

        var elementsShown = this.collection.length;
        var elementsTotal = this.collection.length;

        context.find(' .shown-elements .elements-shown').html(elementsShown);
        context.find(' .shown-elements .elements-total').html(elementsTotal);
    },
    
    paginationUpdate: function () {  
        this.elementsShown = this.collection.length;
        var totalPages = Math.ceil(this.collection.elementsTotal/this.collection.block);
        var currentPage = this.collection.offset;

        var context = $('.' + this.cid);

        context.find('.pagination_current_page>input.js-current-page').val(currentPage || 1);
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
        // If pressed button is disabled do nothing
        if (context.hasClass('disabled')) {
            return;
        }
        
        // Show loading animation while loading
        $('.' + this.cid).find('.list').html(HTML_MID_LOADING);
        
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
    
    // When press key on pagination text input
    pressPage: function (e) {
        var inputContent = parseInt($(e.target).val());
        var totalPages = parseInt($('.pagination_total_pages').html());
        
        // Control overflow
        if (inputContent > totalPages) {
            inputContent = totalPages;
        }
        else if (inputContent <= 1) {
            inputContent = 1;
        }
        
        // When press enter
        if (e.keyCode == 13) {
            if (inputContent && this.collection.offset != inputContent) {
                // Show loading animation while loading
                $('.' + this.cid).find('.list').html(HTML_MID_LOADING);
                
                this.collection.offset = inputContent;
                this.fetchList();
            }
        
            $(e.target).val(this.collection.offset);
        }
    },
    
    // Change view mode when click on the view mode button and render list
    changeViewMode: function (e) {
        this.viewMode = $(e.target).attr('data-viewmode');
        $('.js-change-viewmode').removeClass('disabled');
        $(e.target).addClass('disabled');
        this.renderList();
    },
});
