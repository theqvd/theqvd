Wat.Views.DIListView = Wat.Views.ListView.extend({
    qvdObj: 'di',
    relatedDoc: {
        image_update: "Images update guide"
    },
    
    initialize: function (params) {
        this.collection = new Wat.Collections.DIs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    listEvents: {
        'change input[data-name="di_default"]': 'setDefault',
        'click .js-more-tags': 'showExtraTags'
    },
    
    showExtraTags: function (e) {
        var di_id = $(e.target).attr('data-di_id');
        $('.extra-tags-' + di_id).show();
        $(e.target).hide();
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
            
        this.tagChanges = arguments['__tags_changes__'];
        
        this.updateModel(arguments, filters, this.checkMachinesChanges, auxModel);
    },
    
    applyDefault: function (that) {
        // Came from list view
        var id = that.applyFilters.id[0];
        var checkMachinesChanges = that.checkMachinesChanges;
        that.model = that.collection.where({id: id})[0];
        
        var arguments = {
            "__tags_changes__": {
                'create': ['default'],
            }
        }
        
        that.tagChanges = arguments['__tags_changes__'];

        that.updateModel(arguments, {id: id}, checkMachinesChanges);
    },
    
    saveFile: function(arguments, disk_image_file) {
        var that = this;
        var file = disk_image_file[0].files[0];
        var data = new FormData();
        data.append('file', file);
        
        // Set as disk_image the basename of the file
        arguments.disk_image = file.name;
        
        // Get Url for the API call
        var url = Wat.C.getUpdateDiUrl() + '&action=di_create&arguments=' + JSON.stringify(arguments) + '&parameters=' + JSON.stringify({source: Wat.C.source});
        
        Wat.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));

        $.ajax({
            url: encodeURI(url), 
            data: data,
            type: 'POST',
            xhr: function() {  // Custom XMLHttpRequest
                var myXhr = $.ajaxSettings.xhr();
                if(myXhr.upload){ // Check if upload property exists
                    myXhr.upload.addEventListener('progress', that.updateProgress, false); // For handling the progress of the upload
                }
                
                return myXhr;
            },
            processData: false,
            contentType: false, // Setting contentType as false 'multipart/form-data' and boundary will be sent

        }).success(function(){
            //Wat.I.closeDialog(that.dialog);
            Wat.I.loadingUnblock();
            
            var realView = Wat.I.getRealView(that);
            realView.fetchList();
            realView.checkMachinesChanges(that);

            Wat.I.M.showMessage({message: i18n.t('Successfully created'), messageType: 'success'});
        }).fail(function(data){
            Wat.I.closeDialog(that.dialog);
            Wat.I.loadingUnblock();
            Wat.I.M.showMessage({message: i18n.t('Error creating'), messageType: 'error'});
        });
    },
    
    updateProgress: function (e)  {        
        if (e.total == 0) {
            var percent = 100;
        }
        else {
            var percent = parseInt((e.loaded / e.total) * 100);
        }

        var step = 5;
        
        if (percent == 100) {
            var progressHiddenInput = '<input type="hidden" data-di-uploading="completed">';
        }
        else {
            var progressHiddenInput = '<input type="hidden" data-di-uploading="inprogress-' + Math.floor(percent/step)*step + '">';
        }

        var progressData = [e.loaded, e.total - e.loaded];
        Wat.I.G.drawPieChartSimple('loading-block', progressData);

        var progressMessage = '';
        progressMessage += parseInt(e.loaded/(BYTES_ON_KB*BYTES_ON_KB)) + 'MB';
        progressMessage += ' / ';
        progressMessage += parseInt(e.total/(BYTES_ON_KB*BYTES_ON_KB)) + 'MB';
        progressMessage += progressHiddenInput;
        
        var creatingMessage = $.i18n.t('Uploading image to server');
        
        $('.loading-little-message').html(creatingMessage + '<br><br>' + progressMessage);
    },
    
    heavyCreateDownload: function (args, diskImageUrl) {
        // Di creation is a heavy operation. Screen will be blocked and a progress graph shown
        Wat.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
        Wat.WS.openWebsocket (this.qvdObj, 'di_create', {
                arguments: args,
                url: encodeURI(diskImageUrl)
        }, this.creatingProcessDownload, 'di/download/');
    },   
    
    heavyCreateStaging: function (args) {
        // Di creation is a heavy operation. Screen will be blocked and a progress graph shown
        Wat.I.loadingBlock($.i18n.t('Please, wait while action is performed') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
        Wat.WS.openWebsocket (this.qvdObj, 'di_create', {
                arguments: args
        }, this.creatingProcessStaging, 'staging');
    },
    
    creatingProcessStaging: function (qvdObj, id, data, ws) {
        var usefulView = Wat.I.getUsefulView(qvdObj, 'creatingProcess');
        usefulView.creatingProcess(qvdObj, id, data, ws, 'staging');
    },
    
    creatingProcessDownload: function (qvdObj, id, data, ws) {
        var usefulView = Wat.I.getUsefulView(qvdObj, 'creatingProcess');
        usefulView.creatingProcess(qvdObj, id, data, ws, 'download');
    },
    
    creatingProcess: function (qvdObj, id, data, ws, mode) {
        switch (parseInt(data.status)) {
            case STATUS_IN_PROGRESS:
                if (data.total_size == 0) {
                    var percent = 100;
                }
                else {
                    var percent = parseInt((data.copy_size / data.total_size) * 100);
                }

                var progressData = [data.copy_size, data.total_size - data.copy_size];
                Wat.I.G.drawPieChartSimple('loading-block', progressData);

                var step = 5;

                if (percent == 100) {
                    var progressHiddenInput = '<input type="hidden" data-di-uploading="completed">';
                }
                else {
                    var progressHiddenInput = '<input type="hidden" data-di-uploading="inprogress-' + Math.floor(percent/step)*step + '">';
                }
                
                var progressMessage = '';
                progressMessage += parseInt(data.copy_size/(BYTES_ON_KB*BYTES_ON_KB)) + 'MB';
                progressMessage += ' / ';
                progressMessage += parseInt(data.total_size/(BYTES_ON_KB*BYTES_ON_KB)) + 'MB';
                progressMessage += progressHiddenInput;
                
                var creatingMessage = '';
                switch (mode) {
                    case 'staging':
                        creatingMessage = $.i18n.t('Copying image from staging to images folder in server');
                        break;
                    case 'download':
                        creatingMessage = $.i18n.t('Downloading image from given URL to images folder in server');
                        break;
                }

                $('.loading-little-message').html(creatingMessage + '<br><br>' + progressMessage); 
                break;
            case STATUS_SUCCESS:
                if (ws.readyState == WS_OPEN) {
                    ws.close();
                }           
                Wat.I.loadingUnblock();
                $(".ui-dialog-buttonset button:first-child").trigger('click');
                
                var realView = Wat.I.getRealView(this);
                realView.fetchList();

                Wat.I.M.showMessage({message: i18n.t('Successfully created'), messageType: 'success'});
                
                // Check affected machine changes
                var realView = Wat.I.getRealView(this);
                realView.checkMachinesChanges(this);
                break;
            default:
                if (ws.readyState == WS_OPEN) {
                    ws.close();
                }   

                Wat.I.loadingUnblock();
                $(".ui-dialog-buttonset button:first-child").trigger('click');
                Wat.I.M.showMessage({message: i18n.t(ALL_STATUS[data.status]), messageType: 'error'});
        }
    }
});