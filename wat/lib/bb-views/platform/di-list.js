Wat.Views.DIListView = Wat.Views.ListView.extend({
    qvdObj: 'di',
    liveFields: ['percentage', 'elapsed_time'],
    relatedDoc: {
        image_update: "Images update guide"
    },
    
    initialize: function (params) {
        this.collection = new Wat.Collections.DIs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    renderList: function (params) {
        Wat.Views.ListView.prototype.renderList.apply(this, [params]);
        
        this.renderProgressBars();
    },
    
    renderProgressBars: function () {
        var that = this;
        
        $.each(that.collection.models, function (i, model) {
            var statusStr = '';
            
            switch(model.get('state')) {
                case 'new':
                case 'generating':
                    statusStr = 'Generating';
                    break;
                case 'uploading':
                    statusStr = 'Uploading';
                    break;
                default:
                    // Exit from loop iteration (Do not show progressBar)
                    return;
            }
            
            this.template = _.template(
                Wat.TPL.diProgressBar, {
                    id: model.get('id'),
                    state: model.get('state'),
                    percentage: model.get('percentage'),
                    remainingTime: model.get('remaining_time'),
                    elapsedTime: model.get('elapsed_time'),
                    statusStr: statusStr
                }
            );

            $('.bb-di-progress[data-id="' + model.get('id') + '"]').html(this.template);
        });
        
        var progressBars = $("." + this.cid + " .progressbar");

        $.each (progressBars, function (i, progressBar) {
            var progressLabel = $(progressBar).find('.progress-label');
            $(progressBar).progressbar({
                value: false,
                change: function (e) {
                    that.updateDiProgress(progressBar);
                },
                complete: function () {
                    var progressLabel = $(progressBar).find('.progress-label');
                    progressLabel.text($.i18n.t("Complete"));
                }
            });
        });
        
        that.intervals['localDiProgressTime'] = setInterval(function () {
            $.each(progressBars, function (i, progressBar) {
                var percent = parseInt($(progressBar).attr('data-percent'));
                var remainingTime = parseInt($(progressBar).attr('data-remaining'));
                var elapsedTime = parseInt($(progressBar).attr('data-elapsed'));

                if (percent >= 100) {
                    return;
                }

                $(progressBar).attr('data-remaining', remainingTime>0 ? remainingTime-1 : 0);
                $(progressBar).attr('data-elapsed', elapsedTime+1);

                that.updateDiProgress(progressBar);
            });
        }, 1000);
    },
    
    updateDiProgress: function (progressBar) {
        var progressRemaining = $(progressBar).parent().find('.progress-remaining');
        var progressElapsed = $(progressBar).parent().find('.progress-elapsed');
        var progressLabel = $(progressBar).find('.progress-label');
        
        var percent = $(progressBar).attr('data-percent');
        var remaining = $(progressBar).attr('data-remaining');
        var elapsed = $(progressBar).attr('data-elapsed');
        var statusStr = $(progressBar).attr('data-status-str');
        
        progressRemaining.html(Wat.U.secondsToHms(remaining));
        progressElapsed.html(Wat.U.secondsToHms(elapsed));
        var progressText = percent + "%";
        if (statusStr) {
            progressText = $.i18n.t(statusStr) + ': ' + progressText;
        }
        progressLabel.text(progressText);
        $(progressBar).progressbar("value", percent);
        $(progressBar).find('.ui-progressbar-value').css('width', percent + '%').show();
    },
    
    listEvents: {
        'change input[data-name="di_default"]': 'setDefault',
        'click .js-more-tags': 'showExtraTags',
        'change .js-selected-actions-select': 'applySelectedAction',
        'click .js-unshrink-btn': 'unshrinkRows',
        'click input.check_all[data-embedded-view="di"]': 'checkAll',
        'click input.check-it[data-embedded-view="di"]': 'checkOne',
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
    
    renderEmbeddedBlockList: function () {
        this.renderEmbeddedList();
    },
    
    renderEmbeddedList: function () {
        this.template = _.template(
            Wat.TPL.embedded_osf_di, {
                cid: this.cid,
                models: this.collection.models,
                selectedActions: Wat.C.purgeConfigData(Wat.I.selectedActions.di),
                osfId: $('.dis-subrow').attr('data-dis-row'),
                shrinkFactor: 3
            }
        );
        
        $('.dis-subrow .bb-list').html(this.template);
        
        this.renderProgressBars();
        
        Wat.T.translateAndShow();
        
        // Open websockets for live fields
        if (this.liveFields) {
            Wat.WS.openListWebsockets(this.qvdObj, this.collection, this.liveFields, this.cid);
        }
    },
    
    applySelectedAction: function (e) {
        // Apply action
        Wat.Views.ListView.prototype.applySelectedAction.apply(this, [e]);
        
        // Reset combo after apply action
        $(e.target).val('').trigger('chosen:updated');
    },
    
    // Show hidden rows on shrinked lists
    unshrinkRows: function () {
        $('tr.js-rows-unshrink-row').remove();
        $('tr.js-shrinked-row').show();
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
                
                realView.afterCreating();
                break;
            default:
                if (ws.readyState == WS_OPEN) {
                    ws.close();
                }   

                Wat.I.loadingUnblock();
                $(".ui-dialog-buttonset button:first-child").trigger('click');
                Wat.I.M.showMessage({message: i18n.t(ALL_STATUS[data.status]), messageType: 'error'});
        }
    },
});