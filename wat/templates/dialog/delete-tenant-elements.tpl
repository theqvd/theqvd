<tr>
    <td style="font-weight: bold;"><span data-qvd-obj="<%= elementQvdObj %>" class="js-counter"><%= registers.length %></span> x <span data-i18n="<%= elementName %>"></span></td>
    <td>
        <% 
        if (registers.length) {
            %>
            <ul data-qvd-obj="<%= elementQvdObj %>" class="js-list" style="max-height: 100px; overflow-y: auto;">
            <%
                        
            $.each(registers, function (iReg, reg) {
                var attrs = '';
                if (errors && errors[reg[idField]]) { 
                    attrs = 'class="fa fa-warning" data-i18n="[title]' + errors[reg[idField]].message + '"';
                }
                %>
                    <li data-id="<%= reg[idField] %>">
                        <i class="fa fa-trash delete-element-button js-button-delete-tenant-element" data-i18n="[title]Delete" data-id="<%= reg[idField] %>" data-qvd-obj="<%= elementQvdObj %>"></i>
                        <span <%= attrs %> style="font-size: 0.9em;"><%= reg[nameField] %></span>
                    </li>
                <%
            });
            %>
            </ul>
            <%
        } 
        %>
    </td>
    <td style="width: 40px;">
        <% 
        if (registers.length) {
        %>
            <a class="button fleft button-icon--desktop js-button-delete-tenant-object fa fa-trash" data-qvd-obj="<%= elementQvdObj %>" href="javascript:" data-i18n="[title]Delete all elements of this kind"><span data-i18n="Delete" class="mobile"></span></a>
        <%
        } 
        %>
    </td>
</tr>
