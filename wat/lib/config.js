// Config
Wat.C = {
    login: '',
    password: '',
    loggedIn: false,
    apiUrl: 'http://172.20.126.12:3000/',
    loginExpirationDays: 1,

    getBaseUrl: function () {
        return this.apiUrl + "?login=" + this.login + "&password=" + this.password;
    },
    
    isSuperadmin: function () {
        return this.login == 'superadmin';
    },
    
    logOut: function () {
        $.removeCookie('qvdWatLoggedInUser', { path: '/' });
        this.loggedIn = false;
        this.login = '';
    },
    
    logIn: function (login) {
        this.login = login;
        this.loggedIn = true;
        $.cookie('qvdWatLoggedInUser', login, { expires: this.loginExpirationDays, path: '/' });
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
        }
        else {
            this.loggedIn = false;
            this.login = '';
        }
    },
    
    tryLogin: function () {
        var user = $('input[name="admin_user"]').val();
        var password = $('input[name="admin_password"]').val();

        if (!user) {
            Wat.I.showMessage({message: "Empty user", messageType: "error"});
            return;
        }
        
        this.login = user;
        
        Wat.A.performAction('host_tiny_list', {}, {}, {}, this.checkLogin, this);
    },
    
    checkLogin: function (that) {
        if (!that.retrievedData.result) {
            Wat.I.showMessage({message: "Wrong user or password", messageType: "error"});
            that.login = '';
            return;
        }
        
        Wat.C.logIn(that.login);

        Wat.I.renderMain();

        Wat.Router.app_router.performRoute('', Wat.Views.HomeView);
    }
}