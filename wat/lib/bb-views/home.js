Wat.Views.HomeView = Wat.Views.MainView.extend({
    homeTemplateName: 'home',

    breadcrumbs: {
        'screen': 'Home'
    },
    
    initialize: function (params) {
        //this.model = new Wat.Models.DI(params);
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        Wat.B.bindHomeEvents();
        
        this.render();
    },
    
    events: {
    },
    
    render: function () {
        this.templateHome = Wat.A.getTemplate(this.homeTemplateName);
        
        // Fill the html with the template and the model
        this.template = _.template(
            this.templateHome, {
            }
        );
        
        $(this.el).html(this.template);
        
        Wat.T.translate();

        //Security margin for load successfuly the graphs
        //setTimeout (this.loadData, 100);
        
        Wat.A.performAction('qvd_objects_statistics', {}, {}, {}, this.loadData, this);

        this.printBreadcrumbs(this.breadcrumbs, '');
    },
    
    loadData: function (that) {
        var stats = that.retrievedData.result;
console.log(stats);
        var runningNodesData = [stats.Host.running, stats.Host.total - stats.Host.running];
        Wat.I.G.drawPieChart('running-hosts', runningNodesData);
        
        var runningVMSData = [stats.VM.running, stats.VM.total - stats.VM.running];
        Wat.I.G.drawPieChart('running-vms', runningVMSData);
        
        // Trick to draw bar chart when the div where it will be located will be rendered
        // We know that it is rendered when CSS width attribute change from 'XXX%' to 'XXXpx'

        var barsInterval = setTimeout(function () {
            if ($('#hosts-more-vms').css('width').indexOf("%") == -1) {
            var hostsMoreVMSData = [];
            
            $.each(stats.Host.population, function (iPop, population) {
                hostsMoreVMSData.push(population);
            });
                
            Wat.I.G.drawBarChart('hosts-more-vms', hostsMoreVMSData);
            clearInterval(barsInterval);
            }
        }, 50);
        
        $('.js-summary-users').html(stats.User.total);
        $('.js-summary-vms').html(stats.VM.total);
        $('.js-summary-hosts').html(stats.Host.total);
        $('.js-summary-osfs').html(stats.OSF.total);
        $('.js-summary-dis').html(stats.DI.total);
        
        $('.js-summary-blocked-users').html(stats.User.blocked);
        $('.js-summary-blocked-vms').html(stats.VM.blocked);
        $('.js-summary-blocked-hosts').html(stats.Host.blocked);
        $('.js-summary-blocked-dis').html(stats.DI.blocked);
    }
});