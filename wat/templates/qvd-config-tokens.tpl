<table class="list config-table">
<%
var prefixes = [];
var prefix = '';
var miscTokens = [];

$.each(configTokens, function (iTok, tok) {
    var token = tok.key;
    var value = tok.operative_value;
    var dvalue = tok.default_value;


    var tokenSplitted = token.split('.');
    var prefix = tokenSplitted[0];
%>
    <tr class="js-token-row" data-prefix="<%= prefix %>">
        <td style="text-align: left; vertical-align: middle;">
            <%= token %>
        </td>
        <td style="width: 250px;">
            <input type="text" value="<%= value %>" style="width:100%" class="token-value" data-token="<%= token %>">
        </td>
        <td style="width: 300px;">
            <select data-token="<%= token %>" class="token-action-select">
                <option value="save" data-i18n="Save"></option>
            <%
                if (dvalue == undefined) {
            %>
                    <option value="delete" data-i18n="Delete"></option>
            <% } else if (dvalue != value) { %>
                    <option value="set_default" data-i18n="Restore to default value"></option>
            <% } %>
            </select>
            <a class="js-traductable_button actions_button button fa fa-cog" class="token_actions_button" data-token="<%= token %>" data-i18n="Apply"></a>
        </td>
    </tr>
<%
});
%>
</table>