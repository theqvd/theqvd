<%
    var hooks = pluginData.attributes;
    $.each(hooks, function (i, hook) {
        %>
            <div>
                <span>- <%= hook.name %><span>
                <div class="second_row"><%= hook.hookType %></div>
            </div>
        <%
    });

    if (Object.keys(hooks).length == 0) {
        %>
        <span class="second_row" data-i18n="No elements found"></span>
        <%
    }
%>