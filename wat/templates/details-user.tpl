<div class="details-header">
    <span class="fa fa-user h1" data-i18n><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('user_delete')) { %>
    <a class="button fleft button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"></a>
    <% } %>
    <% if(Wat.C.checkACL('user_update')) { %>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"</a>
    <% } %>
    
    <% 
    if (Wat.C.checkACL('user_update')) {
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
    
    
    <% if(Wat.C.checkACL('user_update') && model.get('number_of_vms_connected') > -10) { %>
        <a class="button button-icon js-button-disconnect-all-vms fa fa-plug fright" href="javascript:" data-i18n="[title]Disconnect from all VMS"></a>
    <% } %>
</div>

<table class="details details-list">
    <tr>
        <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-cloud"></i><span data-i18n>Connected VMs</span></td>
        <td>
            <%= model.get('number_of_vms_connected') %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-lock"></i><span data-i18n>Blocking</span></td>
        <td>
            <% 
            if (model.get('blocked')) {
            %>
                <!--
                <i class="fa fa-lock" data-i18n="[title]Blocked"></i>
                -->
                <span data-i18n>Blocked</span>
            <%
            }
            else {
            %>
                <!--
                <i class="fa fa-unlock" data-i18n="[title]Unblocked"></i>
                -->
                <span data-i18n>Unblocked</span>
            <%
            }
            %>
        </td>
    </tr>
</table>