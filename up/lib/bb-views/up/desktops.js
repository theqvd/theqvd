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
        'click .js-vm-settings': 'editDesktopSettings',
        'click .js-grid-disconnected .js-connect-btn': 'connectDesktop',
        'click .js-list-disconnected .js-connect-btn': 'connectDesktop',
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
        $('.js-grid-disconnected .js-grid-cell-icon.js-grid-cell-hiddeable[data-id="' + $(e.target).attr('data-id') + '"]').show();
    },  
    
    hideGridIcon: function (e) {
        $('.js-grid-disconnected .js-grid-cell-icon.js-grid-cell-hiddeable[data-id="' + $(e.target).attr('data-id') + '"]').hide();
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
                        collection: that.wsCollection
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
    
    setDesktopState: function (id, state) {
        var cellDiv = $('.js-grid-cell[data-id="' + id + '"]');
        var iconDiv = $('.js-grid-cell-icon[data-id="' + id + '"]');
        var stateDiv = $('.js-desktop-state[data-id="' + id + '"]');
        
        $(cellDiv).removeClass('grid-disconnected js-grid-disconnected grid-connected js-grid-connected');
        $(cellDiv).attr('data-state', state);

        switch(state) {
            case 'connected':
                $(iconDiv).removeClass('js-grid-cell-hiddeable').addClass('animated faa-flash').hide();
                $(stateDiv).html($.i18n.t('Connected'));
                $(cellDiv).addClass('grid-connected js-grid-connected');
                break;
            case 'disconnected':
                $(iconDiv).addClass('js-grid-cell-hiddeable').removeClass('animated faa-flash').hide();
                $(stateDiv).html($.i18n.t('Disconnected'));
                $(cellDiv).addClass('grid-disconnected js-grid-disconnected');
                break;
            case 'connecting':
                $(iconDiv).removeClass('js-grid-cell-hiddeable').addClass('animated faa-flash').show();
                $(stateDiv).html($.i18n.t('Connecting') + '...');
                $(cellDiv).addClass('grid-connecting js-grid-connecting');
                break;
        }
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
            }
        }, 1000);
    }
});
