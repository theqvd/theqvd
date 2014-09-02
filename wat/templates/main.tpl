<div class="header-wrapper">
    <div class="header">
        <a href="#">
            <img src="images/qvd-logo-header-trans.png" class="logo">
        </a>
        <a href="javascript:" class="fa fa-bars mobile-menu js-mobile-menu" id="mobile-menu"></a>
        <% if (loggedIn) { %>
            <div class="js-menu-corner menu-corner">
                <ul class="nav-collapse-corner">
                    <li class="menu-option">
                        <a href="#">
                            <i class="fa fa-support"></i>
                            <span data-i18n>Help</span>
                        </a>
                        <ul>
                            <li>
                                <a href="#">
                                    <span class="fa fa-book" data-i18n>Documentation</span>
                                </a>
                            </li>
                            <li>
                                <a href="#">
                                    <span class="fa fa-asterisk" data-i18n>About</span>
                                </a>
                            </li>
                        </ul>
                    </li>
                    <li class="menu-option menu-option--selected">
                        <a href="#">
                            <i class="fa fa-wrench"></i>
                            <span data-i18n>Setup</span>
                        </a>
                        <ul>
                            <li>
                                <a href="#">
                                    <span class="fa fa-suitcase" data-i18n>Admins</span>
                                </a>
                            </li>
                            <li>
                                <a href="#">
                                    <span class="fa fa-building" data-i18n>Tenants</span>
                                </a>
                            </li>
                            <li>
                                <a href="#">
                                    <span class="fa fa-file-text-o" data-i18n>Config</span>
                                </a>
                            </li>
                            <li>
                                <a href="#/setup/customize">
                                    <span class="fa fa-columns" data-i18n>Customize</span>
                                </a>
                            </li>
                        </ul>
                    </li>
                    <li class="menu-option">
                        <a href="javascript:">
                            <i class="fa fa-user"></i>
                            <span class="login"></span>
                        </a>
                        <ul>
                            <li>
                                <a href="#">
                                    <span class="fa fa-power-off" data-i18n>Log-out</span>
                                </a>
                            </li>
                        </ul>
                    </li>
                </ul>
            </div>
        <% } %>

        </div>
</div>
<div class="wrapper"> 
    <% if (loggedIn) { %>
        <div class="menu">
            <ul class="nav-collapse">
                <li class="menu-option" data-target="users">
                    <i class="<%= CLASS_ICON_USERS %>"></i>
                    <span data-i18n>Users</span>
                </li>
                <li class="menu-option" data-target="vms">
                    <i class="<%= CLASS_ICON_VMS %>"></i>
                    <span data-i18n>Virtual machines</span>
                </li>
                <li class="menu-option" data-target="hosts">
                    <i class="<%= CLASS_ICON_NODES %>"></i>
                    <span data-i18n>Nodes</span>
                </li>
                <li class="menu-option" data-target="osfs">
                    <i class="<%= CLASS_ICON_OSFS %>"></i>
                    <span data-i18n>OS Flavours</span>
                </li>
                <li class="menu-option" data-target="dis">
                    <i class="<%= CLASS_ICON_DIS %>"></i>
                    <span data-i18n>Disk images</span>
                </li>
            </ul>
        </div>
        <div id="breadcrumbs" class="breadcrumbs desktop"></div>
    <% } %>
    <div class="loading"><i class="fa fa-gear fa-spin"></i></div>

    <div class="message-container js-message-container">
        <i class="message-close js-message-close fa fa-times-circle"></i>
        <span class="message"></span>
    </div>
    <div class="content bb-content"></div>                        
</div>
<div class="footer" data-link="<a href='http://qindel.com'>Qindel Group</a>"></div>