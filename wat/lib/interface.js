// Pure interface utilities
Wat.I = {
    showAll: function () {
        var firstLoad = $('.wrapper').css('visibility') == 'hidden';

        this.showContent();

        if (firstLoad) {
            $('.wrapper').css('visibility','visible').hide().fadeIn('fast');
            $('.menu').css('visibility','visible').hide().fadeIn('fast');
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
    
    addSortIcons: function (view) {
        // If not view is passed, use currentView
        if (view === undefined) {
            view = Wat.CurrentView;
        }
        // Add sort icons to the table headers
        var sortIconHtml = '<i class="fa fa-sort sort-icon"></i>';

        if (view.sortedBy != '') {
            switch(view.sortedOrder) {
                case '': 
                    var sortIconHtmlSorted = sortIconHtml;
                    break;
                case '-asc':            
                    var sortIconHtmlSorted = '<i class="fa fa-sort-asc sort-icon"></i>';
                    break;
                case '-desc':
                    var sortIconHtmlSorted = '<i class="fa fa-sort-desc sort-icon"></i>';
                    break;
            }
        }

        if (view.sortedBy != '') {
            $('[data-sortby="' + view.sortedBy + '"]').addClass('sorted');
        }

        $.each($('th.sortable'), function(index, cell) {        
            var headerCont = $(cell).html();
            if (view.sortedBy == '' || view.sortedBy != $(cell).attr('data-sortby')) {
                $(cell).html(headerCont + sortIconHtml);
            }
            else {
                $(cell).html(headerCont + sortIconHtmlSorted);
            }
        });

    },
    
    enableDataPickers: function () {
        $('.datetimepicker').datetimepicker({
            dayOfWeekStart: 1,
            lang: 'en',
            format:'Y-m-d h:i'
        });
    }
}