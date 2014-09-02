Wat.Views.HomeView = Wat.Views.MainView.extend({
    homeTemplateName: 'home',
    selectedSection: 'user',

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
        Wat.I.drawPieChart('running-nodes', [12, 21]);
        Wat.I.drawPieChart('running-vms', [285, 310]);
        
        Wat.I.drawBarChart('nodes-more-vms');
    }
});