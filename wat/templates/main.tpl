
<div class="header-wrapper">
    <div class="header">
        <a href="#">
            <img src="images/qvd-logo-header-trans.png" class="logo">
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
            <ul class="nav-collapse-corner">
                <% $.each(cornerMenuPrint, function (iMenu, menuOpt) { %>
                    <li class="menu-option js-menu-option-<%= iMenu %>">
                        <a href="<%= menuOpt.link %>">
                            <i class="<%= menuOpt.icon %>"></i>
                            <span class="<%= menuOpt.textClass %>" data-i18n><%= menuOpt.text %></span>
                        </a>
                        <ul>
                            <% $.each(menuOpt.subMenu, function (iSubMenu, subMenuOpt) { %>
                                <li>
                                    <a href="<%= subMenuOpt.link %>">
                                        <span class="<%= subMenuOpt.icon %>" data-i18n><%= subMenuOpt.text %></span>
                                    </a>
                                </li>
                            <% }); %>
                        </ul>
                    </li>
                <% }); %>
            </ul>
        </div>

        </div>
        <div class="message-container js-message-container">
            <i class="message-close js-message-close fa fa-times-circle"></i>
            <span class="message"></span>
        </div>
</div>
<div class="wrapper">
    <div class="bb-menu"></div>
    <div class="loading"><i class="fa fa-gear fa-spin"></i></div>

    <div class="content bb-content"></div>                        
</div>
<div class="footer" data-link="<a href='http://qindel.com'>Qindel Group</a>"></div>