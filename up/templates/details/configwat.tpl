<div class="sec-wat-config">
    <div class="details-header">
    <span class="<%= CLASS_ICON_WATCONFIG %> h1" data-i18n="WAT Config"></span>
    <div class="clear mobile"></div>
    <a class="button2 fright fa fa-eye js-show-details-actions" data-options-state="hidden" data-i18n="Actions"></a>
    
    <% if(Up.C.checkACL('config.wat.')) { %>
    <a class="button fright button-icon--desktop js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"><span data-i18n="Edit" class="mobile"></span></a>
    <% } %>
    
    <div class="clear mobile"></div>
    </div>

    <% 
    if (Up.C.checkACL('config.wat.')) { 
    %>
    <table class="details details-list col-width-100">
        <tr>
            <td><i class="fa fa-globe"></i><span data-i18n="Language"></span></td>
            <td>
                <span data-i18n="<%= WAT_LANGUAGE_TENANT_OPTIONS[model.get('language')] %>"></span>
                <%
                switch (model.get('language')) {
                    case  'auto':
                %>
                        <div class="second_row" data-i18n="Language will be detected from the browser"></div>
                <%
                        break;
                }
                %>
            </td>
        </tr>
        <tr>
            <td><i class="fa fa-list"></i><span data-i18n="Block size"></span></td>
            <td>
                <span><%= model.get('block') %></span>
            </td>
        </tr>
        <% if (Up.C.isSuperadmin() || !Up.C.isMultitenant()) { %>
        <tr class="desktop-row">
            <td><i class="fa fa-paint-brush"></i><span data-i18n="Style customizer tool"></span></td>
            <td>
                <span data-i18n="<%= $.cookie('styleCustomizer') ? 'Enabled' : 'Disabled' %>"></span>
            </td>
        </tr>
        <% } %>
    </table>
    <% 
    } 
    %>
</div>
