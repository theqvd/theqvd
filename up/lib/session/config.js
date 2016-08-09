// Config
Up.C = {
    // Version of WAT
    version: '4.0',
    
    // Login parameters
    login: '',
    password: '',
    loggedIn: false,
    
    // API parameters
    apiUrl: '', // Will be loaded from external file config.json

    // Source to be stored by API log
    source: 'WAT',
    
    // Configuration file name
    configFileName: 'config.json',
    
    // Days to login expiration
    loginExpirationDays: 1,
    
    // ACL variables
    acls: [],
    aclGroups: {},
    
    // Session ID
    sid: '',
    
    // Current admin IDs
    tenantID: -1,
    adminID: -1,
    
    // Abort old requests when navigate or not
    abortOldRequests: true,
    
    // ajax requests
    requests: [],
    
    // Flag to know if router history is started
    routerHistoryStarted: false,
    
    // Show a clock with server's time
    showServerClock: false,
    
    // Init Api address configuration
    initApiAddress: function () {
        var apiPath = '/api/';
        this.apiUrl+= apiPath;

		// Build websockets URL depending on the used protocol
        if (Up.C.apiUrl.substr(0, 5) == 'https') {
            this.apiWSUrl = 'wss' + this.apiUrl.substr(5);
        }
        else {
            this.apiWSUrl = 'ws' + this.apiUrl.substr(4);
        }
    },

    // Get the base URL for API calls using credentials or session ID
    getBaseUrl: function (action) {
        action = action || "";
        
        return this.getApiUrl() + action;
    },
    
    // Get the API URL
    getApiUrl: function () {
        return this.apiUrl;
    },   
    
    // Set aborting old requests flag
    setAbortOldRequests: function (newValue) {
        this.abortOldRequests = newValue;
    },
    
    getDocGuides: function () {
        guides = {
            'introduction': 'Introduction',
            'stepbystep': 'WAT Step by step', 
            'user': 'User guide'
        };
        
        return guides;
    },
    
    // Return a boolean value depending on if the retrieved guide name is valid or not for current administrator
    // Params:
    //      guide: guide name that will be checked as valid or not
    isValidDocGuide: function (guide) {
        var guides = this.getDocGuides ();
        
        return $.inArray(guide, Object.keys(guides)) != -1;
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
        Up.I.menu = $.extend(true, {}, Up.I.menuOriginal);
        Up.I.userMenu = $.extend(true, {}, Up.I.menuUserOriginal);
        Up.I.helpMenu = $.extend(true, {}, Up.I.menuHelpOriginal);
        Up.I.configMenu = $.extend(true, {}, Up.I.menuConfigOriginal);
        Up.I.setupMenu = $.extend(true, {}, Up.I.menuSetupOriginal);
        Up.I.mobileMenu = $.extend(true, {}, Up.I.mobileMenuOriginal);
        Up.I.cornerMenu = $.extend(true, {}, Up.I.cornerMenuOriginal);
        
        var that = this;

        // Menu visibility
        var aclMenu = {
            'di.see-main.' : 'dis',
            'host.see-main.' : 'hosts',
            'osf.see-main.' : 'osfs',
            'user.see-main.' : 'users',
            'vm.see-main.' : 'vms',
        };
        
        $.each(aclMenu, function (acl, menu) {
            if (!that.checkACL(acl)) {
                delete Up.I.menu[menu];
                delete Up.I.mobileMenu[menu];
            }
        });
        
        // Menu visibility
        var aclSetupMenu = {
            'config.wat.' : 'watconfig',
            'role.see-main.' : 'roles',
            'administrator.see-main.' : 'administrators',
            'tenant.see-main.' : 'tenants',
            'views.see-main.' : 'views',
            'property.see-main.' : 'properties',
            'log.see-main.' : 'logs',
        };
        
        $.each(aclSetupMenu, function (acl, menu) {
            if (!that.checkACL(acl)) {
                delete Up.I.setupMenu[menu];
            }
        });
        
        // For tenant admins (not superadmins) and recover admin in monotenant mode the acl section tenant will not exist
        var tenantsExist = false;
        
        if (!tenantsExist) {
            delete ACL_SECTIONS['tenant'];
            delete ACL_SECTIONS_PATTERNS['tenant'];
        }
    },
    
    // Check if administrator session is expired
    // Params:
    //      response: API call response
    sessionExpired: function (response) {
        if (!Up.Router.upRouter) {
            return false;
        }
        else {
            switch  (response.status) { 
                case STATUS_TENANT_RESTRICTED:
                    // Tenant restricted control will only works when logged (sid defined)
                    if (!Up.C.sid) {
                        break;
                    }
                case STATUS_SESSION_EXPIRED:
                case STATUS_CREDENTIALS_FAIL:
                case STATUS_NOT_LOGIN:
                    // Close dialog (if opened)
                    $('.js-dialog-container').remove();
                    $('html, body').attr('style', '');
                    
                    // Store message on cookies to print it after reloading
                    $.cookie('messageToShow', JSON.stringify({'message': ALL_STATUS[response.status], 'messageType': 'error'}), {expires: 1, path: '/'});
                    window.location = '#/logout';
                    return true;
            }
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
        if (Up.Common.BySection[that.qvdObj] != undefined) {
            if (!$.isEmptyObject(Up.Common.BySection[that.qvdObj])) {
                $.extend(that, Up.Common.BySection[that.qvdObj]);
                that.initializeCommon(that);
                delete that.initializeCommon;
            }
        }
    },
    
    setConfigToken: function (token, value) {
        if ($.inArray(token, ['apiUrl']) == -1) {
            console.error('A not allowed token was intented to load from config file (' + token + ')');
            return;
        }
        
        this[token] = value;
    },
    
    // Add extensions or another setup parameters to jQuery
    setupJQuery: function () {
        // Extend jQuery with pseudo selector :blank
        (function($) {
            $.extend($.expr[":"], {
                // http://docs.jquery.com/Plugins/Validation/blank
                blank: function(a) {
                    return !$.trim(a.value);
                },
            });
        })(jQuery);
        

        // Setup jQuery ajax to store all requests in a requests queue
        $.ajaxSetup({
            beforeSend: function(jqXHR) {
                // Dictionary calls will not be stored
                if (jqXHR.requestURL.indexOf('dictionaries') != -1) {
                    return;
                }
                
                Up.C.requests.push(jqXHR);
            },
            complete: function(jqXHR) {
                var index = $.inArray(jqXHR, Up.C.requests);
                if (index > -1) {
                    Up.C.requests.splice(index, 1);
                }
            },
            statusCode: {
                // Not authorized
                401: function () {
                    Up.L.loadLogin();
                },
            }
        });
        
		// Attach request url to ajax data
        $.ajaxPrefilter(function( options, originalOptions, jqXHR ) {
            jqXHR.requestURL = options.url;   
        });
        
        // Trick to avoid hanged hover events when focus of the window is lost
        $(window).blur(function() {
            $('div').trigger('mouseleave');
        });
    },
    
    // Read config file "/config.json"
    readConfigFile: function (callback) {
        $.ajax({
            url: Up.C.configFileName,
            method: 'GET',
            async: true,
            contentType: 'json',
            cache: false,
            complete: function (response) {
                var isJSON = true;
                var configTokens = '';
                
                try {
                    configTokens = JSON.parse(response.responseText);
                }
                catch(err) {
                    isJSON = false;
                } 
                
                if (isJSON) {
                    $.each(configTokens, function (token, value) {
                        Up.C.setConfigToken(token, value);
                    });

                    // After read configuration file, we will set API address
                    Up.C.initApiAddress();
                }
                
                // Remember login from cookies to recover session if was setted previously
                Up.L.rememberLogin();
            }
        });
    },
    
    setupLibraries: function () {
        // Attach fast click events to separate tap from click
        Up.I.attachFastClick(); 
    },
}
