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
        // When no data, graph looks ugly. Hack to fix it is change dataTotal to 1
        pieData[1].data = dataTotal || 1;

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
            { label: "",  data: data1, color: COL_BRAND},
            { label: "",  data: data2, color: '#DDD'}
        ];

        $(dataStatSelector).html(data1 + '/' + dataTotal);
        
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
    
    drawBarChartRunningVMs: function (name, data, loadTime) {
        var plotSelector = '#' + name;
        
        // Complete data with a minimum of 5 nodes
        if (data.length < 5){
            for(i=data.length;i<5;i++) {
                data.push({
                    id: 0,
                    name: "",
                    number_of_vms: 0
                });
            }
        }
        
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
    },
    
    drawBarChartRunningVMsSimple: function (name, data, loadTime) {
        var plotSelector = '#' + name;
        
        // Complete data with a minimum of 5 nodes
        if (data.length < 5){
            for(i=data.length;i<5;i++) {
                data.push({
                    id: 0,
                    name: "",
                    number_of_vms: 0
                });
            }
        }
        
        
        var barData = [];
        var ticks = [];
        var ids = [];
        $.each(data, function (iNode, node) {
            var index = data.length - iNode - 1;
            
            barData.push([node.number_of_vms, index]);
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
            dataSet = [{ label: "", data: barData, color: COL_BRAND }];
            $.plot($(plotSelector), dataSet, options);
            
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
    },
    
    drawBarChartLog: function (name, data, loadTime) {
        var plotSelector = '#' + name;
        var placeHolder = $(plotSelector);
        
        var barData = [];
        var ticks = [];
        var ids = [];
        var limits = [];
        
        var nTicks = 8;
        var modTicks = parseInt(data.length / nTicks);
        $.each(data, function (iNode, node) {
            var index = data.length - iNode - 1;
            // First value = 0 to increase it with growing effect
            barData.push([iNode, node.registers]);
            
            if (iNode % modTicks == 0) {
                var longDate = new Date(node.id*1000);
                var month = Wat.U.padNumber(longDate.getMonth() + 1);
                var day = Wat.U.padNumber(longDate.getDate());
                //var year = Wat.U.padNumber(longDate.getFullYear());
                var hour = Wat.U.padNumber(longDate.getHours());
                var minute = Wat.U.padNumber(longDate.getMinutes());
                //var second = Wat.U.padNumber(longDate.getSeconds());
                var shortDate = month + "/" + day + " " + hour + ":" + minute;

                ticks.push([iNode, shortDate]);
            }
            else {
                ticks.push([iNode, '']);
            }
            
            ids.push(node.id);
            
            if (limits.length > 0) {
                limits[limits.length-1].max = node.id;
            }
            
            limits.push({
                min: node.id,
                max: null
            });
        });

        var dataSet = [{ label: "", data: barData, color: COL_BRAND }];

        var options = {
            series: {
                bars: {
                    show: true
                },
                lines: {
                    show: false
                }
            },
            bars: {
                align: "center",
                barWidth: 0.8,
                horizontal: false,
                fillColor: { colors: [{ opacity: 0.8 }, { opacity: 1}] },
                lineWidth: 1
            },
            lines: {
                lineWidth: 1
            },
            xaxis: {
                axisLabelUseCanvas: false,
                axisLabelFontSizePixels: 7,
                axisLabelFontFamily: 'Verdana, Arial',
                axisLabelPadding: 10,
                //max: parseInt(maxValue * 1.1),
                tickColor: "#DDD",
                tickFormatter: function (v, axis) {
                    return v;
                },
                color: "black",
                ticks: ticks
            },
            yaxis: {
                axisLabel: i18n.t("Log registers"),
                axisLabelUseCanvas: true,
                axisLabelFontSizePixels: 12,
                axisLabelFontFamily: 'Verdana, Arial',
                axisLabelPadding: 13,
                tickColor: "#DDD",
                tickFormatter: function (v, axis) {
                    return v;
                },
                ticks: 3,
                color: "black",
                
            },
            legend: {
                //noColumns: 0,
                //labelBoxBorderColor: "#858585",
                //position: "ne"
            },
            grid: {
                hoverable: true,
                clickable: true,
                borderWidth: 1,
                borderColor: "#CCC",
                backgroundColor: { colors: ["#EEEEEE", "#FFFFFF"] }
            },
			selection2: {
				mode: "x"
			}
        };
        
        var plot = $.plot($(plotSelector), dataSet, options);
        
        if (barData.length > 0 ) {
            dataSet = [{ label: "", data: barData, color: COL_BRAND }];
            $.plot($(plotSelector), dataSet, options);
            
            window.plot = plot;
            window.barData = barData;
        }
        
        if (barData.length > 0 && false) {
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
                        barData[iNode][0] = node.registers;
                    }
                    else {
                        barData[iNode][0] = parseInt((node.registers / nLoads) * load);
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

                    if (y == 1) {
                        var unit = $.i18n.t('Register');
                    }
                    else {
                        var unit = $.i18n.t('Registers');
                    }
                    showTooltip(item.pageX,
                    item.pageY,
                    color,
                    "<strong>" + y + "</strong> " + unit);
                }
            } else {
                $(this).css('cursor', 'default');
                $("#tooltip").remove();
                previousPoint = null;
            }
        });
        
        $(plotSelector).bind("plotclick", function (event, pos, item) {
            if (barData[item.dataIndex][1] > 0) {
                var min = limits[item.dataIndex].min;
                var max = limits[item.dataIndex].max;
                
                if (item && Wat.C.checkACL('host.see-details.')) {
                    //window.location = "#/host/" + ids[item.dataIndex];
                }
            }
		});
        
		$(plotSelector).bind("plotselected", function (event, ranges) {

			//$("#selection").text(ranges.xaxis.from.toFixed(1) + " to " + ranges.xaxis.to.toFixed(1));

			//var zoom = $("#zoom").prop("checked");
            zoom = true;
			if (zoom) {
				$.each(plot.getXAxes(), function(_, axis) {
					var opts = axis.options;
					opts.min = ranges.xaxis.from;
					opts.max = ranges.xaxis.to;
				});
				plot.setupGrid();
				plot.draw();
				plot.clearSelection();
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
    },
    
}