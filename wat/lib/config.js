// Config
Wat.C = {
    version: '1.7',
    login: '',
    password: '',
    loggedIn: false,
    apiUrl: 'http://172.20.126.12:3000/',
    loginExpirationDays: 1,
    acls: [],

    getBaseUrl: function () {
        return this.apiUrl + "?login=" + this.login + "&password=" + this.password;
    },
    
    isSuperadmin: function () {
        return this.login == 'superadmin';
    },
    
    logOut: function () {
        $.removeCookie('qvdWatLoggedInUser', { path: '/' });
        $.removeCookie('qvdWatLoggedInPassword', { path: '/' });
        this.loggedIn = false;
        this.login = '';
    },
    
    logIn: function (login, password) {
        this.login = login;
        this.password = password;
        this.loggedIn = true;

        $.cookie('qvdWatLoggedInUser', login, { expires: this.loginExpirationDays, path: '/' });
        $.cookie('qvdWatLoggedInPassword', password, { expires: this.loginExpirationDays, path: '/' });
        window.location = '#';
    },
    
    isLogged: function () {
        if (this.loggedIn && this.login != '' && $.cookie('qvdWatLoggedInUser') && $.cookie('qvdWatLoggedInUser') == this.login) {
            return true;
        }
        else {
            this.logOut();
            return false;
        }
    },
    
    rememberLogin: function () {
        if ($.cookie('qvdWatLoggedInUser')) {
            this.loggedIn = true;
            this.login = $.cookie('qvdWatLoggedInUser');
            this.password = $.cookie('qvdWatLoggedInPassword');
        }
        else {
            this.loggedIn = false;
            this.login = '';
        }
    },
    
    tryLogin: function (user, password) {
        var user = $('input[name="admin_user"]').val() || user;
        var password = $('input[name="admin_password"]').val() || password;
        
        if (!user) {
            Wat.I.showMessage({message: "Empty user", messageType: "error"});
            return;
        }

        this.login = user;
        this.password = password;

        Wat.A.performAction('current_admin_setup', {}, {}, {}, this.checkLogin, this, false);
    },
    
    checkLogin: function (that) {        
        if (!that.retrievedData.result || $.isEmptyObject(that.retrievedData.result)) {
            Wat.I.showMessage({message: "Wrong user or password", messageType: "error"});
            that.login = '';
            return;
        }

        // Store retrieved acls
        Wat.C.acls = that.retrievedData.result.acls;
        Wat.C.configureVisibility();
        
        Wat.C.logIn(that.login, that.password);

        Wat.I.renderMain();

        Wat.Router.app_router.performRoute('', Wat.Views.HomeView);
    },
    
    checkACL: function (acl) {
        return $.inArray(acl, this.acls) != -1;
    },
    
    configureVisibility: function () {
        var aclMenu = {
            'see_di' : 'dis',
            'see_host' : 'hosts',
            'see_osf' : 'osfs',
            'see_user' : 'users',
            'see_vm' : 'vms',
        };
        
        var that = this;
        
        $.each(aclMenu, function (acl, menu) {
            if (!that.checkACL(acl)) {
                delete Wat.I.menu[menu];
            }
        });
    }
}