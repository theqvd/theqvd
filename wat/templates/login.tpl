<div class="login-box">
    <div class="login-side">
        <img src="images/qvd-logo-header-trans-tiny_big.png" />
    </div>
    <div class="login-main">
        <div class="login-form">
            <%
            if (parseInt(multitenant)) {
            %>
                <div class="login-control">
                    <div data-i18n="Tenant"></div>
                    <div>
                        <input type="text" name="admin_tenant"  autocomplete="on"/>
                    </div>
                </div>
            <%
            }
            %>
            <div class="login-control">
                <div data-i18n="User"></div>
                <div>
                    <input type="text" name="admin_user" autocomplete="on"/>
                </div>
            </div>
            <div class="login-control">
                <div data-i18n="Password"></div>
                <div>
                    <input type="password" name="admin_password" />
                </div>
            </div>
            <div class="login-button">
                <div>
                    <a class="fa fa-sign-in button js-login-button" data-i18n="Log-in"></a>
                </div>
            </div>
        </div>
    </div>
</div>