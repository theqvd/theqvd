var ListView = MainView.extend({
    sortedBy: '',
    sortedMode: '',
    selectedActions: {},
    formFilters: {},
    columns: [],
    elementsShown: '',
    elementsBlock: 10,
    elementsOffset: 1,
    listContainer: '.bb-list',
    listBlockContainer: '.bb-list-block',
    whatRender: 'all',
    listFilter: {},

    /*
    ** params:
    **  whatRender (string): What part of view render (all/list). Default 'all'
    **  listContainer (string): Selector of list container. Default '.bb-list'
    **  forceListColumns (object): List of columns that will be shown on list ignoring configuration. Format {checks: true, id: true, ...}
    **  forceListSelectedActions (object): List of actions to be performed over selected items that will be able ignoring configuration. Format {delete: true, block: true, ...}
    **  forceListActionButton (object): Override list action button with other button or with null value to not show it. Format {name: 'name of the button', value: 'text into button', link: 'href value'}
    **  listFilter (object): Conditions under the list will be filtered. Format {user: 23, ...}
    */
    
    initialize: function (params) {
        MainView.prototype.initialize.apply(this);

        this.templateListCommonList = this.getTemplate('list-common');
        this.templateListCommonBlock = this.getTemplate('list-common-block');
        this.listTemplate = this.getTemplate(this.listTemplateName);
                
        this.readParams(params);
        
        this.render();
    },
    
    readParams: function (params) {
        if (params !== undefined) {
            if (params.autoRender !== undefined) {
                this.autoRender = params.autoRender;
            }            
            if (params.whatRender !== undefined) {
                this.whatRender = params.whatRender;
            }            
            if (params.listContainer !== undefined) {
                this.listBlockContainer = params.listContainer;
            }                
            if (params.listFilter !== undefined) {
                this.listFilter = params.listFilter;
            }            
            if (params.forceListActionButton !== undefined) {
                this.listActionButton = params.forceListActionButton;
            }            
            if (params.elementsBlock !== undefined) {
                this.elementsBlock = params.elementsBlock;
            }
            if (params.forceListColumns !== undefined) {
                var that = this;
                $(this.columns).each(function(index, column) {
                    if (params.forceListColumns[column.name] !== undefined && params.forceListColumns[column.name]) {
                        that.columns[index].display = true;
                    }
                    else {
                        that.columns[index].display = false;
                    }
                });
            }
            if (params.forceSelectedActions !== undefined) {
                var that = this;
                $(this.selectedActions).each(function(index, action) {
                    if (params.forceSelectedActions[action.value] === undefined) {
                        delete that.selectedActions[index];
                    }
                });
            }
        }
    },
    
    events: {
        'click th.sortable': 'sort',
        'click input[class="check_all"]': 'checkAll',
        'click .first': 'paginationFirst',
        'click .prev': 'paginationPrev',
        'click .next': 'paginationNext',
        'click .last': 'paginationLast',
        'click a[name="filter_button"]': 'filter'
    },

    sort: function (e) {
        if ($.isEmptyObject(this.cache.stringsCache)) {
            this.activeCache(this.cache);
        }
        
        // Find the TH cell, because sometimes you can click on the icon
        if ($(e.target).get(0).tagName == 'TH') {
            var sortCell = $(e.target).get(0);    
        }
        else {
            // If click on the icon, we get the parent
            var sortCell = $(e.target).parent().get(0);    
        }
        
        var sortedBy = $(sortCell).attr('data-sortby');
        
        if (sortedBy !== this.sortedBy || this.sortedMode == 'DESC') {
            this.sortedMode = 'ASC';
            this.collection.url = this.sortedAscUrl;
        }
        else {
            this.sortedMode = 'DESC';
            this.collection.url = this.sortedDescUrl;
        }

        this.sortedBy = sortedBy;
        
        var that = this;
        this.collection.fetch({      
            complete: function () {
                that.renderList(that.listContainer);
                addSortIcons(that);
            }
        });
    },
    
    filter: function () {
        if ($.isEmptyObject(this.cache.stringsCache)) {
            this.activeCache(this.cache);
        }
        
        var filtersContainer = '.' + this.cid + ' .filter';
        var filters = {};
        $.each(this.formFilters, function(index, filter) {
            var filterControl = $(filtersContainer + ' [name="' + filter.name + '"]');
            
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
        var that = this;
        this.collection.fetch({      
            complete: function () {
                that.renderList(that.listContainer);
                addSortIcons(that);
            }
        });
    },

    checkAll: function (e) {
        if ($(e.target).is(":checked")) {
            $('.js-check-it').prop("checked", true);
        } else {
            $('.js-check-it').prop("checked", false);
        }
    },

    render: function () {
        var that = this;
        this.collection.fetch({      
            complete: function () {
                switch(that.whatRender) {
                    case 'all':
                        that.renderCommon();
                        break;
                    case 'list':
                        that.renderListBlock();
                        break;
                }
            }
        });
    },
    
    renderCommon: function () {
        // Fill the html with the template and the collection
        var template = _.template(
            this.templateListCommonList, {
                formFilters: this.formFilters,
                cid: this.cid
            });
        
        $(this.el).html(template);
                
        this.loadFilters();
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        this.renderListBlock();
    },
    
    renderListBlock: function () { 
        // Fill the list
        var template = _.template(
            this.templateListCommonBlock, {
                formFilters: this.formFilters,
                selectedActions: this.selectedActions,
                listActionButton: this.listActionButton,
                cid: this.cid
            }
        );

        $(this.listBlockContainer).html(template);
        
        this.paginationUpdate();
        
        this.renderList();
                this.translate();

    },    
    
    renderList: function () {        
        // Fill the list
        var template = _.template(
            this.listTemplate, {
                models: this.collection.models,
                getCached: this.cache.getCached,
                cache: this.cache.stringsCache,
                columns: this.columns
            }
        );

        $(this.listContainer).html(template);
        this.paginationUpdate();
        
    },
    
    loadFilters: function () {
        var that = this;
        $.each(this.formFilters, function(index, filter) {
            if (filter.type == 'select' && filter.fillable) {
                var jsonUrl = 'http://172.20.126.12:3000/?login=benja&password=benja&action=' + filter.name + '_tiny_list';
                $.ajax({
                    url: jsonUrl,
                    type: 'POST',
                    async: false,
                    dataType: 'json',
                    processData: false,
                    parse: true,
                    success: function (data) {
                        $(data.result.rows).each(function(i,option) {
                            var selected = '';
                            if (that.listFilter[filter.name] !== undefined && that.listFilter[filter.name] == option.id) {
                                selected = 'selected="selected"';
                            }
                            $('select[name="' + filter.name + '"]').append('<option value="' + option.id + '" ' + selected + '>' + 
                                                                           option.name + 
                                                                           '<\/option>');
                        });
                    }
                });
            }
        });
    },
    
    paginationUpdate: function () {        
        this.elementsShown = this.collection.length;
        var totalPages = Math.ceil(this.collection.elementsTotal/this.elementsBlock);
        var currentPage = this.elementsOffset;
        
        $('.pagination_current_page').html(currentPage);
        $('.pagination_total_pages').html(totalPages);
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
    
    paginationMove: function (context, dir) {
        if ($.isEmptyObject(this.cache.stringsCache)) {
            this.activeCache(this.cache);
        }
        
        var totalPages = Math.ceil(this.collection.elementsTotal/this.elementsBlock);
        var currentPage = this.elementsOffset;
        
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
                this.elementsOffset = 1;
                break;
            case 'prev':
                this.elementsOffset--;
                break;
            case 'next':
                this.elementsOffset++;
                break;
            case 'last':
                this.elementsOffset = totalPages;
                break;
        }

        context.find('.pagination_current_page').html(this.elementsOffset);
        
        this.collection.offset = this.elementsOffset;
        
        var that = this;
        this.collection.fetch({      
            complete: function () {
                that.renderList(that.listContainer);
                addSortIcons(that);
            }
        });
    }
});
