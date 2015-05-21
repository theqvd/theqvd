<div class="details-header">
    <span class="<%= CLASS_ICON_WATCONFIG %> h1" data-i18n="WAT Config"></span>
    <% if(Wat.C.checkACL('config.wat.')) { %>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"></a>
    <% } %>
</div>

<% 
if (Wat.C.checkACL('config.wat.')) { 
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
    </table>
<% 
} 
%>
