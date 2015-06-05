Wat.Views.MainView = Backbone.View.extend({
    el: '.bb-content',
    editorContainer: '.bb-editor',
    breadcrumbs: {},
    message: 'Unknown problem',
    // error/success/info
    messagetype: 'error',
    dialogConf: {},
    deleteProps: [],
    currentMenu: '', // platform-setup
    sideViews: [],
    templates: {},
    
    initialize: function () {
        _.bindAll(this, 'render');
        
        // Add common functions
        Wat.C.addCommonFunctions (this);
        Wat.B.bindCommonEvents();
        
        // Add to the view events the parent class of this view to avoid collisions with other views events
        this.events = this.restrictEventsScope(this.events);
        
        // Add the commonly used templates
        this.addCommonTemplates();

        var that = this;
        this.render = _.wrap(this.render, function(render) { 
            that.beforeRender(); 
            render(); 
            that.afterRender(); 
            return that; 
        }); 
    },
    
    addCommonTemplates: function () {
        var templates = {};
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    beforeRender: function () {
    },
    
    afterRender: function () {
    },
    
    events:  {
        'click .js-mobile-menu-hamburger': 'clickMenuMobile'
    },
    
    clickMenuMobile: function () {
        console.log(2);
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
    
    updateElement: function () {        
        var context = '.editor-container.' + this.cid;
        
        return Wat.I.validateForm(context);
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
});
