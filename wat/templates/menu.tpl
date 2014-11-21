<div class="js-platform-menu menu desktop">
    <ul>
        <%
            $.each(menu, function (target, option) {
        %>
            <li class="menu-option" data-target="<%= target %>">
                <i class="<%= option.icon %>"></i>
                <span data-i18n><%= option.text %></span>
            </li>
        <%
            });
        %>
    </ul>
</div>
<div class="js-wat-management-menu menu desktop">
    <ul>
        <%
            $.each(setupMenu, function (target, option) {
        %>
            <li class="menu-option" data-target="<%= target %>">
                <i class="<%= option.icon %>"></i>
                <span data-i18n><%= option.text %></span>
            </li>
        <%
            });
        %>
    </ul>
</div>
<div class="js-qvd-config-menu menu desktop">
    <ul>
        <%
            $.each(configMenu, function (target, option) {
        %>
            <li class="menu-option" data-target="<%= target %>">
                <i class="<%= option.icon %>"></i>
                <span data-i18n><%= option.text %></span>
            </li>
        <%
            });
        %>
    </ul>
</div>
<div class="menu mobile js-menu-mobile">
    <ul class="nav-collapse">
        <%
            $.each(mobileMenu, function (target, option) {
        %>
            <li class="menu-option" data-target="<%= target %>">
                <i class="<%= option.icon %>"></i>
                <span data-i18n><%= option.text %></span>
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