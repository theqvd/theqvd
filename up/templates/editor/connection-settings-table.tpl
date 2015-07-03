<tr>
    <td>
        <label for="type" class="select-label" data-i18n="Connection type"></label>
    </td>
    <td>
        <%
        if (onlyread) {
        %>
            ADSL
        <%
        }
        else {
        %>
            <select name="type">
                <option value="local">Local</option>
                <option value="adsl">ADSL</option>
                <option value="modem">Modem</option>
            </select>
        <%
        }
        %>
    </td>
</tr>
<tr>
    <td>
        <label for="audio" data-i18n="Enable audio"></label>
    </td>
    <td>
        <%
        if (onlyread) {
        %>
            <i class="fa fa-times"></i>
        <%
        }
        else {
        %>
            <input type="checkbox" name="audio"/>
        <%
        }
        %>
    </td>
</tr>
<tr>
    <td>
        <label for="printing" data-i18n="Enable printing"></label>
    </td>
    <td>

        <%
        if (onlyread) {
        %>
            <i class="fa fa-check"></i>
        <%
        }
        else {
        %>
            <input type="checkbox" name="printing"/>
        <%
        }
        %>
    </td>
</tr>
<tr>
    <td>
        <label for="port_forwarding" data-i18n="Enable port forwarding"></label>
    </td>
    <td>

        <%
        if (onlyread) {
        %>
            <i class="fa fa-check"></i>
        <%
        }
        else {
        %>
            <input type="checkbox" name="port_forwarding"/>
        <%
        }
        %>
    </td>
</tr>
<tr>
    <td>
        <label for="full_screen" data-i18n="Full screen"></label>
    </td>
    <td>

        <%
        if (onlyread) {
        %>
            <i class="fa fa-times"></i>
        <%
        }
        else {
        %>
            <input type="checkbox" name="full_screen"/>
        <%
        }
        %>
    </td>
</tr>