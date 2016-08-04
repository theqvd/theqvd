Up.Views.DesktopListView = Up.Views.ListView.extend({  
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
        
        // Spy mouse over elements to avoid fails with mouseleave events
        Up.I.L.spyMouseOver('.js-grid-cell-area', this.hideGridIcon);
        
        Up.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    addListTemplates: function () {
        Up.Views.ListView.prototype.addListTemplates.apply(this, []);

        var templates = {};
        
        templates["list-grid_" + this.qvdObj] = {
            name: 'desktops/' + this.qvdObj + '-grid'
        };  

        templates["list-list_" + this.qvdObj] = {
            name: 'desktops/' + this.qvdObj + '-list'
        };
        
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
        
        this.loadFakeData();

        $.each(this.collectionWorkspaces.models, function (modId, model) {
            var selectedHTML = '';
            if (model.get('active')) {
                selectedHTML = 'selected="selected"';
            }
            $('select[name="active_configuration_select"]').append('<option value="' + model.get('id') + '" ' + selectedHTML + '>' + model.get('name') + '</option>');
        });
        
        Up.I.chosenElement('select[name="active_configuration_select"]', 'single');    
    },
    
    // Render only the list. Usefull to functions such as pagination, sorting and filtering where is not necessary render controls
    renderList: function () {
        // Fill the list
        var template = _.template(
            Up.TPL['list-' + this.viewMode + '_' + this.qvdObj], {
                models: this.collection.models,
                checkBox: false
            }
        );
        
        $(this.listContainer).html(template);
        this.paginationUpdate();
        this.shownElementsLabelUpdate();
        
        // Open websockets for live fields
        if (this.liveFields) {
            Up.WS.openListWebsockets(this.qvdObj, this.collection, this.liveFields, this.cid);
        }
        
        Up.T.translateAndShow();
                
        Up.I.addSortIcons(this.cid);
                
        Up.I.addOddEvenRowClass(this.listContainer);
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
    
    changeActiveConf: function (e) {
        var wsId = $('select[name="active_configuration_select"]').val();
        var wsModel = Up.CurrentView.collectionWorkspaces.where({'id': parseInt(wsId)})[0];
        
        var wsSettings = wsModel.get('settings');
        
        if (!wsSettings) {            
            Up.CurrentView.firstEditWorkspace(e);
        }
    },
    
    editDesktopSettings: function (e) {
        var selectedId = $(e.target).attr('data-id');
        var model = Up.CurrentView.collection.where({id: parseInt(selectedId)})[0];
        
        var that = this;
        var dialogConf = {
            title: $.i18n.t('Desktop settings') + ': ' + model.get('name'),
            buttons : {
                "Save": function () {
                    Up.I.closeDialog($(this));
                }
            },
            button1Class : 'fa fa-save',
            fillCallback : function (target) { 
                Up.I.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    },
    
    connectDesktop: function (e) {
        var that = this;
        
        var selectedId = $(e.target).attr('data-id');

        Up.A.performAction('desktops/' + selectedId + '/token', {}, function (e) {
            that.setDesktopState(selectedId, 'connecting');
            that.startConnectionTimeout(selectedId);
            
            var token = e.retrievedData.token;
            console.log("window.open('qvd:client.ssl.options.SSL_version=TLSv1_2 client.host.name=" + window.location.hostname + " client.auto_connect=1 client.auto_connect.vm_id=" + selectedId + " client.auto_connect.token=" + token + "', '_self');");
            window.open('qvd:client.ssl.options.SSL_version=TLSv1_2 client.host.name=' + window.location.hostname + ' client.auto_connect=1 client.auto_connect.vm_id=' + selectedId + ' client.auto_connect.token=' + token, '_self');
        }, this, 'GET');
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
    },
    
    firstEditWorkspace: function (e) {
        var selectedId = $(e.target).val();

        var model = this.collectionWorkspaces.where({id: parseInt(selectedId)})[0];

        var that = this;
        var dialogConf = {
            title: $.i18n.t('First Workspace configuration') + ': ' + model.get('name'),
            buttons : {
                "Cancel": function () {
                    // If cancel, check default workspace as active
                    $('[name="active_configuration_select"]').val(0);
                    $('[name="active_configuration_select"]').trigger('chosen:updated');
                    $('[name="active_configuration_select"]').trigger('change');
                    
                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Save": function () {                    
                    var params = Up.I.parseForm(this);
                    
                    // TODO: Save params
                    console.log(model);
                    
                    Up.I.closeDialog($(this));
                }
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-save',
            fillCallback : function (target) { 
                Up.I.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    },   
});
