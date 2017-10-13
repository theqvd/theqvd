Wat.WS.changeWebsocketDi = function (id, field, data, row) {
    switch (field) {
        case 'percentage':
            var view = Wat.U.getViewFromQvdObj('di');
            var progressBar = $('.progressbar[data-id="' + id + '"]');
            var percentage = parseFloat(row.percentage * 100).toFixed(2);
            
            $(progressBar).attr('data-percent', percentage);
            $(progressBar).attr('data-remaining', Wat.U.getRemainingTime(row.elapsed_time, percentage));
            $(progressBar).attr('data-elapsed', row.elapsed_time);
            $(progressBar).progressbar("value", percentage);
            break;
    }
}