<table class="roles-inherit-tools-table">
    <tr class="inherit-template">
        <td colspan=2>
            <table class="role-template-matrix">
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
                <%
                $.each(ROLE_TEMPLATE_SCOPE, function (iRTS, rTS) {
                %>
                    <tr>
                        <th><%= rTS %></th>
                        <%
                        $.each(ROLE_TEMPLATE_ACTIONS, function (iRTA, rTA) {
                        %>
                            <td data-role-template-cell="<%= rTS %> <%= rTA %>">
                                <input type="checkbox" class="add-template-button js-add-template-button invisible" data-i18n="[title]<%= rTS %> <%= rTA %>">
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
                        <input type="checkbox" class="add-template-button js-add-template-button invisible" title="Master">
                        </td>
                    </tr>
                    <tr>
                        <th>Total Master</th>
                        <td colspan=7 data-role-template-cell="Total Master">
                            <input type="checkbox" class="add-template-button js-add-template-button invisible" title="Total Master">
                        </td>
                    </tr>
            </table>
        </td>
    </tr>
</table>