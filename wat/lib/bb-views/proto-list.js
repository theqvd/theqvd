var ListView = MainView.extend({
    sortedBy: '',
    sortedMode: '',
    selectedActions: {},
    filters: {},
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
        'click input[class="check_all"]': 'checkAll'
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
                filters: this.filters
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
                filters: this.filters,
                selectedActions: this.selectedActions,
                listActionButton: this.listActionButton
            }
        );

        $(this.listBlockContainer).html(template);
        
        this.updatePagination();
        
        this.renderList();
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
        this.updatePagination();
    },
    
    loadFilters: function () {
        var that = this;
        $.each(this.filters, function(index, filter) {
            if (filter.type == 'select' && filter.fillable) {
                var jsonUrl = 'json/tiny_list_' + filter.name + 's.json';

                $.ajax({
                    url: jsonUrl,
                    method: 'GET',
                    async: false,
                    contentType: 'json',
                    success: function (data) {
                        $(data).each(function(i,option) {
                            var selected = '';
                            if (that.listFilter[filter.name] !== undefined && that.listFilter[filter.name] == option.id) {
                                selected = 'selected="selected"';
                            }
                            $('select[name="' + filter.name + '"]').append('<option value="' + option.id + '" ' + selected + '>' + option.name + '<\/option>');
                        });
                    }
                });
            }
        });
    },
    
    updatePagination: function () {
        this.elementsShown = this.collection.length;
        var totalPages = Math.ceil(this.collection.elementsTotal/this.elementsBlock);
        var currentPage = this.elementsOffset;
        
        $('.pagination_current_page').html(currentPage);
        $('.pagination_total_pages').html(totalPages);
    }
});
