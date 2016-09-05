<table class="roles-inherit-table">
    <tr>
        <td>
            <%
                var classFixed = '';
                if (model.get('fixed') && RESTRICT_TEMPLATES) {
                    classFixed = 'hidden';
                }

                var elementsCount = 0;
                $.each(model.get('roles'), function (iRole, role) {
                    switch (inheritFilter) {
                        case "templates":
                            if (!role.internal) {
                                return;
                            }
                            break;
                        case "roles":
                            if (role.internal) {
                                return;
                            }
                            break;
                    }
                    elementsCount++;
            %>
                <div>
                    <%
                    // If restrict templates flag is disabled, show templates with link like roles
                    if (role.internal && RESTRICT_TEMPLATES) {
                    %>
                        <span class="text"><%= role.name %></span>
                    <%
                    }
                    else {
                    %>
                        <%= Wat.C.ifACL('<a href="#/role/' + iRole + '">', 'role.see-details.') %>
                        <span class="text"><%= role.name %></span>
                        <%= Wat.C.ifACL('</a>', 'role.see-details.') %>
                    <%
                    }
                    %>
                </div>
            <%
                }); 
            %>  
            <%
                if (elementsCount == 0) {
            %>
                    <span data-i18n="No elements found" class="second_row"></span>
            <%
                }
            %>
        </td>
    </tr>
</table>