<div class="bb-header"></div>

<div class="message-container js-message-container">
    <i class="message-close js-message-close fa fa-times-circle"></i>
    <span class="message"></span>
</div>

<div class="wrapper">
    <% if (Up.C.showServerClock) { %>
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
    <div class="bb-menu-top menu-top"></div>
    <div class="bb-content content js-content"></div>
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