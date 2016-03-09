<tr>
    <td style="font-weight: bold;"><span data-qvd-obj="<%= elementQvdObj %>" class="js-counter"><%= registers.length %></span> x <%= elementName %></td>
    <td>
        <% 
        if (registers.length) {
            %>
            <ul data-qvd-obj="<%= elementQvdObj %>" class="js-list">
            <%
            $.each(registers, function (iReg, reg) {
                %>
                    <li data-id="<%= reg.id %>"><%= reg[nameField] %></li>
                <%
            });
            %>
            </ul>
            <%
        } 
        %>
    </td>
</tr>
