<table>
    <% 
    if (Wat.C.checkACL('host.update.name')) { 
    %>
        <tr>
            <td data-i18n="Name"></td>
            <td>
                <input type="text" class="" name="name" value="<%= model.get('name') %>" data-required>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('host.update.address')) { 
    %>
        <tr>
            <td data-i18n="Address"></td>
            <td>
                <input type="text" name="address" value="<%= model.get('address') %>">
            </td>
        </tr>
    <% 
    }
    %>
 </table>