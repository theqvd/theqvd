Wat.I.G = {
    drawPieChart: function (name, data, loadTime) {
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
            var loadTime = loadTime || 200;
            var speed = 30;

            var nLoads = loadTime / speed;

            var step = data1 / nLoads;
            
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
                $(dataStatSelector).html(parseInt(pieData[0].data) + '/' + dataTotal);

                var percentStat = parseInt((pieData[0].data / dataTotal) * 100);
                $(percentStatSelector).html(percentStat + '%');

                // When first data reach the real value, stop growing
                if (pieData[0].data === data1) {
                    clearInterval(growInterval);
                }
            }, speed);
        }
    },
    
    drawBarChart: function (name, data, loadTime) {
        var plotSelector = '#' + name;
        
        var barData = [];
        var ticks = [];
        var ids = [];
        $.each(data, function (iNode, node) {
            var index = data.length - iNode - 1;
            // First value = 0 to increase it with growing effect
            barData.push([0, index]);
            ticks.push([index, node.name]);
            ids.push(node.id);
        });

        var maxValue = data.length > 0 ? data[0].number_of_vms : 10;
        var dataSet = [{ label: "", data: barData, color: COL_BRAND }];

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
                fillColor: { colors: [{ opacity: 0.8 }, { opacity: 1}] },
                lineWidth: 1
            },
            xaxis: {
                axisLabel: i18n.t("Running VMs"),
                axisLabelUseCanvas: false,
                axisLabelFontSizePixels: 12,
                axisLabelFontFamily: 'Verdana, Arial',
                axisLabelPadding: 10,
                max: parseInt(maxValue * 1.1),
                tickColor: "#DDD",
                tickFormatter: function (v, axis) {
                    return v;
                },
                color: "black",
                ticks: 3
            },
            yaxis: {
                axisLabel: i18n.t("Nodes"),
                axisLabelUseCanvas: true,
                axisLabelFontSizePixels: 12,
                axisLabelFontFamily: 'Verdana, Arial',
                axisLabelPadding: 3,
                tickColor: "#DDD",
                ticks: ticks,
                color: "black",
                
            },
            legend: {
                noColumns: 0,
                labelBoxBorderColor: "#858585",
                position: "ne"
            },
            grid: {
                hoverable: true,
                clickable: true,
                borderWidth: 1,
                borderColor: "#CCC",
                backgroundColor: { colors: ["#EEEEEE", "#FFFFFF"] }
            }
        };
 
        var plot = $.plot($(plotSelector), dataSet, options);

        if (barData.length > 0 ) {
            var loadTime = loadTime || 200;
            var speed = 30;

            var nLoads = loadTime / speed;

            var load = 0;
            var growInterval = setInterval(function() {
                load++;
                // To make growing effect, increase proportional part
                $.each(data, function (iNode, node) {
                    var index = data.length - iNode - 1;
                    
                    // First value = 0 to increase it with growing effect
                    if (load >= nLoads) {
                        barData[iNode][0] = node.number_of_vms;
                    }
                    else {
                        barData[iNode][0] = parseInt((node.number_of_vms / nLoads) * load);
                    }
                });

                dataSet = [{ label: "", data: barData, color: COL_BRAND }];
                $.plot($(plotSelector), dataSet, options);

                // After last load, clear interval
                if (load >= nLoads) {
                    clearInterval(growInterval);
                }
            }, speed);
            
            window.plot = plot;
            window.barData = barData;
        }
        
        // Tooltip
        var previousPoint = null, previousLabel = null;
 
        $(plotSelector).bind("plothover", function (event, pos, item) {
            if (item) {
                $(this).css('cursor', 'pointer');
                if ((previousLabel != item.series.label) ||
             (previousPoint != item.dataIndex)) {
                    previousPoint = item.dataIndex;
                    previousLabel = item.series.label;
                    $("#tooltip").remove();

                    var x = item.datapoint[0];
                    var y = item.datapoint[1];

                    var color = item.series.color;

                    showTooltip(item.pageX,
                    item.pageY,
                    color,
                    "<strong>" + x + "</strong> VMs");
                }
            } else {
                $(this).css('cursor', 'default');
                $("#tooltip").remove();
                previousPoint = null;
            }
        });
        
        $(plotSelector).bind("plotclick", function (event, pos, item) {
			if (item) {
				window.location = "#/host/" + ids[item.dataIndex];
			}
		});
 
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