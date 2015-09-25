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
    customCollection: false,
    infoRestrictions: false,
    initFilters: {},
    
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
        
        this.setFilters();
        this.setColumns();
        this.setSelectedActions();
        this.setListActionButton();
        this.setBreadCrumbs();
                
        this.resetSelectedItems();
        
        this.context = $('.' + this.cid);
        
        this.readParams(params);
    
        // Extend the common events with the list events and events of the specific view
        this.extendEvents(this.commonListEvents);
        this.extendEvents(this.listEvents);
        this.addListTemplates();
        
        Wat.A.getTemplates(this.templates, this.render); 
    },
    
    addListTemplates: function () {
        var templates = Wat.I.T.getTemplateList('list', {qvdObj: this.qvdObj});
        
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
        'change .filter-control select': 'filter',
        'input .filter-control input.date-filter': 'filter',
        'click .js-button-new': 'openNewElementDialog',
        'click [name="selected_actions_button"]': 'applySelectedAction'
    },
    
    // Render list sorted by a column
    sort: function (e) { 
        // Show loading animation while loading
        this.loadingList();
        
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

        this.showSortingMessage(sortCell, this.sortedOrder);
          
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
    
    // Remove all rows and show one message while new sorting is loading
    showSortingMessage: function (sortCell, sortedOrder) {
        var sortedFieldName = $(sortCell).find('span').html();
        var theader = $(sortCell).parent().parent();
        var nColumns = theader.find('th').length;
        var tbody = theader.parent().find('tbody');
        var rows = tbody.find('tr');
        // Order icon will be sort-alpha-asc or sort-alpha-desc from awesome webfont
        var orderClass = 'fa fa-sort-alpha' + sortedOrder;

        rows.remove();
        
        // Add common parts of editor to dialog
        var template = _.template(
                    Wat.TPL.sortingRow, {
                        nColumns: nColumns,
                        orderClass: orderClass,
                        sortedFieldName: sortedFieldName
                    }
                );

        tbody.append(template);
        
        // Remove sortable class form header cells to avoid stack of sort petitions
        theader.find('th').removeClass('sortable');
    },
    
    // Hide elements related with a list. Used while list data is loading
    loadingList: function () {
        $('div.js-shown-elements, div.js-selected-elements, fieldset.js-action-selected').hide();
    },
    
    // Show elements related with a list. Used after load list data
    loadedList: function () {
        $('div.js-shown-elements, div.js-selected-elements, fieldset.js-action-selected').show();
    },
    
    // Get filter parameters of the form, set in collection, fetch list and render it
    filter: function (e) {
        var that = this;
        
        // Show loading animation while loading
        that.loadingList();
        $('.list').html(HTML_MID_LOADING);

        if (e && $(e.target).hasClass('mobile-filter')) {
            var filtersContainer = '.' + this.cid + ' .filter-mobile';
        }
        else {
            var filtersContainer = '.' + this.cid + ' .filter';
        }
        
        // Solve dependences in case of fussioned filters
        if (e) {
            Wat.A.solveFilterDependences($(e.target).attr('name'), $(e.target).attr('data-filter-field'));
        }
        
        var filters = {};
        $.each(this.formFilters, function(name, filter) {
            var filterControl = $(filtersContainer + ' [name="' + name + '"]');
            
            // If current field exist in initFilters, delete it to avoid use it when "All" option is selected
            if (that.initFilters && that.initFilters[filterControl.attr('data-filter-field')]) {
                delete that.initFilters[filterControl.attr('data-filter-field')];
            }
            
            // If input text box is empty or selected option in a select is All (-1) skip filter control
            switch(filter.type) {
                case 'select':
                    if (filterControl.val() == '-1' || filterControl.val() == undefined) {
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
                                    "<": Wat.U.getRelativeDate(filterControl.val() * -1)
                                };
                                break;
                            case 'dateGreatThanPast':
                                filters[filterControl.attr('data-filter-field')] = {
                                    ">": Wat.U.getRelativeDate(filterControl.val() * -1)
                                };
                                break;
                            case 'dateLessThanFuture':
                                filters[filterControl.attr('data-filter-field')] = {
                                    "<": Wat.U.getRelativeDate(filterControl.val())
                                };
                                break;
                            case 'dateGreatThanFuture':
                                filters[filterControl.attr('data-filter-field')] = {
                                    ">": Wat.U.getRelativeDate(filterControl.val())
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
        
        var searchHash = Wat.U.transformFiltersToSearchHash(filters);
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
        delete Wat.CurrentView.filters[fKey];
        delete Wat.CurrentView.initFilters[fKey];
        Wat.CurrentView.collection.deleteFilter(fKey);
    },
    
    updateFilterNotes: function () {     
        var that = this;
        
        // Show-Hide filter notes only when view is not embeded
        if (this.cid == Wat.CurrentView.cid) {
            var filtersContainer = '.' + this.cid + ' .filter';
            
            var filterNotes = {};
            if ($.isEmptyObject(filterNotes) && !$.isEmptyObject(this.initFilters)) {
                $.each(this.initFilters, function (filterField, filterValue) {                    
                    switch (filterField) {
                        case 'di_id':
                            filterNotes['di_id'] = {
                                'label': $.i18n.t('Disk image'),
                                'type': 'filter'
                            };
                            break;
                        case 'host_id':
                            filterNotes['host_id'] = {
                                'label': $.i18n.t('Node'),
                                'type': 'filter'
                            };
                            break;
                        case 'osf_id':
                            filterNotes['osf_id'] = {
                                'label': $.i18n.t('OS Flavour'),
                                'type': 'filter'
                            };
                            break;
                        case 'user_id':
                            filterNotes['user_id'] = {
                                'label': $.i18n.t('User'),
                                'type': 'filter'
                            };
                            break;
                        case 'object_id':
                            var filterLabel = $.i18n.t(LOG_TYPE_OBJECTS[that.initFilters['qvd_object']]);
                            
                            filterNotes['object_id'] = {
                                'label': filterLabel,
                                'type': 'filter',
                                'value': filterValue
                            };
                            break;
                    }
                    
                    // If the filtered field has not filter control, show generic filter note
                    if (filterNotes[filterField] && $('.filter [data-filter-field="' + filterField + '"]').length > 0) {
                        if ($('.filter [data-filter-field="' + filterField + '"] option[value="' + filterValue + '"]').val() == undefined) {
                            filterNotes[filterField].value = '<i class="fa fa-spin fa-gear"></i>';
                        }
                        else {
                            delete filterNotes[filterField];
                        }
                    }
                });
            }

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
            
            this.drawFilterNotes(filterNotes);
        }
    },
    
    drawFilterNotes: function(filterNotes) {
        if ($.isEmptyObject(filterNotes)) {
            $('.js-filter-notes').hide();
        }
        else {
            $('.filter-notes-list li').remove();
            
            // Perform fussion notes
            $.each (FUSSION_NOTES, function (fKey, obj) {
                if (filterNotes[obj.label] != undefined && filterNotes[obj.value] != undefined) {
                    filterNotes[fKey] = {
                        label: filterNotes[obj.label].value,
                        value: filterNotes[obj.value].value,
                        type: filterNotes[obj.value].type,
                        replaceValue: obj.replaceValue
                    };
                    
                    delete filterNotes[obj.label];
                    delete filterNotes[obj.value];
                }
            });
            
            $.each(filterNotes, function(fNoteName, fNote) {
                if (fNote.replaceValue) {
                    if (Wat.CurrentView.collection.length) {
                        fNote.value = Wat.CurrentView.collection.models[0].get(fNote.replaceValue);
                    }
                }
                var note = '<li><a href="javascript:" class="js-delete-filter-note delete-filter-note fa fa-times" data-filter-name="' + fNoteName + '" data-filter-type="' + fNote.type + '"></a>';
                note += '<span class="note-label">' + fNote.label + '</span>';
                if (fNote.value != undefined) {
                    note += ': <span class="note-value">' + fNote.value + '</span>';
                }
                
                note += '</li>';
                $('.js-filter-notes-list').append(note);
            });
            $('.js-filter-notes').show();
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
                            Wat.I.closeDialog($(this));
                            Wat.I.updateSelectedItems(that.selectedItems.length);
                        },
                        "Select all": function () {
                            $('.js-check-it').prop("checked", true);
                            that.dialog = $(this);
                            Wat.A.performAction(that.qvdObj + '_all_ids', {}, that.collection.filters, {}, that.storeAllSelectedIds, that);
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
        
        Wat.I.closeDialog(that.dialog);
        Wat.I.updateSelectedItems(that.selectedItems.length);
        that.selectedAll = true;
    },
    
    fillCheckSelector: function (target) {
        var that = Wat.CurrentView;
        
        // Add common parts of editor to dialog
        that.template = _.template(
                    Wat.TPL.selectChecks, {
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
        
        // Add tenant column to any element where it has sense
        var classifiedByTenant = $.inArray(this.qvdObj, QVD_OBJS_CLASSIFIED_BY_TENANT) != -1;
        if (Wat.C.isSuperadmin() && classifiedByTenant) {
            this.columns.tenant = {
                'text': 'Tenant',
                'displayDesktop': true,
                'displayMobile': false,
                'noTranslatable': true,
                'sortable': true
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
                // If typed search is defined, check if typedSearch matchs with currentSearch. If not, do nothing
                if (that.typedSearch) {
                    var currentSearch = $(that.filtersContainer).find('.filter-control>input[type="text"]').val();
                    
                    if (that.typedSearch != currentSearch) {
                        return;
                    }
                }

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
        
        var embeddedView = that.cid != Wat.CurrentView.cid;
        
        // If user have not access to main section, redirect to home
        if (!embeddedView && that.whatRender && !Wat.C.checkACL(that.qvdObj + '.see-main.')) {
            Wat.Router.watRouter.trigger('route:defaultRoute');
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
            Wat.TPL.listCommonList, {
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
            Wat.TPL.listCommonBlock, {
                formFilters: that.formFilters,
                selectedActions: that.selectedActions,
                listActionButton: that.listActionButton,
                cid: this.cid
            }
        );
        
        $(that.listBlockContainer).html(template);
                        
        // Only fetch filters if view is not embeded
        if (Wat.CurrentView.cid == this.cid) {
            this.fetchFilters();
        }

        that.renderList();
                
        // Translate the strings rendered. 
        // This translation is only done here, in the first charge. 
        // When the list were rendered in actions such as sorting, filtering or pagination, 
        // the strings will be individually translated
        
        Wat.T.translate();
        Wat.I.enableDataPickers();
    },    
    
    // Render only the list. Usefull to functions such as pagination, sorting and filtering where is not necessary render controls
    renderList: function () {
        // Fill the list
        var template = _.template(
            Wat.TPL['list_' + this.qvdObj], {
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
            Wat.WS.openListWebsockets(this.qvdObj, this.collection, this.liveFields, this.cid);
        }
        
        Wat.T.translateAndShow();
        
        this.updateFilterNotes();
        
        Wat.I.addSortIcons(this.cid);
        
        // Show hidded controls again after list loading
        this.loadedList();
        
        Wat.I.adaptSideSize();
        
        Wat.I.addOddEvenRowClass(this.listContainer);
        
        this.fillAdminSelect();
    },
    
    fillAdminSelect: function () {
        // If exist admin select and is not filled yet, fill it
        if ($('select[name="admin"]').length > 0 && $('select[name="admin"] option').length < 2) {
            if (Wat.C.isSuperadmin()) {
                // If tenant select is defined, we wait to be loaded to load administrators select
                Wat.A.performAction ('tenant_tiny_list', {}, {}, {}, function(e) {

                    var fillTenantAdmins = function (tenants) {
                        if (tenants.length > 0) {
                            var tenant = tenants.shift();

                            var params = {
                                'action': 'admin_tiny_list',
                                'selectedId': '',
                                'controlName': 'admin',
                                'filters': {
                                    "tenant_id": tenant.id
                                },
                                'order_by': {
                                    "field": ["name"],
                                    "order": "-asc"
                                },
                                'group': tenant.name,
                                'chosenType': 'advanced100'
                            };

                            Wat.A.fillSelect(params, function () {
                                fillTenantAdmins(tenants);
                            });
                        }
                    };

                    fillTenantAdmins(e.retrievedData.rows);
                }, this);

            }
            else {
                // If administrator is not superadmin, administrators combo will be charged normally
                var params = {
                    'action': 'admin_tiny_list',
                    'selectedId': '',
                    'controlName': 'admin',
                    'order_by': {
                        "field": ["name"],
                        "order": "-asc"
                    },
                    'chosenType': 'advanced100'
                };

                Wat.A.fillSelect(params, function () {
                });
            }
        }
    },
    
    // Fill filter selects 
    fetchFilters: function () {
        var that = this;
                
        var existsInSupertenant = $.inArray(that.qvdObj, QVD_OBJS_EXIST_IN_SUPERTENANT) != -1;
        
        $.each(this.formFilters, function(name, filter) {
            if (filter.fillable) {
                if (filter.type == 'select') {
                    var fillAction = name + '_tiny_list';
                    if (filter.fillAction) {
                        fillAction = filter.fillAction;
                    }
                    
                    var nameAsId = false;
                    if (filter.nameAsId) {
                        nameAsId = filter.nameAsId;
                    }
                    
                    var params = {
                        'action': fillAction,
                        'selectedId': that.filters[filter.filterField] || Wat.I.getFilterSelectedId(filter.options),
                        'controlName': name,
                        'startingOptions': Wat.I.getFilterStartingOptions(filter.options),
                        'nameAsId': nameAsId
                    };

                    Wat.A.fillSelect(params, function () {
                        // In tenant case (except in admins list) has not sense show supertenant in filters
                        if (!existsInSupertenant && name == 'tenant') {
                            // Remove supertenant from tenant selector
                            $('select[name="tenant"] option[value="0"]').remove();
                        }
                                                
                        Wat.I.updateChosenControls('[name="' + name + '"]');
                        
                        if (that.filters[filter.filterField] != undefined) {      
                            that.updateFilterNotes();
                        }
                    });
                }
            }
            else {
                // If any field setted as not fillable is filtered, update it on control
                if (that.filters[filter.filterField] != undefined) {      
                    $('.filter-control').find('[name="' + name + '"] option[value="' + that.filters[filter.filterField] + '"]').prop('selected', true);
                    $('.filter-control').find('[name="' + name + '"]').trigger('chosen:updated');
                    
                    that.updateFilterNotes();
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
    
    openMassiveChangesDialog: function (that) {  
        // If the edition is performed over one single element, call single editor
        if (that.selectedItems.length == 1) {
            that.editingFromList = true;
            this.openEditElementDialog(that);
            return;
        }
        
        that.templateEditor = Wat.TPL.editorMassive;
        
        that.dialogConf.buttons = {
            Cancel: function () {
                Wat.I.closeDialog($(this));
            },
            Update: function () {
                that.dialog = $(this);
                that.updateMassiveElement($(this), that.selectedItems);
            }
        };
        
        that.dialogConf.button1Class = 'fa fa-ban';
        that.dialogConf.button2Class = 'fa fa-save';
        
        that.dialogConf.fillCallback = that.fillMassiveEditor;
        that.dialogConf.title = i18n.t('Massive changes over __counter__ elements', {counter: that.selectedItems.length}) + '<i class="fa fa-warning" title="' + i18n.t('Some fields could not be able in the massive editor') + '"></i>';

        that.editorElement();
    },
    
    fillMassiveEditor: function (target) {
        var that = Wat.CurrentView;
        
        // Add common parts of editor to dialog
        that.template = _.template(
                    Wat.TPL.editorCommon, {
                        classifiedByTenant: 0,
                        editorMode: 'massive_edit',
                        isSuperadmin: Wat.C.isSuperadmin(),
                        blocked: undefined,
                        properties: [],
                        cid: that.cid
                    }
                );
        
        target.html(that.template);

        // Add specific parts of editor to dialog
        that.template = _.template(
                    Wat.TPL.editorMassive, {
                        model: that.model
                    }
                );

        $(that.editorContainer).html(that.template);
        
        var enabledProperties = $.inArray(that.qvdObj, QVD_OBJS_WITH_PROPERTIES) != -1;
        var enabledEditProperties = Wat.C.checkACL(that.qvdObj + '.update-massive.properties');
        
        if (enabledProperties && enabledEditProperties) {
            var filters = {};
            
            // In massive edition for superadmins, only is available the specific properties for superadmins
            if (Wat.C.isSuperadmin()) {
                filters['tenant_id'] = SUPERTENANT_ID;
            }

            that.model = new that.collection.model(); 
            
            if (that.selectedItems.length > 1) {
                that.model = that.collection.where({id: that.selectedItems[0]})[0];
            }

            that.editorMode = 'massive-edit';
                
            Wat.A.performAction(that.qvdObj + '_get_property_list', {}, filters, {}, that.fillEditorProperties, that, undefined, {"field":"key","order":"-asc"});
        }
        
        that.configureMassiveEditor (that);
    },
    
    applySelectedAction: function () { 
        var action = $('select[name="selected_actions_select"]').val();

        if (!this.selectedItems.length) {
            Wat.I.M.showMessage({message: 'No items were selected - Nothing to do', messageType: 'info'});
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
        
        var loadingBlock = false;
        if (this.selectedItems.length > 100) {
            loadingBlock = true;
            if (!elementsOutOfView) {
                Wat.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
            }
        }
        
        var that = this;
        switch(action) {
            case 'delete':
                Wat.I.confirm('dialog/confirm-undone', that.applyDelete, that, loadingBlock);
                break;
            case 'block':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog/confirm-out-of-view', that.applyBlock, that, loadingBlock);
                }
                else {
                    that.applyBlock(that);
                }
                break;
            case 'unblock':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog/confirm-out-of-view', that.applyUnblock, that, loadingBlock);
                }
                else {
                    that.applyUnblock(that);
                }
                break;
            case 'massive_changes':
                // The function that will open the Massive changes dialog is: openMassiveChangesDialog
                // Each qvd object have the option of do things before with setupMassiveChangesDialog and after with configureMassiveEditor                
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog/confirm-out-of-view', that.setupMassiveChangesDialog, that, loadingBlock);
                }
                else {
                    that.setupMassiveChangesDialog(that);
                }
                break;
            // Used in VMs
            case 'start':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog/confirm-out-of-view', that.applyStart, that, loadingBlock);
                }
                else {
                    that.applyStart(that);
                }
                break;
            case 'stop':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog/confirm-out-of-view', that.applyStop, that, loadingBlock);
                }
                else {
                    that.applyStop(that);
                }
                break;
            case 'disconnect':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog/confirm-out-of-view', that.applyDisconnect, that, loadingBlock);
                }
                else {
                    that.applyDisconnect(that);
                }
                break;
            // Used in Hosts
            case 'stop_all':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog/confirm-out-of-view', that.applyStopAll, that, loadingBlock);
                }
                else {
                    that.applyStopAll(that);
                }
                break;
            // Used in Users
            case 'disconnect_all':
                if (elementsOutOfView) {
                    Wat.I.confirm('dialog/confirm-out-of-view', that.applyDisconnectAll, that, loadingBlock);
                }
                else {
                    that.applyDisconnectAll(that);
                }
                break;
            case 'delete_acl':
                Wat.I.confirm('dialog/confirm-undone', that.applyDeleteACL, that, loadingBlock);
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
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL(this.qvdObj + '.update-massive.properties')) {
            arguments['__properties_changes__'] = properties;
        }
        
        var context = $('.' + this.cid + '.editor-container');

        var description = context.find('textarea[name="description"]').val();
        
        if (description != '' && Wat.C.checkACL(this.qvdObj + '.update-massive.description')) {
            arguments["description"] = description;
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
            case 'administrator':
                auxModel = new Wat.Models.Admin();
                break;
            case 'role':
                auxModel = new Wat.Models.Role();
                break;
            case 'tenant':
                auxModel = new Wat.Models.Tenant();
                break;
        }
        
        this.updateModel(arguments, filters, this.fetchList, auxModel);
    },
});
