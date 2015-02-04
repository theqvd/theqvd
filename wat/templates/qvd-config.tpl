<div class="wrapper-content <%= cid %>"> 
    <div class="menu secondary-menu setup-side">
    <div class="config-search-box">
        <label for="config_search" data-i18n="Search"></label>
        <input name="config_search"/>
    </div>
    <%
        $.each(prefixes, function (iprefix, prefix) {
        var currentClass = '';
        if (selectedPrefix == prefix) {
            currentClass = 'lateral-menu-option--selected';
        }
    %>
            <ul>
                    <li class="lateral-menu-option <%= currentClass %>" data-prefix="<%= prefix %>">
                        <%= prefix %>
                    </li>
            </ul>
    <%
        });
    %>
    
    </div>
    
    <div class="setup-block">
        <div class="action-new-token">
            <a class="js-traductable_button js-button-new actions_button button fa fa-plus-circle" name="btn-new-conf-token" data-i18n="New configuration token"></a>
        </div>
        <div class="bb-config-tokens"></div>
    </div>

</div>