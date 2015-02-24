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
        'change input[name="di_default"]': 'setDefault',
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
        
        this.updateModel(arguments, filters, this.fetchList, auxModel);
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
            'nameAsId': true,
            'chosenType': 'advanced100'
        };
        
        Wat.A.fillSelect(params); 

        // If main view is osf view, we are creating a disk image from osf details view. 
        // OSF and tenant (if exists) controls will be removed
        if (Wat.CurrentView.qvdObj == 'osf') {
            $('[name="osf_id"]').parent().parent().remove();

            var userHidden = document.createElement('input');
            userHidden.type = "hidden";
            userHidden.name = "osf_id";
            userHidden.value = Wat.CurrentView.model.get('id');
            $('.editor-container').append(userHidden);
                        
            if ($('[name="tenant_id"]').val() != undefined) {
                $('[name="tenant_id"]').parent().parent().remove();
                
                var tenantHidden = document.createElement('input');
                tenantHidden.type = "hidden";
                tenantHidden.name = "tenant_id";
                tenantHidden.value = Wat.CurrentView.model.get('tenant_id');
                $('.editor-container').append(tenantHidden);
            }
        }
        else {
            // Fill OSF select on virtual machines creation form
            var params = {
                'action': 'osf_tiny_list',
                'selectedId': $('.' + this.cid + ' .filter select[name="osf"]').val(),
                'controlName': 'osf_id',
                'chosenType': 'advanced100'
            };

            // If exist tenant control (in superadmin cases) show osfs of selected tenant
            if ($('[name="tenant_id"]').length > 0) {
                // Add an event to the tenant select change
                Wat.B.bindEvent('change', '[name="tenant_id"]', Wat.B.editorBinds.filterTenantOSFs);
            }

            Wat.A.fillSelect(params);  
        }
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
        var osf_id = context.find('[name="osf_id"]').val();
        
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
        
        var disk_image_file = context.find('input[name="disk_image_file"]');
        
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
        //this.createDI(arguments, file, this.fetchList);
        
        //this.saveFile(arguments, disk_image_file);
    },
    
    saveFilePlugin: function(arguments, disk_image_file) {    
        // Get Url for the API call
        var url = Wat.C.getUpdateDiUrl() + '&action=di_create&arguments=' + JSON.stringify(arguments);

        console.log(url);
        
        disk_image_file.fileupload({
            url: url,
            dateType: 'json',
            replaceFileInput: false,
            done: function (e, data) {
                console.info(data);

/*                $.each(data.result.files, function (index, file) {
                    console.log(file.name + ' Uploaded');
                });*/
            },
            fail: function (e, data) {
                console.error(data);
            },
            always: function (e, data) {
                console.warn(data);
            }
        });
    },
    
    saveFile: function(arguments, disk_image_file) {
        var that = this;
        var file = disk_image_file[0].files[0];
        var data = new FormData();
        data.append('file', file);
        
        // Set as disk_image the basename of the file
        arguments.disk_image = file.name;
        
        // Get Url for the API call
        var url = Wat.C.getUpdateDiUrl() + '&action=di_create&arguments=' + JSON.stringify(arguments);

        $.ajax({
            url: url, 
            data: data,
            type: 'POST',
            xhr: function() {  // Custom XMLHttpRequest
                var myXhr = $.ajaxSettings.xhr();
                if(myXhr.upload){ // Check if upload property exists
                    //myXhr.upload.addEventListener('progress', that.updateProgress, false); // For handling the progress of the upload
                    myXhr.upload.addEventListener('progress', that.updateProgress, false); // For handling the progress of the upload
                }
                return myXhr;
            },
            processData: false,
            contentType: false, // Setting contentType as false 'multipart/form-data' and boundary will be sent

        }).success(function(){
            console.info("Success: Files sent!");
        }).fail(function(data){
            console.error("An error occurred, the files couldn't be sent!");
            console.error(data);
        });
        
        return;
        
        $.ajax({
            url: url,
            data: data,
            cache: false,
            contentType: false,
            processData: false,
            type: 'POST',
            success: function(data){
                console.info('sucess uploading');
            },
            error: function(data){
                console.error('error uploading');
            }
        });
    },
    
    updateProgress: function (e, e2)  {
        console.warn(e);
        console.warn(e2);
    },
                                                 
   createDI: function (arguments, file, successCallback) {
        this.model.setOperation('create');
        
        var messages = {
            'success': 'Successfully created',
            'error': 'Error creating'
        };
        
        var model = this.model;
        var filters = {};

        var that = this;
        model.save(arguments, {filters: filters, file: '/tmp/test'}).complete(function(e, a, b) {
            Wat.I.loadingUnblock();

            var callResponse = e.status;
            var response = {status: e.status};
            
            if (e.responseText) {
                try {
                    response = JSON.parse(e.responseText);
                }
                catch (err) {
                    //console.log (e.responseText);
                }
            }
            
            that.retrievedData = response;
            successCallback(that);
            
            if (callResponse == 200 && response.status == STATUS_SUCCESS) {
                that.message = messages.success;
                that.messageType = 'success';
            }
            else {
                that.message = messages.error;
                that.messageType = 'error';
            }

            if (that.dialog) {
                that.dialog.dialog('close');
            }
                        
            var messageParams = {
                message: that.message,
                messageType: that.messageType
            };
            
            Wat.I.showMessage(messageParams, response);
        });
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
            
            $('.loading-little-message').html($.i18n.t('Copying image to server') + '<br><br>' + parseInt(data.copy_size/(1024*1024)) + 'MB / ' + parseInt(data.total_size/(1024*1024)) + 'MB');
        }
                
        if (data.status == STATUS_SUCCESS) {
            if (ws.readyState == WS_OPEN) {
                ws.close();
            }           
            Wat.I.loadingUnblock();
            $(".ui-dialog-buttonset button:first-child").trigger('click');
            
            if (qvdObj == Wat.CurrentView.qvdObj) {
                Wat.CurrentView.fetchList();
            }
            else if (qvdObj == Wat.CurrentView.sideView2.qvdObj) {
                Wat.CurrentView.sideView2.fetchList();
            }
            
            Wat.I.showMessage({message: i18n.t('Successfully created'), messageType: 'success'});
        }
        
        if (data.status == STATUS_ELEMENT_ALREADY_EXISTS) {
            if (ws.readyState == WS_OPEN) {
                ws.close();
            }   
            
            Wat.I.loadingUnblock();
            $(".ui-dialog-buttonset button:first-child").trigger('click');
            Wat.I.showMessage({message: i18n.t('This element already exists'), messageType: 'error'});
        }
    }
});