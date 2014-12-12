<table>
    <tr>
        <td data-i18n="Default"></td>
        <td>
            <%
            if (model.get('default')) {
            %>
                <div class="second_row" data-i18n="This disk image is already setted as default. To change this, another disk image of the same OSF must be setted as default"></div>
            <%
            }
            else {
            %>
                <input type="checkbox" name="default" value="1">
            <%
            }
            %>
        </td>
    </tr>
    <% 
    if (Wat.C.checkACL('di.update.tags')) { 
    %>
        <tr>
            <td data-i18n="Tags"></td>
            <td>
                <input type="text" class="" name="tags" value="<%= model.get('tags') %>">
            </td>
        </tr>
    <% 
    } 
    %>
 </table>