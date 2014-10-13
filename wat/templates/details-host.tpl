<div class="details-header">
    <span class="fa fa-hdd-o h1" data-i18n><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('di_delete')) { %>
    <a class="button fleft button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"></a>
    <% } %>
    <% if(Wat.C.checkACL('host_update')) { %>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"></a>
    <% } %>
    
    <% 
    if (Wat.C.checkACL('host_update')) {
        if(model.get('blocked')) {
    %>
            <a class="button button-icon js-button-unblock fa fa-unlock fright" href="javascript:" data-i18n="[title]Unblock"></a>
    <%
        } 
        else { 
    %>
            <a class="button button-icon js-button-block fa fa-lock fright" href="javascript:" data-i18n="[title]Block"></a>
    <%
        }
    }
    %>
    
</div>

<table class="details details-list">
    <tr>
        <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-ellipsis-h"></i><span data-i18n>IP address</span></td>
        <td>
            <%= model.get('address') %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-heart"></i><span data-i18n>State</span></td>
        <td>
            <% 
        if (model.get('state') == 'running') {
            %>
            <span data-i18n>Running</span>
            <%
            }
            else {
            %>
            <span data-i18n>Stopped</span>
            <%
            }
            %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-lock"></i><span data-i18n>Blocking</span></td>
        <td>
            <% 
            if (model.get('blocked')) {
            %>
                <span data-i18n>Blocked</span>
            <%
            }
            else {
            %>
                <span data-i18n>Unblocked</span>
            <%
            }
            %>
        </td>
    </tr>
</table>