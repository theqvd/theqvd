Wat.Views.DetailsView = Wat.Views.MainView.extend({
    elementId: 0,
    detailsContainer: '.bb-details',
    sideContainer: '.bb-details-side',
    
    viewKind: 'details',
    
    /*
    ** params:
    **  id (numeric): Id of the element which details will be shown
    */
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this);

        this.elementId = params.id;
        
        this.setBreadCrumbs();
        this.setViewACL();
        this.setDetailsFields();
        
        // Extend the common events
        this.extendEvents(this.eventsDetails);
                
        var templates = {
            detailsCommon: {
                name: 'details-common'
            },
            detailsCommonProperties: {
                name: 'details-common-properties'
            },
            details: {
                name: 'details-' + this.qvdObj
            },
            detailsSide: {
                name: 'details-' + this.qvdObj + '-side'
            },
            warn404: {
                name: '404'
            },
            warn404: {
                name: '404'
            },
            editor: {
                name: 'editor-' + this.qvdObj
            }
        }
        
        Wat.A.getTemplates(templates, this.fetchDetails, this); 
    },
    
    setBreadCrumbs: function () {
        this.breadcrumbs = Wat.I.getDetailsBreadCrumbs(this.qvdObj);
    }, 
    
    setViewACL: function () {
        this.viewACL = this.qvdObj + '.see-details.';
    },
    
    afterRender: function () {
        // If this view have Side component, render it after render
        if (this.renderSide) {
            this.renderSide();
        }
    },
    
    fetchDetails: function (that) {
        var that = that || this;
        that.model.fetch({      
            complete: function () {
                that.render();
            }
        });
    },
    
    eventsDetails: {
        'click .js-button-edit': 'openEditElementDialog',
        'click .js-button-unblock': 'applyUnblock' ,
        'click .js-button-block': 'applyBlock', 
        'click .js-button-delete': 'askDelete',
        'click .js-button-default': 'applyDefault',
        'click .js-button-start-vm': 'startVM',
        'click .js-button-stop-vm': 'stopVM',
        'click .js-button-disconnect-all-vms': 'applyDisconnectAll'
    },

    render: function () {
        // If user have not access to main section, redirect to home
        if (!Wat.C.checkACL(this.viewACL)) {
            window.location = '#';
            return;
        }
        
        // If only id is stored in model means that it wasnt found
        if (this.notFound == undefined) {
            this.notFound = Object.keys(this.model.attributes).length <= 1;
        }
        
        // If screen attribute of last breadcrumb is not defined, element wasnt found
        var lastScreen = undefined;
        var nextBread = this.breadcrumbs.next;
        while (1) {
            if (!nextBread.next) {
                lastScreen = !nextBread.screen ? undefined : nextBread.screen;
                break;
            }
            
            nextBread = nextBread.next;
        }
        
        if (this.qvdObj != 'log' && this.qvdObj != 'di' && this.qvdObj != 'configwat') {
            // Add name of the model to breadcrumbs if not exist
            nextBread.screen = this.model.get('name');
        }
        
        if (this.notFound) {
            this.template = _.template(
                Wat.TPL.warn404, {
                }
            );

            $(this.el).html(this.template);
            
            nextBread.screen = '-';
            this.printBreadcrumbs(this.breadcrumbs, '');
            //delete nextBread.screen;
        }
        else { 
            var enabledProperties = $.inArray(this.qvdObj, QVD_OBJS_WITH_PROPERTIES) != -1 && Wat.C.checkACL(this.qvdObj + '.see.properties');
            
            // Fill the html with the template and the model
            this.template = _.template(
                Wat.TPL.detailsCommon, {
                    model: this.model,
                    enabledProperties: enabledProperties,
                    cid: this.cid
                }
            );

            $(this.el).html(this.template);
        
            this.printBreadcrumbs(this.breadcrumbs, '');

            this.template = _.template(
                Wat.TPL.details, {
                    model: this.model,
                    detailsFields: this.detailsFields,
                    enabledProperties: enabledProperties
                }
            );

            $(this.detailsContainer).html(this.template);
        
            this.template = _.template(
                Wat.TPL.detailsSide, {
                    model: this.model,
                    qvdObj: this.qvdObj
                }
            );

            $(this.sideContainer).html(this.template);
            
            if (enabledProperties) {
                // Fill the html with the template and the model
                this.template = _.template(
                    Wat.TPL.detailsCommonProperties, {
                        properties: this.model.get('properties'),
                    }
                );

                $('.bb-properties').html(this.template);
            }
        }

        this.renderRelatedDocs();
        
        Wat.T.translate();
        
        // Open websockets for live fields
        if (this.liveFields) {
            Wat.WS.openDetailsWebsockets(this.qvdObj, this.model, this.liveFields, this.cid);
        }
    },
    
    applyBlock: function () {
        this.updateModel({blocked: 1}, {id: this.elementId}, this.fetchDetails);
    },   
    
    applyUnblock: function () {
        this.updateModel({blocked: 0}, {id: this.elementId}, this.fetchDetails);
    },  
    
    askDelete: function () {
        Wat.I.confirm('dialog-confirm-undone', this.applyDelete, this);
    },
        
    applyDelete: function (that) {
        that.deleteModel({id: that.elementId}, that.afterDelete, that.model);
    },
    
    afterDelete: function (that) {
        //Find the last link to rederect to it after deletion
        var lastLink = '';
        var crumb = that.breadcrumbs;
        while (1) {
            if (crumb.next != undefined) {
                if (crumb.link != undefined) {
                    lastLink = crumb.link;
                }
                crumb = crumb.next;
            }
            else {
                break;
            }
        }
        
        window.location = lastLink;
    },
    
    setDetailsFields: function () {
        // Get Fields from configuration
        this.detailsFields = Wat.I.getDetailsFields(this.qvdObj);
        
        // Check acls on fields to remove forbidden ones
        Wat.C.purgeConfigData(this.detailsFields);

        // The superadmin have an extra field on lists: tenant
        
        // Every element but the hosts has tenant
        if (Wat.C.isSuperadmin() && this.qvdObj != 'host') {
            this.detailsFields.tenant = {
                'text': 'Tenant',
                'display': true,
                'noTranslatable': true
            };
        }
    },
    
    // Check some acls to show or not the side of a details view
    // If no acl pass, return false, otherwise return an object with acls and true or false if pass or not
    checkSide: function (acls) {
        var nAcls = acls.length;
        var pass = 0;
        var result = {};
        
        $.each(acls, function (acl, layer) {
            if (Wat.C.checkACL(acl)) {
                pass++;
                result[acl] = true;
            }
            else {
                result[acl] = false;
                $(layer).hide();
            }
        });
        
        if (!pass) {
            $('.js-details-side').hide();
            $('.js-details-block').addClass('col-width-100');
            return false;
        }
        //$('.js-details-side').show();
        //$('.js-details-block').removeClass('col-width-100');
        return result;
    },
    
    // Return the params to render a embeded side list with object log registers
    getSideLogParams: function (sideContainer) {
        var params = {};
        params.whatRender = 'list';
        params.listContainer = sideContainer;
        params.forceListColumns = {
            see_details: true, 
            action: true, 
            datetime: true
        };

        params.forceSelectedActions = {};
        params.block = 5;
        params.filters = {
            qvd_object: this.qvdObj, 
            object_id: this.elementId
        };
        
        return params;
    },
});
