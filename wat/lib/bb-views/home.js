Wat.Views.HomeView = Wat.Views.MainView.extend({
    homeTemplateName: 'home',
    qvdObj: 'home',
    defaultStats: {
        User: {
            total: 0,
        },
        VM: {
            total: 0,
            expiration: []
        },
        Host: {
            total: 0,
        },
        OSF: {
            total: 0,
        },
        DI: {
            total: 0,
        }
    },
    
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

        if (stats == undefined) {
            stats = this.defaultStats;
        }
        
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
        
        var runningHostsData = [stats.running_hosts_count, stats.hosts_count - stats.running_hosts_count];
        Wat.I.G.drawPieChart('running-hosts', runningHostsData);
        
        var runningVMSData = [stats.running_vms_count, stats.vms_count - stats.running_vms_count];
        Wat.I.G.drawPieChart('running-vms', runningVMSData);

        if ($('#hosts-more-vms').html() != undefined) {
            // Trick to draw bar chart when the div where it will be located will be rendered
            // We know that it is rendered when CSS width attribute change from 'XXX%' to 'XXXpx'
            setTimeout(function () {
                if ($('#hosts-more-vms').css('width').indexOf("%") == -1) {
                var hostsMoreVMSData = [];

                $.each(stats.top_populated_hosts, function (iPop, population) {
                    hostsMoreVMSData.push(population);
                });

                Wat.I.G.drawBarChart('hosts-more-vms', hostsMoreVMSData);
                }
            }, 50);
        }
    }
});