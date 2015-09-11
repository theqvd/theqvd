<div class="login-box">
    <iframe id="remember" name="remember" class="hidden" src="index.html"></iframe>

    <div class="login-side">
        <img src="images/logo-login.png" />
    </div>
    <div class="login-main">
        <form class="login-form js-login-form" target="remember" method="post" action="index.html">
            <div class="login-form">
                <%
                if (parseInt(multitenant)) {
                %>
                    <div class="login-control">
                        <div data-i18n="Tenant"></div>
                        <div>
                            <input type="text" name="admin_tenant"/>
                        </div>
                    </div>
                <%
                }
                %>
                <div class="login-control">
                    <div data-i18n="User"></div>
                    <div>
                        <input type="text" name="admin_user"/>
                    </div>
                </div>
                <div class="login-control">
                    <div data-i18n="Password"></div>
                    <div>
                        <input type="password" name="admin_password"/>
                    </div>
                </div>
                <div class="login-button">
                    <div>
                        <a class="fa fa-sign-in button js-login-button" data-i18n="Log-in"></a>
                        <!--<input type="submit" class="fa fa-sign-in button js-login-button" data-i18n="[value]Log-in">-->
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>