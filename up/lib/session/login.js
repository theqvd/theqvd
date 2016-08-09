Up.L = {
    loggedIn: false,
    sid: '',
    login: '',
    acls: [],
    
    // Process log out including cookies removement
    logOut: function () {
        Up.C.loggedIn = false;
        Up.C.sid = '';
        Up.C.login = '';
        Up.C.acls = [];
        
        Up.I.stopServerClock();
    },
    
    // Process login including cookies creation
    // Params:
    //      sid: session ID
    //      login: administrator username
    logIn: function (sid, login) {
        Up.C.loggedIn = true;
        
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
        if (Up.C.loggedIn && Up.C.sid != '' && Up.C.login != '') {
            return true;
        }
        else {
            Up.L.logOut();
            return false;
        }
    },
    
    // Recover login cookies if exist and call to API to check if credentials are correct
    rememberLogin: function () { 
        Up.C.loggedIn = true;
        
        Up.A.performAction('account', {}, function (that) {
            // Store account settings
            Up.C.account = that.retrievedData;
            
            // Configure visability
            Up.C.configureVisibility();
            
            if (that.retrievedData.status == STATUS_UNAUTHORIZED) {
                Up.L.loadLogin();           
            }
            else {
                Up.L.afterLogin (); 
            }
        });
    },
    
    loadLogin: function () {
        Up.T.initTranslate();

        // Interface configuration
        Up.I.renderMain();
        
        Up.CurrentView = new Up.Views.LoginView({});
    },
    
    // Call to API with user and password retrieved to check if credentials are correct.
    // Params:
    //      user: administrator username
    //      password: administrator password
    // If credentials not retrieved, get it from login form
    tryLogin: function (user, password, tenant) {
        var user = $('input[name="admin_user"]').val() || user;
        var password = $('input[name="admin_password"]').val() || password;
        
        if (!user) {
            Up.I.M.showMessage({message: "Empty user", messageType: "error"});
            return;
        }

        Up.C.login = user;
        Up.C.password = password;
        
        Up.A.apiInfo(Up.L.Login, {});
    },
    
    Login: function (that) {
        Up.A.apiLogIn(Up.L.checkLogin, Up.C);
    },
    
    // After call to API to get admin setup, check response
    // - Showing message if error. 
    // - Storing useful parameters, perform configuration and rendering main if success.
    // Params:
    //      that: Current context where will be stored API call return
    checkLogin: function (that) {
        that.password = '';
        
        if (that.retrievedData.status == STATUS_UNAUTHORIZED) {
            Up.I.renderMain();
            Up.CurrentView = new Up.Views.LoginView({});
            return;
        }
        // If request is not correctly performed and session is enabled, logout and reload
        else if (that.retrievedData.status == STATUS_SUCCESS && that.retrievedData.statusText == 'error') {
            if (Up.C.sid) {
                Up.L.logOut();
                window.location.reload();
            }
            return;
        }
        else if (that.retrievedData.status == ERROR_INTERNAL) {
            Up.I.M.showMessage({message: that.retrievedData.statusText, messageType: "error"});
            return;
        }
        else if (!Up.C.login && that.retrievedData.status == STATUS_NOT_LOGIN) {
            // First loading
            Up.I.M.showMessage({message: that.retrievedData.message, messageType: "error"});
            Up.C.configureVisibility();
            Up.L.afterLogin ();
            return;
        }
        else if (that.retrievedData.status == STATUS_SESSION_EXPIRED || that.retrievedData.status == STATUS_CREDENTIALS_FAIL || that.retrievedData.status == STATUS_NOT_LOGIN || that.retrievedData.status == STATUS_TENANT_RESTRICTED) {
            if (Up.C.sid) {
                Up.L.logOut();
                $.cookie('messageToShow', JSON.stringify({message: that.retrievedData.message, messageType: "error"}), {expires: 1, path: '/'});
                window.location.reload();
            }
            else {
                Up.I.M.showMessage({message: that.retrievedData.message, messageType: "error"});
            }
            return;
        }
        
        if (that.retrievedData.sid) {
            Up.C.sid = that.retrievedData.sid;
        }
        
        // Store retrieved acls
        Up.C.acls = that.retrievedData.acls;
        
        // Store login
        Up.C.login = that.retrievedData.admin_name
        
        // Store block
        Up.C.block = that.retrievedData.admin_block;
        Up.C.tenantBlock = that.retrievedData.tenant_block;
        
        
        // Restore possible residous views configuration to default values
        Up.I.restoreListColumns();
        Up.I.restoreFormFilters();
        
        // Store tenant ID and Name
        Up.C.tenantID = that.retrievedData.tenant_id;
        Up.C.tenantName = that.retrievedData.tenant_name;
        
        // Store admin ID
        Up.C.adminID = that.retrievedData.admin_id;   
        
        // Store time lag between server and client
        var currentDate = new Date();
        var serverDate = new Date(that.retrievedData.server_datetime);
        Up.C.serverClientTimeLag = parseInt((serverDate - currentDate) / 1000);
        
        // Configure visability
        Up.C.configureVisibility();

        if (Up.CurrentView.qvdObj == 'login') {
            Up.L.logIn(that.sid, that.login);
                
            Up.I.renderMain();

            //Up.Router.upRouter.performRoute('', Up.Views.DesktopsView);
        }
                
        Up.L.afterLogin ();
    },
    
    afterLogin: function () {
        // Load translation file
        Up.T.initTranslate();

        // Interface configuration
        Up.I.renderMain();

        if (Up.C.showServerClock) {
            // Start server clock
            Up.I.startServerClock();
        }

        // Binding events manually because backbone doesnt allow bind events to dialogs loaded dinamically
        Up.B.bindCommonEvents();

        if (Up.L.isLogged()) {
            Up.I.setCustomizationFields();
        }
        
        // If the router isnt instantiate, do it
        if (Up.Router.upRouter == undefined) {          
            // Instantiate the router
            Up.Router.upRouter = new Up.Router;
        }
    },
}
