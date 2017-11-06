Wat.Views.OSFListView = Wat.Views.ListView.extend({
    qvdObj: 'osf',
    liveFields: ['number_of_vms', 'number_of_dis'],
    trees: [],

    initialize: function (params) {
        this.collection = new Wat.Collections.OSFs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {
        'click a.js-toggle-dis-row': 'toggleDIsRow'
    },    
    
    toggleDIsRow: function (e) {
        if ($(e.target).hasClass('disabled')) {
            return;
        }
        
        // Reset selectedItems array
        this.selectedItems = [];
        
        var id = $(e.target).attr('data-id');
        var parentRow = $(e.target).closest('tr');
        var parentRowCols = $(e.target).closest('tr').find('td').length;
        
        if ($('tr[data-dis-row="' + id + '"]').length) {
            // Change icon
            $(e.target).removeClass(CLASS_ICON_BUTTON_SUBROW_CLOSE);
            $(e.target).addClass(CLASS_ICON_BUTTON_SUBROW_OPEN);
            
            // Remove row
            $('tr[data-dis-row="' + id + '"]').remove();
            
            // Stop progress bar interval
            clearInterval(Wat.CurrentView.embeddedViews.di.intervals['localDiProgressTime']);
        }
        else {
            // Uncheck all OSF checks
            $('.check_all[data-check-id="osf"]').prop('checked',true).trigger('click');
            
            // Close other possible opened rows
            $('.js-toggle-dis-row.' + CLASS_ICON_BUTTON_SUBROW_CLOSE).trigger('click');
            
            // Change icon
            $(e.target).removeClass(CLASS_ICON_BUTTON_SUBROW_OPEN);
            $(e.target).addClass(CLASS_ICON_BUTTON_SUBROW_CLOSE);
            
            // Add subrow
            $(parentRow).after('<tr data-dis-row="' + id + '"><td colspan=' + parentRowCols + ' class="dis-subrow" data-dis-row="' + id + '"><div class="bb-list list-wrapper">' + HTML_LOADING + '</div></td></tr>');
            
            var params = {};
            params.whatRender = 'list';
            params.listContainer = '.dis-subrow';
            params.forceListColumns = {
                checks: true,
                info: true,
                version: true,
                tags: true,
                description: true,
                creation_date: true
            };
            params.changeFunctionsInternal = {
                renderListBlock: 'renderEmbeddedBlockList',
                renderList: 'renderEmbeddedList'
            };
            
            params.filters = {"osf_id": id};
            
            Wat.CurrentView.embeddedViews = Wat.CurrentView.embeddedViews || {};
            
            Wat.CurrentView.embeddedViews.di = new Wat.Views.DIListView(params);
        }
    },
    
    renderList: function (params) {
        Wat.Views.ListView.prototype.renderList.apply(this, [params]);
        
        // Open a websocket to monitor published images number
        Wat.WS.openWebsocket('di', 'di_get_list', {
            filters: {state: 'published'}, 
            fields: ['osf_id']
        }, function (qvdObj, id, data) {
            var diCount = {};
            
            $.each(data.rows, function (i, row) {
                if (!diCount[row.osf_id]) {
                    diCount[row.osf_id] = 0;
                }
                
                diCount[row.osf_id]++;
            });
            
            $.each(diCount, function (osfId, diCount) {
                $('[data-wsupdate="number_of_published_dis"][data-id="' + osfId + '"]').html(diCount);
            });
            
            // Not included osfs into rows, will be setted to 0
            var queryIds = Object.keys(diCount);
            $.each($('[data-wsupdate="number_of_published_dis"]'), function (i, element) {
                if ($.inArray($(element).attr('data-id'), queryIds) == -1) {
                    $(element).html(0);
                }
            });
        }, 'ws', 'list');
    },
});