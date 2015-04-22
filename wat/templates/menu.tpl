<div class="desktop">
    <div class="js-platform-menu menu" style="display: none;">
        <ul>
            <%
                $.each(menu, function (target, option) {
            %>
                <li class="menu-option" data-target="<%= target %>" data-menu="platform">
                    <i class="<%= option.icon %>"></i>
                    <span data-i18n="<%= option.text %>"></span>
                </li>
            <%
                });
            %>
        </ul>
    </div>
    <div class="js-wat-menu menu" style="display: none;">
        <ul>
            <%
                $.each(setupMenu, function (target, option) {
            %>
                <li class="menu-option" data-target="<%= target %>" data-menu="wat">
                    <i class="<%= option.icon %>"></i>
                    <span data-i18n="<%= option.text %>"></span>
                </li>
            <%
                });
            %>
        </ul>
    </div>
    <div class="js-config-menu menu" style="display: none;">
        <ul>
            <%
                $.each(configMenu, function (target, option) {
            %>
                <li class="menu-option" data-target="<%= target %>" data-menu="config">
                    <i class="<%= option.icon %>"></i>
                    <span data-i18n="<%= option.text %>"></span>
                </li>
            <%
                });
            %>
        </ul>
    </div>
    <div class="js-help-menu menu" style="display: none;">
        <ul>
            <%
                $.each(helpMenu, function (target, option) {
            %>
                <li class="menu-option" data-target="<%= target %>" data-menu="help">
                    <i class="<%= option.icon %>"></i>
                    <span data-i18n="<%= option.text %>"></span>
                </li>
            <%
                });
            %>
        </ul>
    </div>
    <div class="js-user-menu menu" style="display: none;">
        <ul>
            <%
                $.each(userMenu, function (target, option) {
            %>
                <li class="menu-option" data-target="<%= target %>" data-menu="user">
                    <i class="<%= option.icon %>"></i>
                    <span data-i18n="<%= option.text %>"></span>
                </li>
            <%
                });
            %>
        </ul>
    </div>
</div>
<div class="menu mobile js-menu-mobile">
    <ul class="nav-collapse">
        <%
            $.each(mobileMenu, function (target, option) {
        %>
            <li class="menu-option" data-target="<%= target %>">
                <i class="<%= option.icon %>"></i>
                <span data-i18n="<%= option.text %>"></span>
            </li>
        <%
            });
        %>
    </ul>
</div>
<div id="breadcrumbs" class="breadcrumbs desktop"></div>
<div class="desktop filter-notes js-filter-notes hidden">
    <i class="fa fa-filter" data-i18n="">Enabled filters</i>
    <ul class="filter-notes-list js-filter-notes-list">
    </ul>
</div>