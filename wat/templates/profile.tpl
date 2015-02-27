<div class="details-header">
    <span class="fa fa-user h1"><%= login %></span>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"></a>
</div>

<table class="details details-list col-width-100">
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
</table>