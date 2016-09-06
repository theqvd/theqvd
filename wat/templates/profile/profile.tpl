<div class="details-header <%= cid %> sec-profile">
    <span class="fa fa-user h1"><%= login %></span>
    <div class="clear mobile"></div>
    <a class="button2 fright fa fa-eye js-show-details-actions show-details-actions" data-options-state="hidden" data-i18n="Actions"></a>
    
    <a class="button fright button-icon--desktop js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"><span data-i18n="Edit" class="mobile"></span></a>
    
    <div class="clear mobile"></div>
</div>

<table class="details details-list col-width-100">
    <tr>
        <td><i class="<%= CLASS_ICON_TENANTS %>"></i><span data-i18n="Tenant"></span></td>
        <td>
            <span><%= tenantName %></span>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-globe"></i><span data-i18n="Language"></span></td>
        <td>
            <span data-i18n="<%= WAT_LANGUAGE_ADMIN_OPTIONS[language] %>"></span>
            <%
            switch (language) {
                case  'auto':
            %>
                    <div class="second_row" data-i18n="Language will be detected from the browser"></div>
            <%
                    break;
                case 'default':
            %>
                    <div class="second_row" data-i18n="The default language of the system"></div>
            <%
                    break;
            }
            %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-list"></i><span data-i18n="Block size"></span></td>
        <td>
            <% if (block == 0) { %>
                <span data-i18n="Default"></span>
                <div class="second_row" data-i18n="The default block size of the system"></div>
            <% } else { %>
                <span><%= block %></span>
            <% } %>
        </td>
    </tr>
    <%
    if (Wat.C.isMultitenant()) { 
    %>
        <tr>
            <td><i class="fa fa-sitemap"></i><span data-i18n="Global username"></span></td>
            <td>
                 <%= Wat.C.getLoginData() %>
            </td>
        </tr>
    <%   
    }
    %>
    <tr>
        <td><i class="<%= CLASS_ICON_VIEWS %>"></i><span data-i18n="My views"></span></td>
        <td>
            <span class="second_row " data-i18n="Here you can define what columns and filters are shown on each section overriding default views"></span>
            <span class="fright">
                <a href="#/myviews" class="button2 fa fa-pencil" data-i18n="Configure my views"></a>
            </span>
        </td>
    </tr>
</table>