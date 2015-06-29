<table class="role-template-tools">
    <thead>
        <tr>
            <th class="center">
            </th>
            <%
            $.each(ROLE_TEMPLATE_ACTIONS, function (iRTA, rTA) {
            %>
                <th><%= rTA %></th>
            <%
            });
            %>
        </tr>
    </thead>
    <tbody>
    <%
    $.each(ROLE_TEMPLATE_SCOPE, function (iRTS, rTS) {
    %>
        <tr>
            <th><%= rTS %></th>
            <%
            $.each(ROLE_TEMPLATE_ACTIONS, function (iRTA, rTA) {
                var template = templates[rTS + " " + rTA];
                    
                if (!template) {
                    %>
                        <td></td>
                    <%
                    return;
                }
            %>
                <td data-role-template-cell="<%= rTS %> <%= rTA %>">
                    <input type="checkbox" class="add-template-button js-add-template-button" <%= template.inherited ? 'checked="checked"' : '' %> data-i18n="[title]<%= rTS %> <%= rTA %>" data-role-template-id="<%= template.id %>">
                </td>
            <%
            });
            %>
        </tr>
    <%
    });
    %>
        <tr>
            <th>Master</th>
            <td colspan=7 data-role-template-cell="Master">
            <input type="checkbox" class="add-template-button js-add-template-button" <%= templates["Master"].inherited ? 'checked="checked"' : '' %> title="Master" data-role-template-id="<%= templates["Master"].id %>">
            </td>
        </tr>
        <tr>
            <th>Total Master</th>
            <td colspan=7 data-role-template-cell="Total Master">
                <input type="checkbox" class="add-template-button js-add-template-button" <%= templates["Total Master"].inherited ? 'checked="checked"' : '' %> title="Total Master" data-role-template-id="<%= templates["Total Master"].id %>">
            </td>
        </tr>
    </tbody>
</table>