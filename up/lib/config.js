// Config
Wat.C = {
    version: '1.7',
    login: '',
    password: '',
    loggedIn: false,
    apiAddress: '172.20.126.16:3000',   

    // Source to be stored by API log
    source: 'WAT',
    
    loginExpirationDays: 1,
    acls: [],
    aclGroups: {},
    sid: '',
    tenantID: -1,
    adminID: -1,
    
    // Abort old requests when navigate or not
    abortOldRequests: true,
    
    // ajax requests
    requests: [],
    
    // Init Api address configuration
    initApiAddress: function () {
        this.apiUrl = 'http://' + this.apiAddress + '/';
        this.apiWSUrl = 'ws://' + this.apiAddress + '/ws';
    },

    // Get the base URL for API calls using credentials or session ID
    getBaseUrl: function () {
        if (this.login && this.password) {
            var baseUrl = this.getApiUrl() + "?login=" + this.login + "&password=" + this.password;
            
            if (this.multitenant && this.tenant != undefined) {
                baseUrl += "&tenant=" + this.tenant;
            }
                        
            return baseUrl;
        }
        else {
            return this.getApiUrl() + "?sid=" + this.sid;
        }
    },
    
    // Get the API URL
    getApiUrl: function () {
        return this.apiUrl;
    },   
    
    // Get the API URL for update DIs
    getUpdateDiUrl: function () {
        return this.getApiUrl() + "di/upload?sid=" + this.sid;
    }, 
    
    // Get the API URL for download DIs from URL
    getDownloadDiUrl: function (url) {
        return this.getApiUrl() + "di/download?sid=" + this.sid + "&url=" + url;
    },
    
    // Return if current admin is superadmin
    isSuperadmin: function () {
        return true;
    },    
    
    // Return if current admin is recover admin
    isRecoveradmin: function (idToCheck) {
        if (idToCheck == undefined) {
            idToCheck = this.adminID;
        }
        return idToCheck == RECOVER_USER_ID;
    },
    
    // Return if system is configured as multitenant WAT
    isMultitenant: function () {
        return this.multitenant;
    },
    
    // Set calls source
    setSource: function (newSource) {
        this.source = newSource;
    },
    
    // Set aborting old requests flag
    setAbortOldRequests: function (newValue) {
        this.abortOldRequests = newValue;
    },
    
    // Return if WAT administrator should know about multitenant enviroment
    knowMultitenant: function () {
        return this.isMultitenant() && (this.isRecoveradmin() || this.isSuperadmin());
    },
    
    getDocGuides: function () {
        guides = {
            'introduction': 'Introduction',
            'stepbystep': 'WAT Step by step', 
            'user': 'User guide'
        };
        
        if (this.knowMultitenant()) {
            guides.multitenant = 'Multitenant guide'
        }
        
        return guides;
    },
    
    // Return a boolean value depending on if the retrieved guide name is valid or not for current administrator
    // Params:
    //      guide: guide name that will be checked as valid or not
    isValidDocGuide: function (guide) {
        var guides = this.getDocGuides ();
        
        return $.inArray(guide, Object.keys(guides)) != -1;
    },
    
    // Process log out including cookies removement
    logOut: function () {
        $.removeCookie('qvdWatSid', { path: '/' });
        $.removeCookie('qvdWatLogin', { path: '/' });
        this.loggedIn = false;
        this.sid = '';
        this.login = '';
        this.acls = [];
    },
    
    // Process login including cookies creation
    // Params:
    //      sid: session ID
    //      login: administrator username
    logIn: function (sid, login) {
        this.loggedIn = true;
        $.cookie('qvdWatSid', sid, { expires: this.loginExpirationDays, path: '/' });
        $.cookie('qvdWatLogin', login, { expires: this.loginExpirationDays, path: '/' });
        Wat.T.initTranslate();
        
        // Reload screen after login
        var locationHash = window.location.hash;
        
        if (locationHash == '#/login' || locationHash == '#/logout' || typeof WatTests != 'undefined') {
            window.location = '#';
        }
        else {
            window.location.reload();
        }

    },
    
    // Check if current admin is properly logged in
    isLogged: function () {
        if (this.loggedIn && this.sid != '' && $.cookie('qvdWatSid') && $.cookie('qvdWatSid') == this.sid && this.login != '' && $.cookie('qvdWatLogin') && $.cookie('qvdWatLogin') == this.login) {
            return true;
        }
        else {
            this.logOut();
            return false;
        }
    },
    
    // Recover login cookies if exist and call to API to check if credentials are correct
    rememberLogin: function () {
        if ($.cookie('qvdWatSid') && $.cookie('qvdWatLogin')) {
            Wat.C.loggedIn = true;
            Wat.C.sid = $.cookie('qvdWatSid');
            Wat.C.login = $.cookie('qvdWatLogin');
        }
        else {
            Wat.C.loggedIn = false;
            Wat.C.sid = '';
            Wat.C.login = '';
        }

        if (this.sid) {
            Wat.A.performAction('current_admin_setup', {}, {}, {}, this.checkLogin, this);
        }
        else {
            Wat.C.afterLogin ();
        }
    },
    
    // Call to API with user and password retrieved to check if credentials are correct.
    // Params:
    //      user: administrator username
    //      password: administrator password
    // If credentials not retrieved, get it from login form
    tryLogin: function (user, password, tenant) {
        var user = $('input[name="admin_user"]').val() || user;
        var password = $('input[name="admin_password"]').val() || password;
        var tenant = $('input[name="admin_tenant"]').val() || tenant;
        
        if (!user) {
            Wat.I.showMessage({message: "Empty user", messageType: "error"});
            return;
        }

        this.login = user;
        this.password = password;
        this.tenant = tenant;
        
        Wat.A.performAction('current_admin_setup', {}, {}, {}, this.checkLogin, this);
    },
    
    // After call to API to get admin setup, check response
    // - Showing message if error. 
    // - Storing useful parameters, perform configuration and rendering main if success.
    // Params:
    //      that: Current context where will be stored API call return
    checkLogin: function (that) {   
        that.password = '';
        
        if (!that.retrievedData.acls || $.isEmptyObject(that.retrievedData.acls)) {
            Wat.C.logOut();
            Wat.I.showMessage({message: "Wrong user or password", messageType: "error"});
            that.login = '';
            that.sid = '';
            window.location.reload();
            return;
        }
        
        // Store retrieved acls
        Wat.C.acls = that.retrievedData.acls;
        
        // Store language
        Wat.C.language = that.retrievedData.admin_language;
        Wat.C.tenantLanguage = that.retrievedData.tenant_language;
        
        // Store block
        Wat.C.block = that.retrievedData.admin_block;
        Wat.C.tenantBlock = that.retrievedData.tenant_block;
        
        // Store tenant ID
        Wat.C.tenantID = that.retrievedData.tenant_id;
        
        // Store admin ID
        Wat.C.adminID = that.retrievedData.admin_id;   
        
        // Store tenant mode
        Wat.C.multitenant = parseInt(that.retrievedData.multitenant);
        
        // Store time lag between server and client
        var currentDate = new Date();
        var serverDate = new Date(that.retrievedData.server_datetime);
        Wat.C.serverClientTimeLag = parseInt((serverDate - currentDate) / 1000);
        
        // Configure visability
        Wat.C.configureVisibility();
        
        if (Wat.CurrentView.qvdObj == 'login') {
            Wat.C.logIn(that.sid, that.login);
                
            Wat.I.renderMain();

            Wat.Router.app_router.performRoute('', Wat.Views.HomeView);
        }
                
        Wat.C.afterLogin ();
    },
    
    // Given an ACL or an array of ACLs, check if the current admin is granted to it
    // Params:
    //      acl: string or array of acls
    //      logic: OR/AND to calculate the pass condition if is array
    checkACL: function (acl, logic) {
        if ($.isArray(acl)) {
            var pass = 0;
            var that = this;
            $.each(acl, function (i, anAcl) {
                if ($.inArray(anAcl, that.acls) != -1) {
                    pass++;
                }
            });
            
            switch(logic) {
                case 'OR':
                    if (pass > 0) {
                        return true;
                    }
                    break;
                case 'AND':
                default:
                    if (pass == acl.length) {
                        return true;
                    }
                    break;
            }
        }
        else {
            return $.inArray(acl, this.acls) != -1;
        }
        
        if (DEBUG_ACL_FAILS) {
            console.warn('ACL Fail for user ' + this.login + ':');
            console.warn(acl);
        }

        return false;
    },
    
    // Check all the ACLs of predifened groups. If any of them is available, return true
    // Params:
    //      group: ACls group or groups name associted to groups of ACLs defined on configuration file
    checkGroupACL: function (group) {
        var aclGranted = false;
        
        // Convert to array if is not an array yet
        if (typeof group == 'string') {
            var groups = [group];
        }
        else {
            var groups = group;
        }
        
        var that = this;
        $.each(groups, function (iGroup, group) {
            if (aclGranted) {
                return false;
            }
            $.each(that.aclGroups[group], function (iAcl, acl) {
                if (that.checkACL(acl)) {
                    aclGranted = true;
                    return false;
                }
            });
        });
        
        return aclGranted;
    },
    
    // Return a given string if an acl is granted. Empty string will be returned otherwise
    // Params:
    //      string: string that will be returned if pass
    //      acl: acl that will be checked
    ifACL: function (string, acl) {
        if (this.checkACL(acl)) {
            return string;
        }
        else {
            return '';
        }
    },
    
    // Given configuration data (fields, filters, columns...) Delete those which specified ACLs doesnt pass
    // Params:
    //      data: Structure of data for any purpose where is specified ACL or ACL group to be checked for each element.
    purgeConfigData: function (data) {
        var that = this;
        
        // Check acls on data items to remove forbidden ones
        $.each(data, function (item, itemConfig) {
            if (itemConfig.groupAcls != undefined) {
                if (typeof itemConfig.groupAcls == 'string') {
                    itemConfig.groupAcls = [itemConfig.groupAcls];
                }
                
                itemConfig.acls = [];
                
                $.each (itemConfig.groupAcls, function (iGACLs, gACLs) {
                    var acls = that.aclGroups[gACLs];
                    itemConfig.acls = itemConfig.acls.concat(acls);
                });
            }
                        
            if (itemConfig.acls != undefined) {
                if (!that.checkACL(itemConfig.acls, itemConfig.aclsLogic)) {
                    delete data[item];
                }
            }
        });
        
        return data;
    },
    
    // Set different parameters to correct menu and sections visibility. 
    // These settings will be performed depending on ACL checks, mono/multi tenant configurations, or administrators tenants type
    configureVisibility: function () {        
        Wat.I.menu = $.extend(true, {}, Wat.I.menuOriginal);
        Wat.I.userMenu = $.extend(true, {}, Wat.I.menuUserOriginal);
        Wat.I.helpMenu = $.extend(true, {}, Wat.I.menuHelpOriginal);
        Wat.I.configMenu = $.extend(true, {}, Wat.I.menuConfigOriginal);
        Wat.I.setupMenu = $.extend(true, {}, Wat.I.menuSetupOriginal);
        Wat.I.mobileMenu = $.extend(true, {}, Wat.I.mobileMenuOriginal);
        Wat.I.cornerMenu = $.extend(true, {}, Wat.I.cornerMenuOriginal);

        var that = this;

        // Menu visibility
        var aclMenu = {
            'di.see-main.' : 'dis',
            'host.see-main.' : 'hosts',
            'osf.see-main.' : 'osfs',
            'user.see-main.' : 'users',
            'vm.see-main.' : 'vms',
        };
        
        // Menu visibility
        var aclSetupMenu = {
            'config.wat.' : 'watconfig',
            'role.see-main.' : 'roles',
            'administrator.see-main.' : 'administrators',
            'tenant.see-main.' : 'tenants',
            'views.see-main.' : 'views',
            'log.see-main.' : 'logs',
        };
        
        // For tenant admins (not superadmins) and recover admin in monotenant mode the acl section tenant will not exist
        var tenantsExist = false;
        
        if (Wat.C.isSuperadmin() && Wat.C.isMultitenant()) {
            tenantsExist = true;
        }
        
        // For monotenant  enviroments, multitenant documentation will not be shown
        if (!Wat.C.isMultitenant()) {
            $.each(Wat.I.docSections, function (iSec, sec) {
                if (sec.guide == 'multitenant') {
                    delete Wat.I.docSections[iSec];
                }
            });
        }
        
        if (!tenantsExist) {
            delete ACL_SECTIONS['tenant'];
            delete ACL_SECTIONS_PATTERNS['tenant'];
        }
    },
    
    // Check if administrator session is expired
    // Params:
    //      response: API call response
    sessionExpired: function (response) {
        if (!Wat.Router.app_router) {
            return false;
        }
        else if (response.status == STATUS_NOT_LOGIN || response.status == STATUS_SESSION_EXPIRED) {
            Wat.Router.app_router.trigger('route:logout');
            Wat.I.showMessage({'message': ALL_STATUS[response.status], 'messageType': 'error'});
            return true;
        }
        
        return false;
    },
    
    // Abort stored ajax requests
    abortRequests: function () {
        var that = this;
        
        $.each(that.requests, function(idx, jqXHR) {
            if (jqXHR == undefined) {
                return;
            }
            
            jqXHR.abort();
        });

        $.each(that.requests, function(idx, jqXHR) {
            var index = $.inArray(jqXHR, that.requests);
            if (index > -1) {
                that.requests.splice(index, 1);
            }
        });
    },
    
    // Add common functions to the view
    addCommonFunctions: function (that) {
        if (Wat.Common.BySection[that.qvdObj] != undefined) {
            if (!$.isEmptyObject(Wat.Common.BySection[that.qvdObj])) {
                $.extend(that, Wat.Common.BySection[that.qvdObj]);
                that.initializeCommon(that);
                delete that.initializeCommon;
            }
        }
    }
}