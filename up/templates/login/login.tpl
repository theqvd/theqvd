<div class="login-wrapper sec-login">
    <div class="login-box">
        <iframe id="remember" name="remember" class="hidden" src="remember.html"></iframe>
        <div class="login-main">
            <div class="logo-login"></div>
            <div class="header1-login">QVD</div>
            <div class="header2-login">Administrator panel</div>
            <form class="login-form js-login-form" target="remember" method="post" action="index.html">
                <div class="login-form">
                    <div class="login-control">
                        <div>
                            <input type="text" name="admin_user" data-i18n="[placeholder]User"/>
                        </div>
                    </div>
                    <div class="login-control">
                        <div>
                            <input type="password" name="admin_password" data-i18n="[placeholder]Password"/>
                        </div>
                    </div>
                    <% if (loginLinkSrc && loginLinkLabel) { %>
                        <div class="login-control login-link">
                            <a target="_blank" href="<%= loginLinkSrc %>" data-i18n="<%= loginLinkLabel %>"><%= loginLinkLabel %></a>
                        </div>
                    <% } %>
                    <div class="login-button">
                        <a class="button js-login-button" data-i18n="Log-in"></a>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>