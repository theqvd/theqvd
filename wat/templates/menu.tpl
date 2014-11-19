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
<div class="js-setup-menu menu desktop">
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