Up.Views.ListView = Up.Views.MainView.extend({
    collection: {},
    sortedBy: '',
    sortedOrder: '',
    formFilters: {},
    columns: [],
    listContainer: '.bb-list',
    filters: {},
    selectedItems: [],
    selectedAll: false,
    customCollection: false,
    infoRestrictions: false,
    initFilters: {},
    
    viewKind: 'list',
    
    /*
    ** params:
    **  listContainer (string): Selector of list container. Default '.bb-list'
    **  filters (object): Conditions under the list will be filtered. Format {user: 23, ...}
    */
    
    initialize: function (params) {   
		// If there are fixed filters, add them to collection
        if (!$.isEmptyObject(Up.I.fixedFilters)) {
            params.filters = $.extend({}, params.filters, Up.I.fixedFilters);
            this.collection.filters = $.extend({}, this.collection.filters, Up.I.fixedFilters);
        }
        
        // Bind events for this section that cannot be binded using backbone (dialogs, etc.)
        Up.B.bindListEvents();
        
        Up.Views.MainView.prototype.initialize.apply(this, [params]);
                
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
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    readParams: function (params) {
        params = params || {};
        
        this.filters = params.filters || {};
        this.initFilters = $.extend({}, this.filters);
        
        this.block = params.block || this.block;
        this.offset = params.offset || {};
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
        'keypress .pagination input.js-current-page': 'pressPage'
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
        
        this.collection.fetch({      
            success: function () {
                that.renderListBlock();
            }
        });
    },
    
    //Render list with controls (list block)
    renderListBlock: function (that) {
        // Fill the list
        var template = _.template(
            Up.TPL[this.qvdObj + 'CommonBlock'], {
                formFilters: this.formFilters,
                listActionButton: this.listActionButton,
                cid: this.cid,
                qvdObj: this.qvdObj,
                pagination: false,
            }
        );
        
        $(this.el).html(template);
                
        // Translate the strings rendered. 
        // This translation is only done here, in the first charge. 
        // When the list were rendered in actions such as sorting, filtering or pagination, 
        // the strings will be individually translated
        
        Up.T.translate();
        
        this.renderList();
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
});
