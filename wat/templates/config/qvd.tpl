<div class="wrapper-content <%= cid %> sec-qvd-config"> 
    <div class="menu secondary-menu setup-side">
    <% if (Wat.C.isMultitenant() && Wat.C.isSuperadmin()) { %>
        <div class="config-search-box">
            <label for="tenant_search" data-i18n="Tenant"></label>
            <select class="" name="tenant_id" id="tenant_search"></select>
        </div>
    <% } %>
    <div class="config-search-box">
        <label for="config_search" data-i18n="Search"></label>
        <input name="config_search" data-i18n="[placeholder]Write and press enter"/>
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
        <div class="action-token-top">
            <% if (isCreationAllowed) { %>
                <a class="js-traductable_button js-button-new actions_button button fa fa-plus-circle" name="btn-new-conf-token" data-i18n="New configuration token"></a>
            <% } %>
            <a class="fright js-traductable_button js-button-save actions_button button fa fa-save" name="btn-save-conf-token" data-i18n="Save all"></a>
        </div>
        <div class="bb-config-tokens"></div>
        <div class="action-token-bottom">
            <a class="fright js-traductable_button js-button-save actions_button button fa fa-save" name="btn-save-conf-token" data-i18n="Save all"></a>
        </div>
    </div>

</div>

<a class="back-top-button js-back-top-button js-back-top-generic-button fa fa-arrow-up button2" style="display:none;" data-i18n>Go top</a>
