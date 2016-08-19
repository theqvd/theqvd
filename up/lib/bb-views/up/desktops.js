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
        Up.B.bindDesktopsEvents();
        
        // Spy mouse over elements to avoid fails with mouseleave events
        Up.I.L.spyMouseOver('.js-grid-cell-area', this.hideGridIcon);
        
        Up.Views.ListView.prototype.initialize.apply(this, [params]);        
    },
    
    // This events will be added to view events
    listEvents: {
        'click .js-change-viewmode': 'changeViewMode',
        'click .js-desktop-settings-btn': 'editDesktopSettings',
        'click .js-desktop-connect-btn': 'connectDesktop',
        'change select[name="active_configuration_select"]': 'changeActiveConf',
        'mouseover .js-grid-cell-area': 'showGridIcon',
        'mouseout .js-grid-cell-area': 'hideGridIcon'
    },
    
    addListTemplates: function () {
        Up.Views.ListView.prototype.addListTemplates.apply(this, []);
        
        var templates = Up.I.T.getTemplateList('desktops');
        this.templates = $.extend({}, this.templates, templates); 
    },
    
    showGridIcon: function (e) {
        $('.js-grid-cell-icon.js-grid-cell-hiddeable[data-id="' + $(e.target).attr('data-id') + '"]').show();
    },  
    
    hideGridIcon: function (e) {
        $('.js-grid-cell-icon.js-grid-cell-hiddeable[data-id="' + $(e.target).attr('data-id') + '"]').hide();
    },
    
    // Extend renderListBlock to fill active configuration select
    renderListBlock: function (params) {  
        Up.Views.ListView.prototype.renderListBlock.apply(this, []);
        
        // Load Workspaces on select control
        var that = this;
        
        this.wsCollection.fetch({      
            complete: function () {
                
                var template = _.template(
                    Up.TPL.workspacesSelectOption, {
                        collection: that.wsCollection,
                        viewMode: that.viewMode
                    }
                );
                
                $('.bb-workspaces-select').html(template);
                
                Up.I.chosenElement('select[name="active_configuration_select"]', 'single');
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
                
        Up.I.addSortIcons(that.cid);
                
        Up.I.addOddEvenRowClass(that.listContainer);
    },
    
    afterRender: function () {
        Up.Views.ListView.prototype.afterRender.apply(this, []);        
        Up.WS.openWebsocket('desktops', Up.WS.changeWebsocketDesktops);
    },
    
    // Change view mode when click on the view mode button and render list
    changeViewMode: function (e) {
        this.viewMode = $(e.target).attr('data-viewmode');
        $('.js-change-viewmode').removeClass('disabled');
        $(e.target).addClass('disabled');
        
        this.renderList();
    },
    
    changeActiveConf: function (e) {
        var selectedId = $('select[name="active_configuration_select"]').val();
        
        var model = Up.CurrentView.wsCollection.where({id: parseInt(selectedId)})[0];
        
        var settings = model.get('settings');
        
        if (!settings) {            
            Up.CurrentView.firstEditWorkspace(model);
        }
        else {
            Up.CurrentView.activeWorkspace(e, model, function() {});
        }
    },
    
    setAllDesktopsState: function (models) {
        var that = this;
        $.each(models, function (iModel, model) {
            that.setDesktopState(model.get('id'), model.get('state'));
        });
    },
    
    setDesktopState: function (id, newState) {
        // Grid view
        if (Up.I.isMobile()) {
            var iconDivMobile = $('.js-desktop-connect-btn.mobile[data-id="' + id + '"]');
        }
        else {
            var iconDiv = $('.js-grid-cell-icon[data-id="' + id + '"]');
        }
        var stateDiv = $('.js-desktop-state[data-id="' + id + '"]');
        
        var cellDiv = $('.js-grid-cell[data-id="' + id + '"]');
        var cellCurrentState = $(cellDiv).attr('data-state');
        $(cellDiv).removeClass('grid-disconnected js-grid-disconnected grid-connected js-grid-connected grid-connecting js-grid-connecting grid-reconnecting js-grid-reconnecting');

        // List view
        var cellRow = $('.js-row-desktop[data-id="' + id + '"]');
        var rowCurrentState = $(cellRow).attr('data-state');
        $(cellRow).removeClass('row-disconnected js-row-disconnected row-connected js-row-connected row-connecting js-row-connecting row-reconnecting js-row-reconnecting');
        
        // Depending on the current view, state will be retrieved from one or another
        var currentState = cellCurrentState || rowCurrentState;
        
        // When try to connect to connected desktop, establish "fake ui state" reconnecting 
        if (newState == 'connecting' && (currentState == 'connected' || currentState == 'reconnecting')) {
            newState = 'reconnecting';
        }
        
        // Update DOM new state
        $(cellDiv).attr('data-state', newState);
        $(cellRow).attr('data-state', newState);
        
        // Change Interfce with style and animations
        switch(newState) {
            case 'connected':
            case 'disconnected':
                if (Up.I.isMobile()) {
                    $(iconDivMobile).removeClass('animated faa-flash');
                }
                else {
                    $(iconDiv).addClass('js-grid-cell-hiddeable').removeClass('animated faa-flash').hide();
                }
                $(stateDiv).removeClass('animated faa-flash');
                break;
            case 'connecting':
            case 'reconnecting':
                if (Up.I.isMobile()) {
                    $(iconDivMobile).addClass('animated faa-flash');
                }
                else {
                    $(iconDiv).removeClass('js-grid-cell-hiddeable').addClass('animated faa-flash').show();
                }
                $(stateDiv).addClass('animated faa-flash');
                break;
        }
        
        $(cellRow).addClass('row-' + newState + ' js-row-' + newState);
        $(cellDiv).addClass('grid-' + newState + ' js-grid-' + newState);
        $(stateDiv).attr('data-i18n', Up.I.getStateString(newState)).html($.i18n.t(Up.I.getStateString(newState)));
        
        // Store new state in model
        var model = Up.CurrentView.collection.where({id: parseInt(id)})[0];
        model.set('state', newState);
    },
    
    startConnectionTimeout: function (id) {
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
                clearInterval(that.connectionTimeouts[id].timeout);
                
                delete(that.connectionTimeouts[id]);
                return;
            }
        }, 1000);
    }
});
