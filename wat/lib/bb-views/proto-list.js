Wat.Views.ListView = Wat.Views.MainView.extend({
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

        this.templateListCommonList = Wat.A.getTemplate('list-common');
        this.templateListCommonBlock = Wat.A.getTemplate('list-common-block');
        this.listTemplate = Wat.A.getTemplate(this.listTemplateName);
        
        this.readParams(params);
        
        this.render();
        
        // Extend the common events
        this.extendEvents(this.eventsList);
    },
    
    readParams: function (params) {
        if(params === undefined) {
            params = {};
        }
        
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
            var selectedActions = [];
            $(this.selectedActions).each(function(index, action) {
                if (params.forceSelectedActions[action.value] !== undefined) {
                    selectedActions.push(action);
                }
            });

            this.selectedActions = selectedActions;
        }
    },
    
    eventsList: {
        'click th.sortable': 'sort',
        'click input[class="check_all"]': 'checkAll',
        'click .first': 'paginationFirst',
        'click .prev': 'paginationPrev',
        'click .next': 'paginationNext',
        'click .last': 'paginationLast',
        'click a[name="filter_button"]': 'filter',
        'keyup .filter-control input': 'filter',
        'input .filter-control input': 'filter',
        'change .filter-control select': 'filter',
        'click .js-button-new': 'newElement'
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
        if (this.offset != 1) {
            $('.' + this.cid + ' .pagination .first').trigger('click');
        }
        else {   
            this.fetchList();
        }
    },
    
    // Get filter parameters of the form, set in collection, fetch list and render it
    filter: function () {
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

        // When we came from a view without elements pagination doesnt exist
        var existsPagination = $('.' + this.cid + ' .pagination .first').length > 0;
        
        // If the current offset is not the first page, trigger click on first button of pagination to go to the first page. 
        // This button render the list so is not necessary render in this case
        if (this.offset != 1 && existsPagination) {
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
    
    // Fetch collection and render list
    fetchList: function () {
        var that = this;
        this.collection.fetch({      
            complete: function () {
                that.renderList(that.listContainer);
                Wat.I.addSortIcons(that);

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
                
        this.fetchFilters();
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        this.renderListBlock();
    },
    
    //Render list with controls (list block)
    renderListBlock: function () {
        // Fill the list
        var template = _.template(
            this.templateListCommonBlock, {
                formFilters: this.formFilters,
                selectedActions: this.selectedActions,
                listActionButton: this.listActionButton,
                nElements: this.collection.length,
                cid: this.cid
            }
        );

        $(this.listBlockContainer).html(template);
                
        this.renderList();
        
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
        this.selectedActionControlsUpdate();
    },
    
    // Fill filter selects 
    fetchFilters: function () {
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
                            if (that.filters[filter.filterField] !== undefined && that.filters[filter.filterField] == option.id) {
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

        $('.pagination_current_page').html(currentPage || 1);
        $('.pagination_total_pages').html(totalPages || 1);
        
        if (totalPages <= 1) {
            $('.pagination a').addClass('disabled');
        }
        else {
            $('.pagination a').removeClass('disabled');
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

        context.find('.pagination_current_page').html(this.collection.offset);
                
        this.fetchList();
    },
    
    newElement: function (e) {
        var that = this;
        
        this.dialogConf.buttons = {
            Cancel: function () {
                $(this).dialog('close');
            },
            Create: function () {
                that.createElement($(this));
                that.showMessage();
            }
        };
        
        this.dialogConf.button1Class = 'fa fa-ban';
        this.dialogConf.button2Class = 'fa fa-plus-circle';
        
        
        this.editorElement(e);
    }
});
