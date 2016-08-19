<% 
    var cornerMenuPrint = $.extend(true, {}, cornerMenu);
    var cornerMenuPrintMobile = $.extend(true, {}, cornerMenu);

    delete cornerMenuPrintMobile.welcome;
%>
        
<div class="bb-header-wrapper header-wrapper js-header-wrapper header-wrapper--section">
    <div class="header">
        <div class="back-button js-back-button <%= CLASS_ICON_HAMBURGER_MENU %>"></div>
        <div class="section-title" data-i18n="<%= sectionTitle %>"><%= sectionTitle %></div>
        <div class="section-sub-title js-section-sub-title"><%= sectionSubTitle %></div>
        <div class="js-menu-corner menu-corner">
            <ul class="nav-collapse-corner needsclick">
                <% $.each(cornerMenuPrintMobile, function (iMenu, menuOpt) { %>
                    <li class="menu-option needsclick js-menu-option-<%= iMenu %> <%= menuOpt.liClass %> <%= section == iMenu ? 'menu-option-current' : '' %>">
                        <% 
                        if (menuOpt.link) { 
                        %>
                            <a href="<%= menuOpt.link %>" class="needsclick">
                                <i class="<%= menuOpt.icon %> needsclick2"></i>
                                <span class="<%= menuOpt.textClass %> needsclick2" data-i18n="<%= menuOpt.text %>"></span>
                            </a>
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