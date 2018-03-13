Wat.Views.MainView = Backbone.View.extend({
    el: '.bb-content',
    editorContainer: '.bb-editor',
    editorPropertiesContainer: '.bb-custom-properties',
    breadcrumbs: {},
    message: 'Unknown problem',
    // error/success/info
    messagetype: 'error',
    dialogConf: {},
    deleteProps: [],
    deleteACLs: [],
    addACLs: [],
    deleteRoles: [],
    addRoles: [],
    currentMenu: '', // platform-setup
    sideViews: [],
    embeddedViews: {},
    templates: {},
    intervals: {},
    
    initialize: function () {
        _.bindAll(this, 'render');
        
        // Add common functions
        Wat.C.addCommonFunctions (this);
        
        // Add to the view events the parent class of this view to avoid collisions with other views events
        this.events = this.restrictEventsScope(this.events);
        
        // Add the commonly used templates
        this.addCommonTemplates();
        
        // Reset sideViews
        this.sideViews = [];
        
        var that = this;
        this.render = _.wrap(this.render, function(render) { 
            that.beforeRender(); 
            render(); 
            that.afterRender(); 
            return that; 
        }); 

		// If any message os sent from last refresh, show it and delete cookie
        if ($.cookie('messageToShow')) {
            var tInt = setInterval(function() {
                if (Wat.T.loaded) {
            Wat.I.M.showMessage(JSON.parse($.cookie('messageToShow')));
            $.removeCookie('messageToShow', {path: '/'});
                    clearInterval(tInt);
                }
                else {
                    console.log('not loaded');
                }
            }, 100);
        }
        
        $('.js-super-wrapper').removeClass('super-wrapper--login');
        $('body').css('background','');
    },
    
    addCommonTemplates: function () {
        var editorTemplates = Wat.I.T.getTemplateList('commonEditors', {qvdObj: this.qvdObj});
        var conflictTemplates = Wat.I.T.getTemplateList('conflict');
        
        this.templates = $.extend({}, this.templates, editorTemplates, conflictTemplates);
    },
    
    beforeRender: function () {
            // Close submenus for touch devices compatibility
            $('.js-menu-corner li ul').hide();
    },
    
    afterRender: function () {
        var htmlString ="<html><body ><label>INPUT TYPE</label></body></html>";
        var doc = new jsPDF('landscape','pt');
        var specialElementHandlers = {
          '#editor': function( element, renderer ) {
              return true;
            }
        };
    },
    
    events:  {
        'input .filter-control>input': 'filterBySubstring',
        'click .js-next-tab': 'nextTab'
    },
    
    filterBySubstring: function(e) {
        // Store typed search to mantain the order in filter task avoiding 
        // filtering if current typed search doesnt match with stored one
        Wat.CurrentView.typedSearch = $(e.target).val();
        
        this.filter(e);
    },
    
    extendEvents: function (ev) {
        if (ev == undefined) {
            return;
        }
        ev = this.restrictEventsScope(ev);
        this.events = _.extend(this.events, ev);
    },
  
    restrictEventsScope: function (events) {
        var that = this;
        var newEvents = {};
        $.each(events, function(key, value) {
            var newKey = key.replace(' ', ' .' + that.cid + ' ');
            newEvents[newKey] = value;
        });
        return newEvents;
    },
    
    printBreadcrumbs: function (bc, bcHTML) {
        // If no bradcrumbs are given, do nothing
        if ($.isEmptyObject(bc)) {
            return;
        }
        
        if (bc.link != undefined) {
            bcHTML += '<a href="' + bc.link + '" data-i18n="' + bc.screen + '"></a>';
        }
        else {
            bcHTML += '<span data-i18n="' + bc.screen + '">' + bc.screen + '</span>';
        }
        if (bc.next != undefined) {
            bcHTML += ' <i class="fa fa-angle-double-right"></i> ';
            this.printBreadcrumbs (bc.next, bcHTML);
        }
        else {
            bcHTML += '<a href="javascript:" class="fa fa-book js-screen-help screen-help" data-i18n="[title]Related documentation" data-docsection="' + this.qvdObj + '"></a>'
            $('#breadcrumbs').html(bcHTML);
        }
    },
    
    createModel: function (arguments, successCallback) {
        this.model.setOperation('create');
        
        var messages = {
            'success': 'Successfully created',
            'error': 'Error creating'
        };
        
        this.saveModel(arguments, {}, messages, successCallback);
    },
    
    updateModel: function (arguments, filters, successCallback, model) {
        // If not model is passed, use this.model
        var model = model || this.model;
        
        // If we are updating an element from list view, reset selected items
        if (this.viewKind == 'list') {
            this.resetSelectedItems();
        }
        
        model.setOperation('update');
        
        var messages = {
            'success': 'Successfully updated',
            'error': 'Error updating'
        };
        
        this.saveModel(arguments, filters, messages, successCallback, model);
    },
    
    deleteModel: function (filters, successCallback, model) {
        // If not model is passed, use this.model
        var model = model || this.model;
        
        model.setOperation('delete');
        
        var messages = {
            'success': 'Successfully deleted',
            'error': 'Error deleting'
        };
        
        this.saveModel({}, filters, messages, successCallback, model);
    },
    
    saveModel: function (arguments, filters, messages, successCallback, model) {
        var model = model || this.model;
        
        var that = this;
        model.save(arguments, {filters: filters}).complete(function(e, a, b) {
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

            if (callResponse == 200 && response.status == STATUS_SUCCESS) {
                that.message = messages.success;
                that.messageType = 'success';
            }
            else {
                that.message = messages.error;
                that.messageType = 'error';
            }

            if (that.dialog && that.dialog.hasClass("ui-dialog-content")) {
                Wat.I.closeDialog(that.dialog);
            }
                        
            var messageParams = {
                message: that.message,
                messageType: that.messageType
            };
            
            that.retrievedData = response;
            successCallback(that);
            
            var intercepted = false;
            
            if (messageParams.messageType == 'error') {
                intercepted = Wat.A.interceptSavingModelResponse(model.operation, response);
            }
            
            if (!intercepted) {
                Wat.I.M.showMessage(messageParams, response);
            }
        });
    },
    
    // Open dialog to resolve dependency problems
    openDependenciesDialog: function (dependencyIds, qvdObj) {
        var that = this;
        
        // Retrieve names
        var dependencyElements = {};
        
        if (this.collection) {
            $.each(dependencyIds, function (i, id) {
                var model = that.collection.where({id: parseInt(id)})[0];
                dependencyElements[id] = model.get('name');
            });
        }
        else if (that.model && dependencyIds.length == 1) {
            dependencyElements[dependencyIds[0]] = that.model.get('name');
        }
        
        var dialogConf = {
            title: $.i18n.t('Action not accomplished for all elements'),
            buttons : {
                "Cancel": function () {
                    Wat.I.closeDialog($(this));
                },
                "Enforce deletion for all": function () {
                    var allIds = $('.js-elements-list').attr('data-all-ids').split(',');
                    var qvdObj = $('.js-elements-list').attr('data-qvd-obj');
                                
                    // Mark all buttons pending to be deleted
                    $('.js-button-force-delete').attr('data-deleteme', '1');
                    
                    Wat.A.deletePending('.js-button-force-delete');
                }
            },
            buttonClasses : ['fa fa-ban js-button-cancel', 'fa fa-bomb js-button-force-delete-all'],
            fillCallback : function(target) { 
                that.template = _.template(
                    Wat.TPL.deleteDependency, {
                        dependencyElements: dependencyElements,
                        qvdObj: qvdObj
                    }
                );

                target.html(that.template);
            }
        }
        
        this.dependencyDialog = Wat.I.dialog(dialogConf);
    },
    
    // Open element for creation forms
    openNewElementDialog: function (e) {
        var that = this;
        // Avoid open dialogs relative to another qvd objets in screens with embedded views
        if (e && $(e.target).attr('data-qvd-obj') != this.qvdObj) {
            return;
        }
        
        this.dialogConf.buttons = {
            Cancel: function (e) {
                Wat.I.closeDialog($(this));
                
                Wat.CurrentView.editorView.afterNewElementDialogAction('cancel');
            },
            Create: function (e) {
                var valid = Wat.CurrentView.editorView.validateForm();

                if (!valid) {
                    return;
                }
                
                if (Wat.I.isDialogButtonDisabled('create')) {
                    return;
                }
                
                that.dialog = $(this);
                Wat.CurrentView.editorView.createElement($(this));
                
                Wat.CurrentView.editorView.afterNewElementDialogAction('create');
                
                Wat.I.closeDialog($(this));
            }
        };

        this.dialogConf.buttonClasses = [
            'fa fa-ban js-button-cancel', 
            'fa fa-plus-circle js-button-create'
        ];
        
        this.dialogConf.fillCallback = function (target, that) {
            var editorViewClass = Wat.Common.BySection[that.qvdObj] ? Wat.Common.BySection[that.qvdObj].editorViewClass : Wat.CurrentView.editorViewClass;
            Wat.CurrentView.editorView = new editorViewClass({ action: 'create', el: $(target), parentView: Wat.U.getViewFromQvdObj(that.qvdObj) });
        };
        
        this.dialog = Wat.I.dialog(this.dialogConf, this);
    },
    
    // Switch editor form to next tab
    nextTab: function () {
        var activeTab = -1;
        $.each($('.js-editor-tabs>li'), function (iTab, tab) {
            if (activeTab > -1 && iTab == (activeTab+1)) {
                $(tab).trigger('click');
                return;
            }

            if ($(tab).hasClass('tab-active')) {
                activeTab = iTab;
            }
        });
    },
    
    openEditElementDialog: function (e) {
        var that = this;
        
        this.dialogConf.buttons = {
            Cancel: function (e) {
                Wat.I.closeDialog($(this));
                
                that.afterEditElementDialogAction('cancel');
                
                // If we are updating an element from list view, reset selected items
                if (that.viewKind == 'list') {
                    that.resetSelectedItems();
                }
            },
            Update: function (e) {
                var valid = Wat.CurrentView.editorView.validateForm();
                
                if (!valid) {
                    return;
                }

                
                if (Wat.I.isDialogButtonDisabled('update')) {
                    return;
                }
                
                that.dialog = $(this);
                Wat.CurrentView.editorView.updateElement(that.dialog, that);
                
                Wat.CurrentView.editorView.afterEditElementDialogAction('update');
            }
        };

        this.dialogConf.buttonClasses = ['fa fa-ban js-button-cancel', 'fa fa-save js-button-update'];
        
        this.dialogConf.fillCallback = function (target, that) {
            var editorViewClass = Wat.Common.BySection[that.qvdObj] ? Wat.Common.BySection[that.qvdObj].editorViewClass : Wat.CurrentView.editorViewClass;
            Wat.CurrentView.editorView = new editorViewClass({ action: 'update', el: $(target), parentView: that });
        };
        
        Wat.I.dialog(this.dialogConf, this);
    },
    
    stopVM: function (filters, messages) {
        var messages = messages || {
            'success': 'Stop request successfully performed',
            'error': 'Error stopping Virtual machine'
        };
        
        Wat.A.performAction ('vm_stop', {}, filters, messages, function(){}, this);
    },
    
    disconnectVMUser: function (filters, messages) {        
        var messages = messages || {
            'success': 'User successfully disconnected from VM',
            'error': 'Error disconnecting user from Virtual machine'
        };
        
        Wat.A.performAction ('vm_user_disconnect', {}, filters, messages, this.fetchList, this);
    },
    
    openRelatedDocsDialog: function () {
        var that = this;
        
        var dialogConf = {};

        dialogConf.title = $.i18n.t("Related documentation");

        dialogConf.buttons = {
            "Read full documentation": function (e) {
                $('.js-button-close').trigger('click');
                window.location = '#documentation';
            },
            Close: function (e) {
                Wat.I.closeDialog($(this));
            }
        };

        dialogConf.buttonClasses = ['fa fa-book js-button-read-full-doc', 'fa fa-check js-button-close'];

        dialogConf.fillCallback = function (target, that) {
            // Back scroll of the div to top position
            target.html('');
            $('.js-dialog-container').animate({scrollTop:0});

            var sectionDoc = [];
            sectionDoc[this.qvdObj] = "This section step by step";
            this.relatedDoc = $.extend({}, sectionDoc, that.relatedDoc);
            
            if (this.relatedDoc) {
                var that = this;

                that.template = _.template(
                        Wat.TPL.relatedDoc, {
                            relatedDoc: that.relatedDoc,
                        }
                    );

                target.html(that.template);
            }
        };


        Wat.I.dialog(dialogConf, this);          
    },
    
    // Fetch details or list depending on the current view kind
    fetchAny: function (that) {
        that = that || this;
        
        switch (that.viewKind) {
            case 'list':
                that.fetchList();
                break;
            case 'details':
                that.fetchDetails();
                break;
        }
    },
    
    // Hooks after click a button on dialog
    afterNewElementDialogAction: function (action) {},
    afterEditElementDialogAction: function (action) {},
    
    // Override view remove method to do not destroy $el from DOM. Only empty it.
    remove: function() {
        this.$el.empty();
        this.undelegateEvents();
    }
});
