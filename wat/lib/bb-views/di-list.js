Wat.Views.DIListView = Wat.Views.ListView.extend({
    qvdObj: 'di',

    initialize: function (params) {
        this.collection = new Wat.Collections.DIs(params);

        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    listEvents: {
        'change input[name="di_default"]': 'setDefault'
    },
    
    setDefault: function (e) {
        var di_id = $(e.target).attr('data-di_id');
        
        var filters = {"id": di_id};
        var arguments = {
            "__tags_changes__": {
                'create': ['default'],
            },
        };
        
        var auxModel = new Wat.Models.DI();
        
        this.updateModel(arguments, filters, this.fetchList, auxModel);
    },
    
    fetchFilters: function () {
        Wat.Views.ListView.prototype.fetchFilters.apply(this);

        // As the osf filter in DI list hasn't all option, we trigger the change once it is loaded to perform the filtering
        $('.filter-control [name="osf"]').trigger('change');
    },
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.DI();
        this.dialogConf.title = $.i18n.t('New Disk image');

        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
        
        // Configure tags inputs
        Wat.I.tagsInputConfiguration();
        
        // Fill disk images of staging folder select on disk images creation form
        var params = {
            'action': 'dis_in_staging',
            'controlName': 'disk_image',
            'nameAsId': true
        };
        
        Wat.A.fillSelect(params); 
        
        Wat.I.chosenElement('[name="disk_image"]', 'advanced100');

        // Fill OSF select on virtual machines creation form
        var params = {
            'action': 'osf_tiny_list',
            'selectedId': $('.' + this.cid + ' .filter select[name="osf"]').val(),
            'controlName': 'osf_id'
        };
        
        // If exist tenant control (in superadmin cases) show osfs of selected tenant
        if ($('[name="tenant_id"]').val() != undefined) {
            // Add the tenant id to the osf select filling
            params.filters = {
                'tenant_id': $('[name="tenant_id"]').val()
            };
            
            // Add an event to the tenant select change
            Wat.B.bindEvent('change', '[name="tenant_id"]', Wat.B.editorBinds.filterTenantOSFs);
        }
        
        Wat.A.fillSelect(params);  
        
        Wat.I.chosenElement('[name="osf_id"]', 'single100');
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');

        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        var osf_id = context.find('select[name="osf_id"]').val();
        
        var arguments = {
            "blocked": blocked ? 1 : 0,
            "osf_id": osf_id
        };
        
        if (!$.isEmptyObject(properties.set)) {
            arguments["__properties__"] = properties.set;
        }
        
        var disk_image = context.find('select[name="disk_image"]').val();
        if (disk_image) {
            arguments["disk_image"] = disk_image;
        }   
        
        var version = context.find('input[name="version"]').val();
        if (version && Wat.C.checkACL('di.create.version')) {
            arguments["version"] = version;
        }
        
        var tags = context.find('input[name="tags"]').val();
        tags = tags && Wat.C.checkACL('di.create.tags') ? tags.split(',') : [];
        
        var def = context.find('input[name="default"][value=1]').is(':checked');
        
        // If we set default add this tag
        if (def && Wat.C.checkACL('di.create.default')) {
            tags.push('default');
        }
        
        arguments['__tags__'] = tags;
             
        if (Wat.C.isSuperadmin) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            arguments['tenant_id'] = tenant_id;
        }
        
        //this.createModel(arguments, this.fetchList);
        this.heavyCreate(arguments);
    },
    
    heavyCreate: function (args) {
        // Di creation is a heavy operation. Screen will be blocked and a progress graph shown
        Wat.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
        Wat.WS.openWebsocket (this.qvdObj, 'di_create', {}, args, [], this.creatingProcess, 'staging');
    },
    
    creatingProcess: function (qvdObj, id, data, ws) {
        if (data.status == 1000) {
            if (data.total_size == 0) {
                var percent = 100;
            }
            else {
                var percent = parseInt((data.copy_size / data.total_size) * 100);
            }
            
            var progressData = [data.copy_size, data.total_size - data.copy_size];
            Wat.I.G.drawPieChartSimple('loading-block', progressData);
            
            $('.loading-little-message').html(parseInt(data.copy_size/(1024*1024)) + 'MB / ' + parseInt(data.total_size/(1024*1024)) + 'MB');
        }
        
        if (data.status == STATUS_SUCCESS) {
            if (ws.readyState == 1) {
                ws.close();
            }           
            Wat.I.loadingUnblock();
            $(".ui-dialog-buttonset button:first-child").trigger('click');
            Wat.CurrentView.fetchList();
            Wat.I.showMessage({message: i18n.t('Successfully created'), messageType: 'success'});
        }
    }
});