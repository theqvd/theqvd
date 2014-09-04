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
        
        this.loadData();
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
        
        this.printBreadcrumbs(this.breadcrumbs, '');
    },
    
    loadData: function () {
        var runningNodesData = [2, 1];
        Wat.I.G.drawPieChart('running-nodes', runningNodesData);
        
        var runningVMSData = [285, 13];
        Wat.I.G.drawPieChart('running-vms', runningVMSData);
        
        // Trick to draw bar chart when the div where it will be located will be rendered
        // We know that it is rendered when CSS width attribute change from 'XXX%' to 'XXXpx'

        var barsInterval = setTimeout(function () {
            if ($('#nodes-more-vms').css('width').indexOf("%") == -1) {
            var nodesMoreVMSData = [
                {
                    'id': 32,
                    'name': 'First Node',
                    'vms': 321
                },
                {
                    'id': 322,
                    'name': 'Node due',
                    'vms': 234
                },
                {
                    'id': 3,
                    'name': 'Trua Noden',
                    'vms': 111
                },
                {
                    'id': 1,
                    'name': 'Cuatreren Noers',
                    'vms': 56
                },
                {
                    'id': 666,
                    'name': 'Chinconochento',
                    'vms': 21
                }
            ];
                Wat.I.G.drawBarChart('nodes-more-vms', nodesMoreVMSData);
                clearInterval(barsInterval);
            }
        }, 50);
    }
});