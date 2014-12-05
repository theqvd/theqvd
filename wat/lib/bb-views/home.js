Wat.Views.HomeView = Wat.Views.MainView.extend({
    homeTemplateName: 'home',
    homeTemplateVmsExpireName: 'home-vms-expire',
    qvdObj: 'home',
    liveFields: [
        'users_count', 
        'vms_count', 
        'hosts_count', 
        'osfs_count', 
        'dis_count',
        'blocked_users_count', 
        'blocked_vms_count', 
        'blocked_hosts_count', 
        'blocked_dis_count',
        'running_hosts_count',
        'running_hosts_count',
        'running_vms_count',
        'running_vms_count',
        'vms_with_expiration_date',
        'top_populated_hosts'
    ],
    
    stats: {
        blocked_dis_count: 0,
        blocked_hosts_count: 0,
        blocked_users_count: 0,
        blocked_vms_count: 0,
        dis_count: 0,
        hosts_count: 0,
        osfs_count: 0,
        running_hosts_count: 0,
        running_vms_count: 0,
        status: 0,
        top_populated_hosts: [],
        users_count: 0,
        vms_count: 0,
        vms_with_expiration_date: []
    },
    
    breadcrumbs: {
        'screen': 'Home'
    },
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        Wat.B.bindHomeEvents();
        
        Wat.A.performAction('qvd_objects_statistics', {}, {}, {}, this.render, this);
    },
    
    events: {
    },
    
    render: function () {
        var stats = this.retrievedData;
        
        if (stats == undefined) {
            stats = this.stats;
        }

        this.stats = stats;
        delete this.stats.message;
        
        this.templateHome = Wat.A.getTemplate(this.homeTemplateName);
        
        // Fill the html with the template and the model
        this.template = _.template(
            this.templateHome, {
                stats: this.stats
            }
        );
        
        $(this.el).html(this.template);  
        
        this.renderVmsExpire ();
        
        Wat.T.translate();
        
        this.loadData(this.stats);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        // Open websockets for live fields
        Wat.WS.openStatsWebsockets(this.qvdObj, this.liveFields, this.cid);
    },
    
    renderVmsExpire: function () {
        if (!this.stats.vms_with_expiration_date) {
            return;
        }
        this.templateHomeVmsExpire = Wat.A.getTemplate(this.homeTemplateVmsExpireName);
        // Fill the html with the template and the model
        this.template = _.template(
            this.templateHomeVmsExpire, {
                vms_with_expiration_date: this.stats.vms_with_expiration_date
            }
        );
        
        $(".bb-vms-expire").html(this.template);
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