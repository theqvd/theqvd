<div class="details-header">
    <span class="fa fa-hdd-o h1"><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('host.delete.')) { %>
    <a class="button fleft button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"></a>
    <% } %>
    <% if(Wat.C.checkGroupACL('hostEdit')) { %>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"></a>
    <% } %>
    
    <% 
    if (Wat.C.checkACL('host.update.block')) {
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

<table class="details details-list <% if (!enabledProperties) { %> col-width-100 <% } %>">
    <% 
    if (detailsFields['id'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-male"></i><span data-i18n="Id"></span></td>
            <td>
                <%= model.get('id') %>
            </td>
        </tr>  
    <% 
    }
    if (detailsFields['address'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-ellipsis-h"></i><span data-i18n="IP address"></span></td>
            <td>
                <%= model.get('address') %>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['state'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-heart"></i><span data-i18n="State"></span></td>
            <td>
                <% 
            if (model.get('state') == 'running') {
                %>
                <span data-i18n data-wsupdate="state-text" data-id="<%= model.get('id') %>">Running</span>
                <%
                }
                else {
                %>
                <span data-i18n data-wsupdate="state-text" data-id="<%= model.get('id') %>">Stopped</span>
                <%
                }
                %>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['block'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-lock"></i><span data-i18n="Blocking"></span></td>
            <td>
                <% 
                if (model.get('blocked')) {
                %>
                    <span data-i18n="Blocked"></span>
                <%
                }
                else {
                %>
                    <span data-i18n="Unblocked"></span>
                <%
                }
                %>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['connected_vms'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-cloud"></i><span data-i18n="Running VMs"></span></td>
            <td>
                <% if (model.get('number_of_vms_connected') > 0) { %>
                <%= Wat.C.ifACL('<a href="#/vms/host/' + model.get('id') + '">', 'vm.see-main.') %>
                    <span data-wsupdate="number_of_vms_connected" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms_connected') %></span>
                </a>
                <% } else {%>
                    <span data-wsupdate="number_of_vms_connected" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms_connected') %></span>
                <% } %>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('host.see.created-by')) {
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_ADMINS %>"></i><span data-i18n="Created by"></span></td>
            <td>
                <span><%= model.get('creation_admin_name') %></span>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('host.see.creation-date')) {
    %>
        <tr>
            <td><i class="fa fa-clock-o"></i><span data-i18n="Creation date"></span></td>
            <td>
                <span><%= model.get('creation_date') %></span>
            </td>
        </tr>
    <% 
    }
    %>
    <tbody class="bb-properties"></tbody>
</table>