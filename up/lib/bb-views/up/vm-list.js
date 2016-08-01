Up.Views.VMListView = Up.Views.SettingsProtoView.extend({  
    qvdObj: 'vm',
    viewMode: 'grid',
    liveFields: ['state', 'user_state', 'ip', 'host_id', 'host_name', 'ssh_port', 'vnc_port', 'serial_port'],
    connectionTimeouts: [],
    
    relatedDoc: {
        image_update: "Images update guide",
        full_vm_creation: "Create a virtual machine from scratch",
    },
    
    initialize: function (params) {
        this.collection = new Up.Collections.VMs(params);
        
        $('.menu-option').removeClass('menu-option--current');
        $('[data-target="virtualdesktops"]').addClass('menu-option--current');
        
        Up.B.bindEvent('mouseover', '.js-grid-cell-area', function (e) {
            $('.js-grid-disconnected .js-grid-cell-icon.js-grid-cell-hiddeable[data-id="' + $(e.target).attr('data-id') + '"]').show();
        });        
        Up.B.bindEvent('mouseout', '.js-grid-cell-area', function (e) {
            $('.js-grid-disconnected .js-grid-cell-icon.js-grid-cell-hiddeable[data-id="' + $(e.target).attr('data-id') + '"]').hide();
        });
        
        setInterval(function() {
            // If mouse is not over hoverable div, trigger mouseleave event as hack to avoid fails on native HTML event
            if ($('.js-grid-cell-area:hover').length == 0) {
                $('.js-grid-cell-area').trigger('mouseleave');
            }
        }, 500);

        Up.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
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
    
    // This events will be added to view events
    listEvents: {
        'click .js-change-viewmode': 'changeViewMode',
        'click .js-vm-settings': 'editDesktopSettings',
        'click .js-grid-disconnected .js-connect-btn': 'connectDesktop',
        'click .js-list-disconnected .js-connect-btn': 'connectDesktop',
        'change select[name="active_configuration_select"]': 'changeActiveConf'
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
                Up.CurrentView.renderEditionMode(model, target);
                $('.js-settings-details-bracket').hide();
            },
        }

        Up.I.dialog(dialogConf);
    },
    
    connectDesktop: function (e) {
        var that = this;
        
        var selectedId = $(e.target).attr('data-id');

        Up.A.performAction('vm_connect/' + selectedId, {}, function (e) {
            that.setDesktopState(selectedId, 'connecting');
            that.startConnectionTimeout(selectedId);
            window.location = Up.C.getBaseUrl('vm_connect/' + selectedId);
            
        }, this, 'POST');
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
    
    createElement: function () {
        var valid = Up.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');

        var user_id = context.find('[name="user_id"]').val();
        var osf_id = context.find('select[name="osf_id"]').val();
        
        var arguments = {
            "user_id": user_id,
            "osf_id": osf_id
        };
        
        if (!$.isEmptyObject(properties.set) && Up.C.checkACL('vm.create.properties')) {
            arguments["__properties__"] = properties.set;
        }
        
        var di_tag = context.find('select[name="di_tag"]').val();
        
        if (di_tag && Up.C.checkACL('vm.create.di-tag')) {
            arguments.di_tag = di_tag;
        }
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            arguments["name"] = name;
        }
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            arguments["description"] = description;
        }
        
        this.createModel(arguments, this.fetchList);
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
                that.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    },   
});