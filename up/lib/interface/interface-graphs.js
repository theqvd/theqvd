Up.I.G = {
    drawPieChartSimple: function (name, data, loadTime) {
        var plotSelector = '#' + name;
        
        // If container is not loaded in dom, do nothing
        if ($(plotSelector).html() == undefined) {
            return;
        }
        
        var dataStatSelector = '.js-' + name + '-data';
        var percentStatSelector = '.js-' + name + '-percent';

        var data1 = data[0];
        var data2 = data[1];
        
        var dataTotal = data1 + data2;      

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

        // When no data, graph looks ugly. Hack to fix it is change data2 to 1
        if (data1 == 0 ){
            data2 = 1;
        }
        
        var pieData = [
            { label: "",  data: data1, color: Up.I.G.getGraphColorA()},
            { label: "",  data: data2, color: Up.I.G.getGraphColorB()}
        ];

        $(dataStatSelector).find('.data').html(data1);
        $(dataStatSelector).find('.data-total').html(dataTotal);
        
        if (dataTotal == 0) {
            var percentData = 0;
        }
        else {
            var percentData = parseInt((data1 / dataTotal) * 100);
        }
        
        $(percentStatSelector).html(percentData + '%');

        var plot = $.plot(plotSelector, pieData, {
            series: series,
            legend: legend,
            grid: grid
        });
                
        plot.setData(pieData);
        plot.draw();
    },
    
    getGraphColorA: function () {
        return $('.js-fake-graph-a').css('color');
    },
    
    getGraphColorB: function () {
        return $('.js-fake-graph-b').css('color');
    }
}