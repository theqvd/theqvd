// Config
Wat.C = {
    login: 'benja',
    password: '',
    apiUrl: 'http://172.20.126.12:3000/',

    getBaseUrl: function () {
        return this.apiUrl + "?login=" + this.login + "&password=" + this.password;
    }
}