Wat.Views.OSFDetailsView = Wat.Views.DetailsView.extend({  
    qvdObj: 'osf',
    liveFields: ['number_of_vms', 'number_of_dis'],

    initialize: function (params) {
        this.model = new Wat.Models.OSF(params);
        
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    render: function () {
        var that = this;
        
        Wat.Views.DetailsView.prototype.render.apply(this);
        
        // If OSF were created using DIG, retrieve OS info from DIG
        var osdID = this.model.get('osd_id');
        if (osdID) {
            Wat.DIG.fetchOSD(osdID, function (OSDmodel) {
                that.OSDmodel = OSDmodel;

                Wat.DIG.renderOSDetails(that.OSDmodel, {
                    shrinked: false,
                    editable: false,
                    container: ''
                });
            });
            
            that.renderDiProgress(osdID);
        }
        else {
            Wat.DIG.renderOSDetails();
            
            // If no OSD, remove dis log info from DOM
            // TODO: Call to di_list on API
            $('.js-dis-log').closest('tr').remove();
        }
    },
    
    renderDiProgress: function (osdID) {
        var that = this;
        
        var imageModel = new Wat.Models.Plugin({}, {osdId: osdID, pluginId: 'image'});

        imageModel.fetch({
            complete: function () {
                if (imageModel.get('error')) {
                    $('.bb-dis-log').html('<div class="center" data-i18n="Error retrieving software information"></div>');
                    Wat.T.translate();
                    return;
                }
                
                var template = _.template(
                            Wat.TPL.osfDiLogOsd, {
                                images: imageModel.attributes
                            }
                        );

                $('.bb-dis-log').html(template);

                var progressBars = $(".progressbar");

                $.each (progressBars, function (i, progressBar) {
                    var progressLabel = $(progressBar).find('.progress-label');

                    $(progressBar).progressbar({
                        value: false,
                        change: function () {
                            that.updateDiProgress(progressBar);
                        },
                        complete: function () {
                            var progressLabel = $(progressBar).find('.progress-label');
                            progressLabel.text("Complete!");
                        }
                    });
                });

                // TODO: Replace by websockets
                that.intervals['diProgressBars'] = setInterval(function () {
                    imageModel.fetch({
                        complete: function () {
                            $.each(imageModel.attributes, function (i, image) {
                                var progressBar = $('.js-images-log-list tr[data-id="' + image.id + '"] .progressbar');
                                var percent = image.percent;
                                var remainingTime = image.remainingTime;
                                var elapsedTime = image.elapsedTime;

                                $(progressBar).attr('data-percent', percent);
                                $(progressBar).attr('data-remaining', remainingTime);
                                $(progressBar).attr('data-elapsed', elapsedTime);

                                $(progressBar).progressbar("value", percent);
                            });
                        }
                    });
                }, 3000);

                that.intervals['localDiProgressTime'] = setInterval(function () {
                    $.each(imageModel.attributes, function (i, image) {
                        var progressBar = $('.js-images-log-list tr[data-id="' + image.id + '"] .progressbar');
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
            }
        });
    },
    
    updateDiProgress: function (progressBar) {
        var progressRemaining = $(progressBar).parent().find('.progress-remaining');
        var progressElapsed = $(progressBar).parent().find('.progress-elapsed');
        var progressLabel = $(progressBar).find('.progress-label');
        
        var percent = $(progressBar).attr('data-percent');
        var remaining = $(progressBar).attr('data-remaining');
        var elapsed = $(progressBar).attr('data-elapsed');

        progressRemaining.html(Wat.U.secondsToHms(remaining));
        progressElapsed.html(Wat.U.secondsToHms(elapsed));
        progressLabel.text(percent + "%");
    },
    
    renderSide: function () {
        var sideCheck = this.checkSide({
            'osf.see.vm-list': '.js-side-component1', 
            'osf.see.di-list': '.js-side-component2', 
            'osf.see.log': '.js-side-component3'
        });

        if (sideCheck === false) {
            return;
        }
        
        if (sideCheck['osf.see.di-list']) { 
            var sideContainer2 = '.' + this.cid + ' .bb-details-side1';

            // Render Disk images list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer2;
            params.forceListColumns = {disk_image: true};
            
            if (Wat.C.checkGroupACL('osfDiEmbeddedInfo')) {
                params.forceListColumns['info'] = true;
            }

            if (Wat.C.checkACL('osf.see.di-list-default-update')) {
                params.forceListColumns.default = true;
            }

            // Check ACLs to show or not info icons in DIs list
            params.forceInfoRestrictions = {};
            if (Wat.C.checkACL('osf.see.di-list-default')) {
                params.forceInfoRestrictions.default = true;
            }
            if (Wat.C.checkACL('osf.see.di-list-head')) {
                params.forceInfoRestrictions.head = true;
            }
            if (Wat.C.checkACL('osf.see.di-list-tags')) {
                params.forceInfoRestrictions.tags = true;
            }
            if (Wat.C.checkACL('osf.see.di-list-block')) {
                params.forceInfoRestrictions.block = true;
            }
            
            params.forceSelectedActions = {};
            params.block = 5;
            params.filters = {"osf_id": this.elementId};
            
            this.sideViews.push(new Wat.Views.DIListView(params));  
        }
        
        if (sideCheck['osf.see.vm-list']) { 
            var sideContainer1 = '.' + this.cid + ' .bb-details-side2';

            // Render Virtual Machines list on side
            var params = {};
            params.whatRender = 'list';
            params.listContainer = sideContainer1;
            params.forceListColumns = {name: true, tag: true};
            
            if (Wat.C.checkGroupACL('osfVmEmbeddedInfo')) {
                params.forceListColumns['info'] = true;
            }
                
            // Check ACLs to show or not info icons in OSFs list
            params.forceInfoRestrictions = {};
            if (Wat.C.checkACL('osf.see.vm-list-block')) {
                params.forceInfoRestrictions.block = true;
            }
            if (Wat.C.checkACL('osf.see.vm-list-expiration')) {
                params.forceInfoRestrictions.expiration = true;
            }
            if (Wat.C.checkACL('osf.see.vm-list-state')) {
                params.forceInfoRestrictions.state = true;
            }
            if (Wat.C.checkACL('osf.see.vm-list-user-state')) {
                params.forceInfoRestrictions.user_state = true;
            }
            
            params.forceSelectedActions = {};
            params.forceListActionButton = null;
            params.block = 5;
            params.filters = {"osf_id": this.elementId};
            this.sideViews.push(new Wat.Views.VMListView(params));
        }
        
        
        if (sideCheck['osf.see.log']) { 
            var sideContainer = '.' + this.cid + ' .bb-details-side3';

            // Render Related log list on side
            var params = this.getSideLogParams(sideContainer);

            this.sideViews.push(new Wat.Views.LogListView(params));
        
            this.renderLogGraph(params);
        }
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
    },
});