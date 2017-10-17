Wat.WS.changeWebsocketDi = function (id, field, data, row) {
    switch (field) {
        case 'percentage':
            var view = Wat.U.getViewFromQvdObj('di');
            var progressBar = $('.progressbar[data-id="' + id + '"]');
            
            $(progressBar).attr('data-percent', row.percentage);
            $(progressBar).attr('data-remaining', Wat.U.getRemainingTime(row.elapsed_time, row.percentage));
            $(progressBar).attr('data-elapsed', row.elapsed_time);
            $(progressBar).progressbar("value", parseInt(row.percentage));
            break;
    }
}