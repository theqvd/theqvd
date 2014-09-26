Wat.Views.HomeView = Wat.Views.MainView.extend({
    homeTemplateName: 'home',
    qvdObj: 'home',
    
    breadcrumbs: {
        'screen': 'Home'
    },
    
    initialize: function (params) {
        //this.model = new Wat.Models.DI(params);
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        Wat.B.bindHomeEvents();
        
        Wat.A.performAction('qvd_objects_statistics', {}, {}, {}, this.render, this);
    },
    
    events: {
    },
    
    render: function () {
        var stats = this.retrievedData.result;

        this.templateHome = Wat.A.getTemplate(this.homeTemplateName);
        
        // Fill the html with the template and the model
        this.template = _.template(
            this.templateHome, {
                stats: stats
            }
        );
        
        $(this.el).html(this.template);
        
        Wat.T.translate();
        
        this.loadData(stats);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
    },
    
    loadData: function (stats) {
        if (!stats) {
            return;
        }
        var runningHostsData = [stats.Host.running, stats.Host.total - stats.Host.running];
        Wat.I.G.drawPieChart('running-hosts', runningHostsData);
        
        var runningVMSData = [stats.VM.running, stats.VM.total - stats.VM.running];
        Wat.I.G.drawPieChart('running-vms', runningVMSData);

        if ($('#hosts-more-vms').html() != undefined) {
            // Trick to draw bar chart when the div where it will be located will be rendered
            // We know that it is rendered when CSS width attribute change from 'XXX%' to 'XXXpx'
            setTimeout(function () {
                if ($('#hosts-more-vms').css('width').indexOf("%") == -1) {
                var hostsMoreVMSData = [];

                $.each(stats.Host.population, function (iPop, population) {
                    hostsMoreVMSData.push(population);
                });

                Wat.I.G.drawBarChart('hosts-more-vms', hostsMoreVMSData);
                }
            }, 50);
        }
    }
});