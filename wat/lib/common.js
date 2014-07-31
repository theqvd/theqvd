function addSortIcons (view) {
    // Add sort icons to the table headers
    var sortIconHtml = '<i class="fa fa-sort sort-icon"></i>';

    if (view.sortedBy != '') {
        switch(view.sortedMode) {
            case '': 
                var sortIconHtmlSorted = sortIconHtml;
                break;
            case 'ASC':            
                var sortIconHtmlSorted = '<i class="fa fa-sort-asc sort-icon"></i>';
                break;
            case 'DESC':
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
    
}

function showAll() {
    var firstLoad = $('.wrapper').css('visibility') == 'hidden';

    showContent();

    if (firstLoad) {
        $('.wrapper').css('visibility','visible').hide().fadeIn('fast');
        $('.menu').css('visibility','visible').hide().fadeIn('fast');
        $('.header-wrapper').css('visibility','visible').hide().fadeIn('fast');
        $('.content').css('visibility','visible').hide().fadeIn('fast');
        $('.breadcrumbs').css('visibility','visible').hide().fadeIn('fast');
        $('.menu-corner').css('visibility','visible');
    }
}

function showContent() {
    // Set to the side box the same height of the content box
    $('.js-side').css('min-height', $('.content').height());
    
    $('.breadcrumbs').css('visibility','visible').hide().fadeIn();
    $('.content').css('visibility','visible').hide().fadeIn();
    $('.footer').css('visibility','visible').hide().fadeIn();
    $('.loading').hide();
}

function showLoading() {
    var firstLoad = $('.wrapper').css('visibility') == 'hidden';

    if (!firstLoad) {
        $('.breadcrumbs').hide();
        $('.content').hide();
        $('.footer').hide();
        $('.loading').show();
    }
}
