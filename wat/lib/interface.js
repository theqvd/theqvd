// Pure interface utilities
Wat.I = {
    cornerMenu : {},
    
    getCornerMenu: function () {
        return $.extend(true, [], this.cornerMenu);
    },
    
    listColumns: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {}
    },
    
    getListColumns: function (qvdObj) {
        return $.extend(true, {}, this.listColumns[qvdObj]);
    },
    
    // DEPRECATED
    getListColumnsByField: function (qvdObj) {
        var listColumns = this.getListColumns(qvdObj);
        
        // Get default values for custom columns
        var listColumnsByField = {};
        $.each(listColumns, function (columnName, column) {
            $.each(column.fields, function (iField, field) {
                listColumnsByField[field] = listColumnsByField[field] || {};
                listColumnsByField[field][columnName] = column.display;
            });
        });
        
        return listColumnsByField;
    },
    
    formFilters: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {}
    },
    
    getFormFilters: function (qvdObj) {
        return $.extend(true, {}, this.formFilters[qvdObj]);
    },
    
    // DEPRECATED
    getFormFiltersByField: function (qvdObj) {
        var formFilters = this.getFormFilters(qvdObj);
        
        // Get default values for custom filters
        var formFiltersByField = {desktop: {}, mobile: {}};
        $.each(formFilters, function (filterName, filter) {
            // For desktop
            formFiltersByField['desktop'][filter.filterField] = formFiltersByField['desktop'][filter.filterField] || {};
            formFiltersByField['desktop'][filter.filterField][filterName] = filter.displayDesktop;
            
            // For mobile
            formFiltersByField['mobile'][filter.filterField] = formFiltersByField['mobile'][filter.filterField] || {};
            formFiltersByField['mobile'][filter.filterField][filterName] = filter.displayMobile;
        });
        
        return formFiltersByField;
    },
    
    getCurrentCustomization: function (qvdObj) {
        var currentCustomization = {};

        var listColumns = this.getListColumns(qvdObj);
        
        // Get default values for custom columns
        var listColumnsByField = {};
        $.each(listColumns, function (fieldName, column) {
            $.each(column.fields, function (iField, field) {
                currentCustomization[field] = currentCustomization[field] || {};
                currentCustomization[field]['listColumns'] = currentCustomization[field]['listColumns'] || {};
                currentCustomization[field]['listColumns'][fieldName] = column.display;
            });
        });
        
        //return listColumnsByField;
        
        var formFilters = this.getFormFilters(qvdObj);
        
        // Get default values for custom filters
        var formFiltersByField = {desktop: {}, mobile: {}};
        $.each(formFilters, function (fieldName, filter) {
            var field = filter.filterField;
            // For desktop
            currentCustomization[field] = currentCustomization[field] || {};
            currentCustomization[field]['desktopFilters'] = currentCustomization[field]['desktopFilters'] || {};
            currentCustomization[field]['desktopFilters'][fieldName] = filter.displayDesktop; 
            
            // For mobile
            currentCustomization[field] = currentCustomization[field] || {};
            currentCustomization[field]['mobileFilters'] = currentCustomization[field]['mobileFilters'] || {};
            currentCustomization[field]['mobileFilters'][fieldName] = filter.displayMobile;
        });
        
        return currentCustomization;
    },
    
    setCustomizationFields: function (qvdObj) {
        var filters = {};

        // If qvd object is not specified, all will be setted
        if (qvdObj) {
            filters.qvd_obj = qvdObj;
        }
        
        Wat.A.performAction('config_field_get_list', {}, filters, {}, this.setCustomizationFieldsCallback, this, false);
    },
    
    setCustomizationFieldsCallback: function (that) {
        if (that.retrievedData.status === 0) {
            var fields = that.retrievedData.result.rows;

            $.each(fields, function (iField, field) {
                // If field options are not defined, we keep the default options doing nothing
                if (!field.filter_options) {
                    return;
                }
                
                var fieldName = field.name;               
                var qvdObj = field.qvd_obj;
                
                // Fix bad JSON format returned by API
                optionsJSON = field.filter_options.replace(/\\"/g,'"');
                optionsJSON = optionsJSON.replace(/^"/,'');
                optionsJSON = optionsJSON.replace(/"$/,'');
                
                var options = JSON.parse(optionsJSON);
                
                if (options.listColumns) {
                    $.each(options.listColumns, function (columnName, display) {
                        that.listColumns[qvdObj][columnName].display = display;
                    });
                }
                
                if (options.mobileFilters) {
                    $.each(options.mobileFilters, function (columnName, display) {
                        that.formFilters[qvdObj][columnName].displayMobile = display;
                    });
                }
                
                if (options.desktopFilters) {
                    $.each(options.desktopFilters, function (columnName, display) {
                        that.formFilters[qvdObj][columnName].displayDesktop = display;
                    });
                }
            });            
        }
    },
    
    selectedActions: {
        vm: [],
        user: [],
        host: [],
        osf: [],
        di: []
    },
    
    getSelectedActions: function (qvdObj) {
        return $.extend(true, [], this.selectedActions[qvdObj]);
    },
    
    listActionButton: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {}
    },
    
    getListActionButton: function (qvdObj) {
        return $.extend(true, [], this.listActionButton[qvdObj]);
    },
    
    // Breadcrumbs
    
    homeBreadCrumbs: {
        'screen': 'Home',
        'link': '#'
    },
    
    // List breadcrumbs
    listBreadCrumbs: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {}
    },   
        
    getListBreadCrumbs: function (qvdObj) {
        return this.listBreadCrumbs[qvdObj];
    },
    
    // List breadcrumbs
    detailsBreadCrumbs: {
        vm: {},
        user: {},
        host: {},
        osf: {},
        di: {}
    },   
        
    getDetailsBreadCrumbs: function (qvdObj) {
        return this.detailsBreadCrumbs[qvdObj];
    },
    
    showAll: function () {
        var firstLoad = $('.wrapper').css('visibility') == 'hidden';

        this.showContent();

        if (firstLoad) {
            $('.wrapper').css('visibility','visible').hide().fadeIn('fast');
            $('.menu').css('visibility','visible');
            $('.header-wrapper').css('visibility','visible').hide().fadeIn('fast');
            $('.content').css('visibility','visible').hide().fadeIn('fast');
            $('.breadcrumbs').css('visibility','visible').hide().fadeIn('fast');
            $('.menu-corner').css('visibility','visible');
        }
    },

    showContent: function () {
        // Set to the side box the same height of the content box
        $('.js-side').css('min-height', $('.content').height());

        $('.breadcrumbs').css('visibility','visible').hide().show();
        $('.content').css('visibility','visible').hide().show();
        $('.footer').css('visibility','visible').hide().show();
        $('.loading').hide();
    },

    showLoading: function () {
        var firstLoad = $('.wrapper').css('visibility') == 'hidden';

        if (!firstLoad) {
            $('.breadcrumbs').hide();
            $('.content').hide();
            $('.footer').hide();
            $('.loading').show();
        }
    },
    
    updateSortIcons: function (view) {
        // If not view is passed, use currentView
            if (view === undefined) {
                view = Wat.CurrentView;
            }
        
        // Get the context to the view
            var context = $('.' + view.cid);

        // Add sort icons to the table headers            
            var sortClassDefault = 'fa-sort';
            var sortClassAsc = 'fa-sort-asc';
            var sortClassDesc = 'fa-sort-desc';
                
            if (view.sortedBy != '') {
                switch(view.sortedOrder) {
                    case '': 
                        var sortClassSorted = '';
                        break;
                    case '-asc':            
                        var sortClassSorted = sortClassAsc;
                        break;
                    case '-desc':
                        var sortClassSorted = sortClassDesc;
                        break;
                }
            }

            context.find('th.sortable i').removeClass(sortClassDefault + ' ' + sortClassAsc + ' ' + sortClassDesc);
            context.find('th.sortable i').addClass(sortClassDefault);

            if (view.sortedBy != '') {
                context.find('[data-sortby="' + view.sortedBy + '"]').addClass('sorted');
                context.find('[data-sortby="' + view.sortedBy + '"] i').removeClass(sortClassDefault);
                context.find('[data-sortby="' + view.sortedBy + '"] i').addClass(sortClassSorted);
            }
    },
    
    enableDataPickers: function () {
        $('.datetimepicker').datetimepicker({
            dayOfWeekStart: 1,
            lang: 'en',
            format:'Y-m-d h:i'
        });
    },
    
    chosenConfiguration: function () {
        // Convert the filter selects to library chosen style
            var chosenOptions = {};
            chosenOptions.no_results_text = i18n.t('No results match');
            chosenOptions.placeholder_text_single = i18n.t('Select an option');
            chosenOptions.placeholder_text_multiple = i18n.t('Select some options');
            chosenOptions.search_contains = true;

            var chosenOptionsSingle = jQuery.extend({}, chosenOptions);
            chosenOptionsSingle.disable_search = true;
            chosenOptionsSingle.width = "150px";

            var chosenOptionsSingle100 = jQuery.extend({}, chosenOptionsSingle);
            chosenOptionsSingle100.width = "100%"; 

            var chosenOptionsAdvanced100 = jQuery.extend({}, chosenOptions);
            chosenOptionsAdvanced100.width = "100%";
        
            // Store options to be retrieved in dinamic loads
            this.chosenOptions = {
                'single': chosenOptionsSingle,
                'single100': chosenOptionsSingle100,
                'advanced100': chosenOptionsAdvanced100
            };

            $('.filter-control select.chosen-advanced').chosen(chosenOptionsAdvanced100);
            $('.filter-control select.chosen-single').chosen(chosenOptionsSingle100);
            $('select.chosen-single').chosen(chosenOptionsSingle);
    },
    
    chosenElement: function (selector, type) {
        $(selector).chosen(this.chosenOptions[type]);
    },
    
    updateChosenControls: function (selector) {
        var selector = selector || 'select.chosen-advanced, select.chosen-single';
        $(selector).trigger('chosen:updated');
    },
    
    mobileMenuConfiguration: function () {
        $('.js-mobile-menu').click(function () {
            $('.menu').slideToggle();
        });
        
        $('.menu .menu-option').click(function () {
            if ($('.js-mobile-menu').css('display') != 'none') {
                $('.menu').slideUp();
            }
        });
    },
    
    cornerMenuEvents: function () {
       // Show/hide the corner menu
       $('.js-menu-corner li:has(ul)').hover(
          function(e)
          {
             $(this).find('ul').css({display: "block"});
          },
          function(e)
          {
             $(this).find('ul').css({display: "none"});
          }
       );
    },
    
    // Set specific menu section as selected
    setMenuOpt: function (opt) {
        $('.menu-option').removeClass('menu-option--selected');
        $('.menu-option[data-target="' + opt + '"]').addClass('menu-option--selected');
    },
    
    renderMain: function () {
        var templateMain = Wat.A.getTemplate('main');
        // Fill the html with the template and the collection
        var template = _.template(
            templateMain, {
                loggedIn: Wat.C.loggedIn
            });
        
        $('.bb-super-wrapper').html(template);
    },
    
    tooltipConfiguration: function () {
        $( document ).tooltip({
            position: { 
                my: "left+15 center", 
                at: "right center" 
            },
            content: function(callback) {
                // Carriage return support
                callback($(this).prop('title').replace('\n', '<br />')); 
            }
        }
                             );
    },
    
    tagsInputConfiguration: function () {
        $('[name="tags"]').tagsInput({
            'defaultText': i18n.t('Add a tag')
        });
                
        
    },
    
    dialog: function (dialogConf) {
        $('.js-dialog-container').dialog({
            dialogClass: "loadingScreenWindow",
            title: dialogConf.title,
            resizable: false,
            dialogClass: 'no-close',
            collision: 'fit',
            modal: true,
            buttons: dialogConf.buttons,
            open: function(e) {                
                // Close message if open
                    $('.message-close').trigger('click');

                // Buttons style
                    var buttons = $(e.target).next().find('button');
                    var buttonsText = $(".ui-dialog-buttonset .ui-button .ui-button-text");

                    buttons.attr('class', '');
                    buttons.addClass("button");

                    var button1 = buttonsText[0];
                    var button2 = buttonsText[1];

                    Wat.T.translateElementContain($(button1));
                    Wat.T.translateElementContain($(button2));

                    // Delete jQuery UI default classes
                    buttons.attr("class", "");
                    // Add our button class
                    buttons.addClass("button");

                    $(button1).addClass(dialogConf.button1Class);
                    $(button2).addClass(dialogConf.button2Class);
                
                // Call to the callback function that will fill the dialog
                    dialogConf.fillCallback($(this));
                
                // Translate dialog strings
                    Wat.T.translateElement($(this).find('[data-i18n]'));
            },
            
            close: function () {
            }
        });     
    },
    
    updateLoginOnMenu: function () {
        $('.js-menu-corner').find('.login').html(Wat.C.login);
    },
    
    // Messages
    showMessage: function (msg, response) {
        // Process message to set expanded message if proceeds
        msg = this.processMessage (msg, response);
        
        this.clearMessageTimeout();
        
        $("html, body").animate({ scrollTop: 0 }, 200);

        if (msg.expandedMessage) {
            var expandIcon = '<i class="fa fa-plus-square-o expand-message js-expand-message" title="' + i18n.t('See more') + '..."></i>';
            var expandedMessage = '<article class="expandedMessage">' + msg.expandedMessage + '</article>';
        }
        else {
            var expandIcon = '';
            var expandedMessage = '';
        }
        
        var summaryMessage = '<summary>' + msg.message + '</summary>';
        
        $('.message').html(expandIcon + summaryMessage + expandedMessage);
        $('.message-container').hide().slideDown(500);
        $('.message-container').removeClass('success error info warning');
        $('.message-container').addClass(msg.messageType);
        
        // Success and info messages will be hidden automatically
        if (msg.messageType != 'error') {
            this.messageTimeout = setTimeout(function() { 
                $('.message-close').trigger('click');
            },3000);
        }
    },
    
    closeMessage: function () {
        this.clearMessageTimeout();
        $('.js-message-container').slideUp(500);
    },
    
    setMessageTimeout: function () {
        this.clearMessageTimeout();
        this.messageTimeout = setTimeout(function() { 
            $('.message-close').trigger('click');
        },3000);
    },
    
    clearMessageTimeout: function () {
        if (this.messageTimeout) {
            clearInterval(this.messageTimeout);
        }
    },
    
    processMessage: function (msg, response) {
        if (!response) {
            return msg;
        }
        
        if (!msg.message) {
            msg.message = response.message;
        }
        
        switch (msg.messageType) {
            case 'error':
                msg.expandedMessage = msg.expandedMessage || '';
                
                if (response.message != msg.message) {
                    msg.expandedMessage += '<strong>' + response.message + '</strong> <br/><br/>';
                }
            
                if (response.failures && !$.isEmptyObject(response.failures)) {
                    msg.expandedMessage += this.getTextFromFailures(response.failures) + '<br/>';
                }
                break;
        }
        
        return msg;
    },
    
    getTextFromFailures: function (failures) {
        // Group failures by text
        var failuresByText = {};
        $.each(failures, function(id, text) {
            failuresByText[text] = failuresByText[text] || [];
            failuresByText[text].push(id);
        });
        
        // Get class from the icon of the selected item from menu to use it in list
        var elementClass = $('.menu-option--selected').find('i').attr('class');
        
        var failuresList = '<ul>';
        $.each(failuresByText, function(text, ids) {
            failuresList += '<li>';
            failuresList += '<i class="fa fa-angle-double-right strong">' + text + '</i>';
            failuresList += '<ul>';
            $.each(ids, function(iId, id) {
                if ($('.list')) {
                    var elementName = $('.list').find('tr.row-' + id).find('.js-name .text').html();
                    if (!elementName) {
                        elementName = '(ID: ' + id + ')';
                    }
                    
                    failuresList += '<li class="' + elementClass + '">' + elementName + '</li>';
                }
                else {
                    failuresList += '<li class="' + elementClass + '">' + id + '</li>';
                }
            });
            failuresList += '</ul>';
            failuresList += '</li>';
        });
        
        failuresList += '</ul>';
        
        return failuresList;
    },
    
    
    fillCustomizeOptions: function (qvdObj) { 
        var listColumns = this.listColumns[qvdObj]
        var head = '<tr><th data-i18n="Column">' + i18n.t('Column') + '</th><th data-i18n="Show">' + i18n.t('Show') + '</th></tr>';
        var selector = '.js-customize-columns table';
        $(selector + ' tr').remove();
        $(selector).append(head);

        $.each(listColumns, function (fName, field) {
            if (field.fixed) {
                return;
            }

            var cellContent = Wat.I.controls.CheckBox({checked: field.display});
            
            var fieldText = field.text;
            
            if (field.noTranslatable) {
                var fieldTextTranslated = field.text;
            }
            else {
                var fieldTextTranslated = i18n.t(field.text);
            }
            
            var row = '<tr><td data-i18n="' + fieldText + '">' + fieldTextTranslated + '</td><td class="center">' + cellContent + '</td></tr>';
            
            $(selector).append(row);
        });
        
        var formFilters = this.formFilters[qvdObj]
        var head = '<tr><th data-i18n="Filter control">' + i18n.t('Filter control') + '</th><th data-i18n="Desktop version">' + i18n.t('Desktop version') + '</th><th data-i18n="Mobile version">' + i18n.t('Mobile version') + '</th></tr>';
        var selector = '.js-customize-filters table';
        $(selector + ' tr').remove();
        $(selector).append(head);

        $.each(formFilters, function (fName, field) {
            if (field.fixed) {
                return;
            }

            var cellContentDesktop = Wat.I.controls.CheckBox({checked: field.display && field.device != 'mobile'});
            var cellContentMobile = Wat.I.controls.CheckBox({checked: field.display && field.device != 'desktop'});
            
            var fieldType = '';
            switch(field.type) {
                case 'text':
                    fieldType = 'Text input';
                    break;
                case 'select':
                    fieldType = 'Combo box';
                    break;
            }
            
            var fieldText = field.text;
            
            if (field.noTranslatable) {
                var fieldTextTranslated = field.text;
            }
            else {
                var fieldTextTranslated = i18n.t(field.text);
            }
            
            var rowField = '<td><div data-i18n="' + fieldText + '">' + fieldTextTranslated + '</div><div class="second_row" data-i18n="' + fieldType + '">' + i18n.t(fieldType) + '</div></td>';
            var rowMobile = '<td class="center">' + cellContentDesktop + '</td>';
            var rowDesktop = '<td class="center">' + cellContentMobile + '</td></tr>';
            var row = '<tr>' + rowField + rowMobile + rowDesktop + '</tr>';
            
            $(selector).append(row);
        });
    },
    
    controls: {
        CheckBox: function (params) {
            var checked = '';
            if (params.checked){
                checked = 'checked';
            }

            var control = '<input type="checkbox" value="1" ' + checked + '/>';

            return control;
        },
    },
    
    getFieldTypeName: function (type) {
        var fieldType = '';
        switch(type) {
            case 'text':
                fieldType = 'Text input';
                break;
            case 'select':
                fieldType = 'Combo box';
                break;
        }
        
        return fieldType;
    },
    
    drawPieChart: function (name, data, maxLoadTime) {
        var plotSelector = '#' + name;
        var dataStatSelector = '.js-' + name + '-data';
        var percentStatSelector = '.js-' + name + '-percent';

        var data1 = data[0];
        var data2 = data[1];
        var dataTotal = data1 + data2;
        
        var maxLoadTime = maxLoadTime || 500;
        var speed = 30;
        
        var nLoads = maxLoadTime / speed;
        
        var step = Math.ceil(data1/nLoads);        

        // Pie common parameters
        var series = {
                pie: {
                    show: true,
                    innerRadius: 0.5,
                    label: {
                        show: false
                    }
                }
            };

        var legend = {
                show: false
            };

        var grid = {
                hoverable: false,
                clickable: false
            };

        var pieData = [
            { label: "",  data: 0, color: COL_BRAND},
            { label: "",  data: 0, color: '#DDD'}
        ];

        // First data start from 0 and second one from total to make grow effect
        pieData[0].data = 0;
        pieData[1].data = dataTotal;

        $(dataStatSelector).html('0/' + dataTotal);
        $(percentStatSelector).html('0%');

        var plot = $.plot(plotSelector, pieData, {
            series: series,
            legend: legend,
            grid: grid
        });

        if (data1 > 0 ) {
            var growInterval = setInterval(function(){
                // To make growing effect, first data will grow and second one decrease
                pieData[0].data+=step;
                pieData[1].data-=step;

                if (pieData[0].data > data1) {
                    pieData[0].data = data1;
                    pieData[1].data = data2;
                }
                
                plot.setData(pieData);
                plot.draw();

                // Upgrade data and percent stats
                $(dataStatSelector).html(pieData[0].data + '/' + dataTotal);

                var percentStat = parseInt((pieData[0].data / dataTotal) * 100);
                $(percentStatSelector).html(percentStat + '%');

                // When first data reach the real value, stop growing
                if (pieData[0].data === data1) {
                    clearInterval(growInterval);
                }
            }, speed);
        }
    },
    
    drawBarChart: function (name) {
        var plotSelector = '#' + name;
        
        var rawData = [[111, 0], [123, 1],[257, 2],[288, 3],[322, 4]];
        var dataSet = [{ label: "", data: rawData, color: COL_BRAND }];
        var ticks = [[0, "Node 1"], [1, "Node backup"], [2, "Node in da house"], [3, "No-Node"], [4, "Yesde Node"]];

        var options = {
            series: {
                bars: {
                    show: true
                }
            },
            bars: {
                align: "center",
                barWidth: 0.8,
                horizontal: true,
                fillColor: { colors: [{ opacity: 0.5 }, { opacity: 1}] },
                lineWidth: 1
            },
            xaxis: {
                axisLabel: "Running virtual machines",
                axisLabelUseCanvas: false,
                axisLabelFontSizePixels: 12,
                axisLabelFontFamily: 'Verdana, Arial',
                axisLabelPadding: 10,
                max: parseInt(rawData[rawData.length-1][0] * 1.1),
                tickColor: "#DDD",
                tickFormatter: function (v, axis) {
                    return v;
                },
                color: "black"
            },
            yaxis: {
                axisLabel: "Nodes",
                axisLabelUseCanvas: true,
                axisLabelFontSizePixels: 12,
                axisLabelFontFamily: 'Verdana, Arial',
                axisLabelPadding: 3,
                tickColor: "#DDD",
                ticks: ticks,
                color: "black"
            },
            legend: {
                noColumns: 0,
                labelBoxBorderColor: "#858585",
                position: "ne"
            },
            grid: {
                hoverable: true,
                borderWidth: 1,
                borderColor: "#CCC",
                backgroundColor: { colors: ["#EEEEEE", "#FFFFFF"] }
            }
        };
 
        $(document).ready(function () {
            $.plot($(plotSelector), dataSet, options);
            $(plotSelector).UseTooltip();
        });
 
        var previousPoint = null, previousLabel = null;
 
        $.fn.UseTooltip = function () {
            $(this).bind("plothover", function (event, pos, item) {
                if (item) {
                    if ((previousLabel != item.series.label) ||
                 (previousPoint != item.dataIndex)) {
                        previousPoint = item.dataIndex;
                        previousLabel = item.series.label;
                        $("#tooltip").remove();
 
                        var x = item.datapoint[0];
                        var y = item.datapoint[1];
 
                        var color = item.series.color;
                        //alert(color)
                        //console.log(item.series.xaxis.ticks[x].label);               
 
                        showTooltip(item.pageX,
                        item.pageY,
                        color,
                        item.series.yaxis.ticks[y].label +
                        " : <strong>" + x + "</strong> VMs");
                    }
                } else {
                    $("#tooltip").remove();
                    previousPoint = null;
                }
            });
        };
 
        function showTooltip(x, y, color, contents) {
            $('<div id="tooltip">' + contents + '</div>').css({
                position: 'absolute',
                display: 'none',
                top: y - 10,
                left: x + 10,
                border: '2px solid ' + color,
                padding: '3px',
                'font-size': '9px',
                'border-radius': '5px',
                'background-color': '#fff',
                'font-family': 'Verdana, Arial, Helvetica, Tahoma, sans-serif',
                opacity: 0.9
            }).appendTo("body").fadeIn(200);
        }
    }
}