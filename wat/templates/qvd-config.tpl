<div class="wrapper-content <%= cid %>"> 
    <div class="menu secondary-menu setup-side">
    
    <%
        $.each(prefixes, function (iprefix, prefix) {
        var currentClass = '';
        if (selectedPrefix == prefix) {
            currentClass = 'token-prefix-option--selected';
        }
    %>
            <ul>
                    <li class="token-prefix-option <%= currentClass %>" data-prefix="<%= prefix %>">
                        <%= prefix %>
                    </li>
            </ul>
    <%
        });
    %>
    
    </div>
    
    <div class="setup-block">
    <div class="action-new-token">
        <a class="js-traductable_button js-button-new actions_button button fa fa-plus-circle" name="btn-new-conf-token" data-i18n>
            New configuration token
        </a>
    </div>
    <div class="bb-config-tokens"></div>
    </div>

</div>