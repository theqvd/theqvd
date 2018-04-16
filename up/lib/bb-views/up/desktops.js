Up.Views.DesktopsView = Up.Views.ListView.extend({  
    qvdObj: 'desktops',
    viewMode: 'grid',
    liveFields: ['state'],
    connectionTimeouts: [],
    
    relatedDoc: {
        image_update: "Images update guide",
        full_vm_creation: "Create a virtual machine from scratch",
    },
    
    initialize: function (params) {
        this.collection = new Up.Collections.Desktops(params)
        this.wsCollection = new Up.Collections.Workspaces();
        
        // Bind events for this section that cannot be binded using backbone (dialogs, etc.)
        Up.B.bindSettingsEvents();
        
        // Spy mouse over elements to avoid fails with mouseleave events
        Up.I.L.spyMouseOver('.js-grid-cell-area', this.hideGridIcon);
        
        Up.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {
        'click .js-desktop-settings-btn': 'editDesktopSettings',
        'click .js-unblocked .js-desktop-connect-btn': 'connectDesktop',
        'change select[name="active_configuration_select"]': 'activeWorkspaceFromDesktops',
        'mouseover .js-unblocked .js-grid-cell-area': 'showGridIcon',
        'mouseout .js-grid-cell-area': 'hideGridIcon'
    },
    
    addListTemplates: function () {
        Up.Views.ListView.prototype.addListTemplates.apply(this, []);
        
        var templates = Up.I.T.getTemplateList('desktops');
        this.templates = $.extend({}, this.templates, templates); 
    },
    
    showGridIcon: function (e) {
        var desktopId = $(e.target).attr('data-id');
        var desktopState = $('.js-grid-cell[data-id="' + desktopId + '"]').attr('data-state');
        
        switch(desktopState) {
            case 'connected':
                var action = 'reconnect';
                break;
            case 'connecting':
            case 'reconnecting':
                // In case of desktops in process of connection doesnt show any icon
                return;
                break;
            default:
                var action = 'connect';
                break;
        }
        
        // Hide all possible shown icons and show hovered one
        $('.js-grid-cell-icon.js-grid-cell-hiddeable').hide();
        $('.js-grid-cell-icon.js-grid-cell-hiddeable[data-id="' + desktopId + '"][data-action="' + action + '"]').show();
        
        // Switch hover class to screenshot layers too
        $('.js-grid-cell[data-state="connected"] .js-vm-screenshot, .js-gird-cell[data-state="disconnected"] .js-vm-screenshot').removeClass('vm-screenshot--hover');
        $('.js-vm-screenshot[data-id="' + desktopId + '"]').addClass('vm-screenshot--hover');
    },
    
    hideGridIcon: function (e) {
        var desktopId = $(e.target).attr('data-id');
        var desktopState = $('.js-grid-cell[data-id="' + desktopId + '"]').attr('data-state');
        
        switch(desktopState) {
            case 'connecting':
            case 'reconnecting':
                // In case of desktops in process of connection doesnt hide any icon
                break;
                return;
        }
        
        $('.js-grid-cell-icon.js-grid-cell-hiddeable[data-id="' + desktopId + '"]').hide();
        $('.js-vm-screenshot[data-id="' + desktopId + '"]').removeClass('vm-screenshot--hover');
    },
    
    // Extend renderListBlock to fill active configuration select
    renderListBlock: function (params) {
        var that = this;
        
        // Load Workspaces on select control
        this.wsCollection.fetch({
            complete: function () {
                Up.Views.ListView.prototype.renderListBlock.apply(that, []);
                
                var template = _.template(
                    Up.TPL.workspacesSelectOption, {
                        collection: that.wsCollection,
                        viewMode: that.viewMode
                    }
                );
                
                $('.bb-workspaces-select').html(template);
                
                Up.I.Chosen.element('select[name="active_configuration_select"]', 'single');
                Up.T.translate();
            }
        });
    },
    
    // Render only the list. Usefull to functions such as pagination, sorting and filtering where is not necessary render controls
    renderList: function (that) {
        var that = that || this;
        
        // Fill the list
        var template = _.template(
            Up.TPL['list-' + that.viewMode + '_' + that.qvdObj], {
                models: that.collection.models,
                checkBox: false
            }
        );
        
        $(that.listContainer).html(template);
        
        // Update status
        Up.CurrentView.setAllDesktopsState(that.collection.models);
        
        that.paginationUpdate();
        that.shownElementsLabelUpdate();
        
        Up.T.translateAndShow();
        
        Up.I.addOddEvenRowClass(that.listContainer);
    },
    
    afterRender: function () {
        Up.Views.ListView.prototype.afterRender.apply(this, []);        
        Up.WS.openWebsocket('desktops', Up.WS.changeWebsocketDesktops);
    },
    
    setAllDesktopsState: function (models) {
        var that = this;
        $.each(models, function (iModel, model) {
            that.setDesktopState(model.get('id'), model.get('state'));
        });
    },
    
    setVMState: function (id, newVMState) {
        // Store on model
        
        var desktopModel = Up.CurrentView.collection.findWhere({id: parseInt(id)});
        desktopModel.set('vm_state', newVMState);
    },
    
    setDesktopState: function (id, newState) {
        // If newState is stable, store on model.
        switch (newState) {
            case 'connected':
            case 'disconnected':
                var desktopModel = Up.CurrentView.collection.findWhere({id: parseInt(id)});
                desktopModel.set('lastStableState', newState);
                break;
        }
        
        var cellDiv = $('.js-grid-cell[data-id="' + id + '"]');
        
        $(cellDiv).removeClass('grid-disconnected js-grid-disconnected grid-connected js-grid-connected grid-connecting js-grid-connecting grid-reconnecting js-grid-reconnecting');
        var currentState = $(cellDiv).attr('data-state');

        // When try to connect to connected desktop, establish "fake ui state" reconnecting 
        if (newState == 'connecting' && (currentState == 'connected' || currentState == 'reconnecting')) {
            newState = 'reconnecting';
        }
        
        var actionAttr = '';
        switch(newState) {
            case 'connecting':
                var actionAttr = '[data-action="connect"]';
                break;
            case 'reconnecting':
                var actionAttr = '[data-action="reconnect"]';
                break;
        }
        
        // Grid view
        if (Up.I.isMobile()) {
            var iconDivMobile = $('.js-desktop-connect-btn.mobile[data-id="' + id + '"]');
        }
        else {
            var iconDiv = $('.js-grid-cell-icon[data-id="' + id + '"]' + actionAttr);
            var screenshotDiv = $('.js-vm-screenshot[data-id="' + id + '"]');
            var areaDiv = $('.js-unblocked .js-grid-cell-area[data-id="' + id + '"]');
        }
        var stateDiv = $('.js-desktop-state[data-id="' + id + '"]');
        
        
        // Update DOM new state
        $(cellDiv).attr('data-state', newState);
        
        // Change Interface with style and animations
        switch(newState) {
            case 'connected':
            case 'disconnected':
                if (Up.I.isMobile()) {
                    $(iconDivMobile).removeClass('animated faa-flash');
                }
                else {
                    $(iconDiv).addClass('js-grid-cell-hiddeable').removeClass('animated faa-flash').hide();
                    $(screenshotDiv).removeClass('vm-screenshot--hover');
                }
                $(stateDiv).removeClass('animated faa-flash');
                
                if (!Up.I.isMobile()) {
                    // Screenshot div toggle
                    $('.js-vm-screenshot[data-id="' + id + '"]').hide();
                    $('.js-vm-screenshot[data-id="' + id + '"][data-state="' + newState + '"]').show();
                }
                break;
            case 'connecting':
            case 'reconnecting':
                if (Up.I.isMobile()) {
                    $(iconDivMobile).addClass('animated faa-flash');
                }
                else {
                    $(iconDiv).removeClass('js-grid-cell-hiddeable').addClass('animated faa-flash').show();
                    $(screenshotDiv).addClass('vm-screenshot--hover');
                }
                $(stateDiv).addClass('animated faa-flash');
                break;
        }
        
        if (!Up.I.isMobile()) {
            var areaTitle = Up.I.getDesktopTitleString(newState, false);
            if (areaTitle) {
                $(areaDiv).attr('data-i18n', '[title]' + Up.I.getDesktopTitleString(newState, false));
            }
            else {
                $(areaDiv).removeAttr('title');
            }
            
            Up.T.translate();
        }

        $(cellDiv).addClass('grid-' + newState + ' js-grid-' + newState);
        $(stateDiv).attr('data-i18n', Up.I.getStateString(newState)).html($.i18n.t(Up.I.getStateString(newState)));
        
        // Store new state in model
        var model = Up.CurrentView.collection.where({id: parseInt(id)})[0];
        model.set('state', newState);
    },
    
    startConnectionTimeoutClassic: function (id) {
        var that = this;
        
        that.connectionTimeouts[id] = {};
        
        that.connectionTimeouts[id].count = 0;
        that.connectionTimeouts[id].timeout = setInterval(function () {
            // If desktop has connected status, break timeout countdown
            if ($('.js-grid-cell[data-id="' + id + '"]').attr('data-state') == 'connected') {
                clearInterval(that.connectionTimeouts[id].timeout);
                return;
            };
            
            // Increase counter
            that.connectionTimeouts[id].count++;
            
            // If counter reach timeout set disconnected status and breack timeout countdown
            if (that.connectionTimeouts[id].count >= CONNECTION_TIMEOUT) {
                that.setDesktopState(id, 'disconnected');
                that.connectDesktopFail();
                clearInterval(that.connectionTimeouts[id].timeout);
                
                delete(that.connectionTimeouts[id]);
                return;
            }
        }, 1000);
    },
    
    startConnectionTimeoutHTML5: function (id) {
        var that = this;
        
        // Wait some time for cookie connection creation
        setTimeout(function () {
            // Check one time per second if connection cookie exists
            var interval = setInterval(function () {
                // When connection cookie being deleted, restore last stable state
                if (!$.cookie('connectingDesktop-' + id)) {
                    var desktopModel = Up.CurrentView.collection.findWhere({id: parseInt(id)});
                    if (desktopModel) {
                        that.setDesktopState(id, desktopModel.get('lastStableState'));
                    }

                    clearInterval(interval);
                }
            }, 1000);
        }, 3000);
    },
    
    activeWorkspaceFromDesktops: function (e) {
        var selectedId = parseInt($(e.target).val());
        var model = Up.CurrentView.wsCollection.findWhere({id: selectedId});
        
        this.activeWorkspace(model, function () {});
    }
});
