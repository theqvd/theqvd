Wat.Views.HomeView = Wat.Views.MainView.extend({
    qvdObj: 'home',
    
    relatedDoc: {
        first_steps: "First steps",
        home: "Main page"
    },
    
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
        'connected_users_count',
        'running_hosts_count',
        'running_vms_count',
        'vms_with_expiration_date',
        'top_populated_hosts'
    ],
    
    stats: {
        blocked_dis_count: 0,
        blocked_hosts_count: 0,
        blocked_users_count: 0,
        blocked_vms_count: 0,
        connected_users_count: 0,
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
    
    events: {
        'click .js-exportPDF': 'exportPDF',
        'click .js-exportCSV': 'exportCSV'
    },
    
    breadcrumbs: {
        'screen': 'Home'
    },
    
    initialize: function (params) {
        $('.js-platform-menu').hide();

        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        Wat.B.bindHomeEvents();
                
        var templates = Wat.I.T.getTemplateList('home');
        
        Wat.A.getTemplates(templates, this.getStatistics, this); 
    },
    
    getStatistics: function (that) {
        Wat.A.performAction('qvd_objects_statistics', {}, {}, {}, that.render, that);
    },
    
    render: function () {
        var stats = this.retrievedData;
        
        if (stats == undefined || this.retrievedData.status != STATUS_SUCCESS) {
            stats = this.stats;
        }

        this.stats = stats;
        delete this.stats.message;
                
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.home, {
                stats: this.stats,
                cid: this.cid
            }
        );
        
        $(this.el).html(this.template);  
        
        this.printBreadcrumbs(this.breadcrumbs, '');

        this.renderVmsExpire ();
                
        this.loadData(this.stats);
                
        Wat.T.translateAndShow();
        
        // Open websockets for live fields
        Wat.WS.openStatsWebsockets(this.qvdObj, this.liveFields, this.cid);
    },
    
    renderVmsExpire: function () {
        if (!this.stats.vms_with_expiration_date) {
            return;
        }
        
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.homeVMsExpire, {
                vms_with_expiration_date: this.stats.vms_with_expiration_date
            }
        );
        
        $(".bb-vms-expire").html(this.template);
                
        Wat.T.translate();
    },
    
    loadData: function (stats) {
        if (!stats || stats.statusText == 'abort') {
            return;
        }
        
        var runningHostsData = [stats.running_hosts_count, stats.hosts_count - stats.running_hosts_count];
        Wat.I.G.drawPieChart('running-hosts', runningHostsData);      
        
        var connectedUsersData = [stats.connected_users_count, stats.users_count - stats.connected_users_count];
        Wat.I.G.drawPieChart('connected-users', connectedUsersData);
        
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

                    Wat.I.G.drawBarChartRunningVMs('hosts-more-vms', hostsMoreVMSData);
                }
            }, 50);
        }
    },
    
    exportPDF: function () {
        var doc = new jsPDF('p', 'mm');

        html2canvas($('.home-wrapper'), {
            background:'#fff',
            onrendered: function(canvas) {   
                $('canvas').hide();

                var imgData = canvas.toDataURL(
                    'image/jpeg');  

                var doc = new jsPDF('p', 'mm');

                doc.setFontSize(26);          
                doc.text(5, 20, $.i18n.t('QVD summary'));


                compress = 0;
                var shrinkFactor = canvas.width / 200;
                var height = canvas.height / shrinkFactor;
                var width = canvas.width / shrinkFactor;

                doc.addImage(imgData, 'JPEG', 5, 30, width, height, undefined, compress);

                var d = new Date();
                var date = d.toISOString().substring(0, 10);
                var time = d.toTimeString().substring(0, 8);
                time = time.replace(/:/g, '');
                var dateTime = date + '_' + time;

                var iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

                if (iOS) {
                    doc.output('dataurlnewwindow');
                }
                else {
                    doc.save('QVD-Summary-' + dateTime + '.pdf');
                }

                Wat.CurrentView.render();
            },
              allowTaint: true,
              logging: false,
              useCORS: true
        });
    },   
    
    exportCSV: function () {
        // Make a copy of the home stats
        var homeStats = $.extend(true, {}, this.retrievedData);
        
        // Delete data of API communication
        delete homeStats.sid;
        delete homeStats.status;
        
        // Convert top populated hosts structure to a simple string
        var topPopulatedHosts = [];
        $.each(homeStats.top_populated_hosts, function (i, host) {
            topPopulatedHosts.push(host.id + ',' + host.name + ',' + host.number_of_vms);
        });
        
        homeStats.top_populated_hosts = '"' + topPopulatedHosts.join('|') + '"';  
        
        // Convert vms with expiration date structure to a simple string
        var vmsWithExpirationDate = [];
        $.each(homeStats.vms_with_expiration_date, function (i, exp) {
            vmsWithExpirationDate.push(exp.id + ',' + exp.name + ',' + exp.expiration.replace('T',''));
        });
        
        homeStats.vms_with_expiration_date = '"' + vmsWithExpirationDate.join('|') + '"';
        
        var keys = Object.keys(homeStats);
        keys.sort();
        
        var values = keys.map(function(v) { 
            return homeStats[v]; 
        });
        
        // Build CSV
        var csv = '';
        csv += keys.join(',') + "\n";
        csv += values.join(',') + "\n";
        
        // Get Current date time to build file name
        var d = new Date();
        var date = d.toISOString().substring(0, 10);
        var time = d.toTimeString().substring(0, 8);
        time = time.replace(/:/g, '');
        var dateTime = date + '_' + time;
        
        // Export CSV file
        var blob = new Blob([csv], {type: "text/plain;charset=utf-8"});                       
        saveAs(blob, 'QVD-Summary-' + dateTime + '.csv');
    },
});