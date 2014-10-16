// Config
Wat.C = {
    version: '1.7',
    login: '',
    password: '',
    loggedIn: false,
    apiUrl: 'http://172.20.126.12:3000/',
    //apiUrl: 'http://172.26.9.42:3000/',
    loginExpirationDays: 1,
    acls: [],
    aclGroups: {},

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
        
        Wat.A.performAction('current_admin_setup', {}, {}, {}, this.checkLogin, this, false);
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
        
        if (Wat.CurrentView.qvdObj == 'login') {
            Wat.C.logIn(that.login, that.password);
                
            Wat.I.renderMain();

            Wat.Router.app_router.performRoute('', Wat.Views.HomeView);
            
            //window.location.reload();
        }
    },
    
    // Given an ACL or an array of ACLs, check if it pass or not due the user configuration
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
        
        return false;
    },
    
    // Check all the ACLs of predifened groups. If any of them is available, return true
    checkGroupACL: function (group) {
        var aclGranted = false;
        
        var that = this;
        $.each(this.aclGroups[group], function (iAcl, acl) {
            if (that.checkACL(acl)) {
                aclGranted = true;
                return false;
            }
        });
        
        return aclGranted;
    },
    
    ifACL: function (string, acl) {
        if (this.checkACL(acl)) {
            return string;
        }
        else {
            return '';
        }
    },
    
    purgeConfigData: function (data) {
        var that = this;
        
        // Check acls on data items to remove forbidden ones
        $.each(data, function (item, itemConfig) {
            if (itemConfig.groupAcls != undefined) {
                itemConfig.acls = that.aclGroups[itemConfig.groupAcls];
            }
            if (itemConfig.acls != undefined) {
                if (!that.checkACL(itemConfig.acls, itemConfig.aclsLogic)) {
                    delete data[item];
                }
            }
        });
        
        return data;
    },
    
    configureVisibility: function () {        
        Wat.I.menu = $.extend(true, {}, Wat.I.menuOriginal);
        Wat.I.mobileMenu = $.extend(true, {}, Wat.I.mobileMenuOriginal);

        // Menu visibility
        var aclMenu = {
            'di.see-main.' : 'dis',
            'host.see-main.' : 'hosts',
            'osf.see-main.' : 'osfs',
            'user.see-main.' : 'users',
            'vm.see-main.' : 'vms',
        };
        
        var that = this;
        
        $.each(aclMenu, function (acl, menu) {
            if (!that.checkACL(acl)) {
                delete Wat.I.menu[menu];
                delete Wat.I.mobileMenu[menu];
            }
        });

        Wat.I.cornerMenu = $.extend(true, {}, Wat.I.cornerMenuOriginal);
        
        // Corner menu visibility
        var aclCornerMenu = {
            'administrator.see-main.' : 'admins',
            'role.see-main.' : 'roles',
            'tenant.see-main.' : 'tenants',
            'config.see-main.' : 'config',
            'views.see-main.' : 'customize',
        };
        
        var that = this;
        
        $.each(aclCornerMenu, function (acl, menu) {
            if (!that.checkACL(acl)) {
                delete Wat.I.cornerMenu.setup.subMenu[menu];
            }
        });
        
        if ($.isEmptyObject(Wat.I.cornerMenu.setup.subMenu)) {
            delete Wat.I.cornerMenu.setup;
        }
    }
}