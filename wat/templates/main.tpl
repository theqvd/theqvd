<div class="header-wrapper">
    <div class="header">
        <a href="#">
            <img src="images/qvd-logo-header-trans.png" class="logo">
        </a>
        <a href="javascript:" class="fa fa-bars mobile-menu js-mobile-menu" id="mobile-menu"></a>
        <% 
            var cornerMenuPrint = $.extend(true, {}, cornerMenu);
            if (!loggedIn) {
                delete cornerMenuPrint.setup;
                delete cornerMenuPrint.user;
            } 
        %>

        <div class="js-menu-corner menu-corner">
            <ul class="nav-collapse-corner">
                <% $.each(cornerMenuPrint, function (iMenu, menuOpt) { %>
                    <li class="menu-option">
                        <a href="<%= menuOpt.link %>">
                            <i class="<%= menuOpt.iconClass %>"></i>
                            <span class="<%= menuOpt.textClass %>" data-i18n><%= menuOpt.text %></span>
                        </a>
                        <ul>
                            <% $.each(menuOpt.subMenu, function (iSubMenu, subMenuOpt) { %>
                                <li>
                                    <a href="<%= subMenuOpt.link %>">
                                        <span class="<%= subMenuOpt.iconClass %>" data-i18n><%= subMenuOpt.text %></span>
                                    </a>
                                </li>
                            <% }); %>
                        </ul>
                    </li>
                <% }); %>
            </ul>
        </div>

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