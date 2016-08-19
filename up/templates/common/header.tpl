<div class="bb-header-wrapper header-wrapper js-header-wrapper">
    <div class="header">
        <div class="logo mobile js-header-logo-mobile"></div>
        <div class="logo desktop js-header-logo-desktop"></div>
        <% 
            var cornerMenuPrint = $.extend(true, {}, cornerMenu);
            var cornerMenuPrintMobile = $.extend(true, {}, cornerMenu);

            delete cornerMenuPrintMobile.welcome;
        %>

        <div class="js-menu-corner menu-corner">
            <ul class="nav-collapse-corner needsclick">
                <% $.each(cornerMenuPrint, function (iMenu, menuOpt) { %>
                    <li class="menu-option needsclick js-menu-option-<%= iMenu %> <%= menuOpt.liClass %>">
                        <% 
                        if (menuOpt.link) { 
                        %>
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
                        <% 
                        }
                        else { 
                        %> 
                            <span class="<%= menuOpt.textClass %>" data-i18n="<%= menuOpt.text %>"></span>
                        <% 
                        }
                        %>
                    </li>
                <% }); %>
            </ul>
        </div>
    </div>
</div>