
<div class="header-wrapper js-header-wrapper">
    <div class="header">
        <a href="#">
            <!--<img src="images/logo-header.png" class="logo">-->
            <div class="logo"></div>
        </a>
        <a href="javascript:" class="fa fa-bars mobile-menu js-mobile-menu-hamburger" id="mobile-menu"></a>
        <% 
            var cornerMenuPrint = $.extend(true, {}, cornerMenu);

            if (!loggedIn) {
                delete cornerMenuPrint.wat;
                delete cornerMenuPrint.user;
                //delete cornerMenuPrint.help.subMenu.about;
            } 
        %>

        <div class="js-menu-corner menu-corner">
            <ul class="nav-collapse-corner needsclick">
                <% $.each(cornerMenuPrint, function (iMenu, menuOpt) { %>
                    <li class="menu-option needsclick js-menu-option-<%= iMenu %>">
                        <a href="<%= menuOpt.link %>" class="needsclick">
                            <i class="<%= menuOpt.icon %> needsclick"></i>
                            <span class="<%= menuOpt.textClass %> needsclick" data-i18n="<%= menuOpt.text %>"></span>
                        </a>
                        <ul class="js-menu-submenu-<%= iMenu %>">
                            <% $.each(menuOpt.subMenu, function (iSubMenu, subMenuOpt) { %>
                                <li>
                                    <a href="<%= subMenuOpt.link %>" class="js-submenu-option js-submenu-option-<%= iSubMenu %>">
                                        <span class="<%= subMenuOpt.icon %>" data-i18n="<%= subMenuOpt.text %>"></span>
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

<div class="message-container js-message-container">
    <i class="message-close js-message-close fa fa-times-circle"></i>
    <span class="message"></span>
</div>

<div class="wrapper">
    <% if (Wat.C.showServerClock) { %>
    <div class="server-datetime-wrapper js-server-datetime-wrapper">
        <div style="display: none;">
            <i class="fa fa-calendar"></i>
            <span class="js-server-date second_row"></span>
        </div>
        <div data-i18n="[title]Server's time">
            <i class="fa fa-clock-o"></i>
            <span class="js-server-time second_row"></span>
        </div>
    </div>
    <% } %>
    <div class="bb-menu"></div>
    <div class="content bb-content js-content"></div>
    <div class="loading"><i class="fa fa-gear fa-spin"></i></div>
</div>                       
</div>
    <div class="js-responsive-switch responsive-switch <%= !forceDesktop ? 'mobile' : '' %>">
        <% if (forceDesktop) { %>
            <a class="fa fa-mobile button-transparent event js-unforce-desktop" data-i18n="Mobile version"></a>
        <% } else { %>
            <a class="fa fa-desktop button-transparent event js-force-desktop" data-i18n="Desktop version"></a>
        <% } %>
    </div>

<div class="footer"><a href="<%= footerLinks.copyright %>" target="_blank">Qindel Group &copy; <%= new Date().getFullYear() %></a> | <a href="<%= footerLinks.terms %>" data-i18n="Terms of use" target="_blank"></a> | <a href="<%= footerLinks.policy %>" data-i18n="Cookie privacy and data protection" target="_blank"></a> | <a href="<%= footerLinks.contact %>" data-i18n="Contact" target="_blank"></a></div>