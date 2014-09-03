// Config
Wat.C = {
    login: 'superadmin',
    login: 'benja',
    password: '',
    loggedIn: false,
    apiUrl: 'http://172.20.126.12:3000/',

    getBaseUrl: function () {
        return this.apiUrl + "?login=" + this.login + "&password=" + this.password;
    },
    
    isSuperadmin: function () {
        return this.login == 'superadmin';
    },
    
    logOut: function () {
        this.loggedIn = false;
    },
    
    logIn: function (login) {
        this.login = login;
        this.loggedIn = true;
    },
    
    isLogged: function () {
        return this.loggedIn;
    }
}