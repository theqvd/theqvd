<table class="list config-table">
<%
var prefixes = [];
var prefix = '';
var miscTokens = [];

if (!configTokens || configTokens.length == 0) {
%>
    <tr>
        <td data-i18n="No elements found"></td>
    </tr>
<%
}

$.each(configTokens, function (iTok, tok) {
    var token = tok.key;
    var value = tok.operative_value;
    var dvalue = tok.default_value;
    var isDefault = tok.is_default;

    var tokenSplitted = token.split('.');
    var prefix = tokenSplitted[0];
%>
    <tr class="js-token-row token-row" data-prefix="<%= prefix %>">
        <td>
            <%= _.escape(token) %>

            <%
            if (QVD_CONFIG_HELP[token] != undefined) {
            %>
                <div class="second_row token_description"><%= QVD_CONFIG_HELP[token] %></div>
            <%
            }
            %>
        </td>
        <td style="width: 300px;">
            <input 
                type="text" 
                value="<%= value %>" 
                style="width:100%" 
                class="token-value js-token-value" 
                data-is-default="<%= isDefault %>" 
                data-token="<%= token %>"
            >
            <div class="second_row hidden js-not-saved" data-token="<%= token %>">
                <span class="second_row fleft fa fa-warning" data-i18n="Not saved"></span>
                <a 
                    class="js-traductable_button button2 js-reset-token fright fa fa-rotate-left" 
                    data-value="<%= value %>" 
                    data-is-default="<%= isDefault %>" 
                    data-token="<%= token %>" 
                    data-i18n="Reset;[title]Reset token to saved value"
                >
                </a>
            </div>
            <div class="second_row hidden js-will-delete" data-token="<%= token %>">
                <span class="second_row fleft fa fa-warning" data-i18n="Will be deleted"></span>
                <a 
                    class="js-traductable_button button2 js-reset-token fright fa fa-rotate-left" 
                    data-value="<%= value %>" 
                    data-is-default="<%= isDefault %>" 
                    data-is-created="<%= dvalue == undefined ? 1 : 0 %>" 
                    data-token="<%= token %>" 
                    data-i18n="Undo;[title]Undo deletion"
                >
                </a>
            </div>
        </td>
        <td style="width: 250px;" class="token-actions-col">
            <% if (dvalue == undefined) { %>
                <a class="js-traductable_button js-delete-token button2 fa fa-trash" data-token="<%= token %>" data-i18n="Delete"></a>
            <% } else if (!isDefault) { %>
                <a class="js-traductable_button js-restore-token-default button2 fa fa-chevron-left" data-token="<%= token %>" data-default-value="<%= dvalue %>" data-i18n="Default value;[title]Reset token to default value"></a>
                <div class="second_row js-default-value fa fa-info-circle hidden" data-token="<%= token %>" data-i18n="Default value"></div>
            <% } else { %>
                <div class="second_row js-default-value fa fa-info-circle" data-token="<%= token %>" data-i18n="Default value"></div>
            <% } %>
        </td>
    </tr>
<%
});
%>
</table>