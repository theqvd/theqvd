<div class="details-header">
    <span class="fa fa-user h1"><%= model.get('name') %></span>
    <div class="clear mobile"></div>
    <a class="button2 fright fa fa-eye js-show-details-actions" data-options-state="hidden" data-i18n="Actions"></a>
    
    <% if(Wat.C.checkACL('user.delete.')) { %>
    <a class="button fleft button-icon--desktop js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"><span data-i18n="Delete" class="mobile"></span></a>
    <% } %>
    <% if(Wat.C.checkGroupACL('userEdit')) { %>
    <a class="button fright button-icon--desktop js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"><span data-i18n="Edit" class="mobile"></span></a>
    <% } %>
    
    <% 
    if (Wat.C.checkACL('user.update.block')) {
        if(model.get('blocked')) {
    %>
            <a class="button button-icon--desktop js-button-unblock fa fa-unlock-alt fright" href="javascript:" data-i18n="[title]Unblock"><span data-i18n="Unblock" class="mobile"></span></a>
    <%
        } 
        else { 
    %>
            <a class="button button-icon--desktop js-button-block fa fa-lock fright" href="javascript:" data-i18n="[title]Block"><span data-i18n="Block" class="mobile"></span></a>
    <%
        }
    }
    %>
    
    
    <% 
    if(Wat.C.checkACL('vm.update.disconnect-user')) { 
        var enabled = false;
        if (model.get('number_of_vms_connected') > 0) {
            enabled = true;
        }
    %>
        <a class="button button-icon--desktop js-button-disconnect-all-vms fa fa-plug fright <%= enabled ? '' : 'hidden' %>" data-enabled="<%= enabled %>" href="javascript:" data-i18n="[title]Disconnect"><span data-i18n="Disconnect" class="mobile"></span></a>
    <% 
    } 
    %>
    
    <div class="clear mobile"></div>
</div>

<table class="details details-list <% if (!enabledProperties) { %> col-width-100 <% } %>">
    <%   
    if (Wat.C.isSuperadmin()) { 
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_TENANTS %>"></i><span data-i18n="Tenant"></span></td>
            <td>
                <%= Wat.C.ifACL('<a href="#/tenant/' + model.get('tenant_id') + '">', 'tenant.see-details.') %>
                <%= model.get('tenant_name') %>
                <%= Wat.C.ifACL('</a>', 'tenant.see-details.') %>
            </td>
        </tr>
    <%   
    }
    if (Wat.C.checkACL('user.see.id')) { 
    %>
        <tr>
            <td><i class="fa fa-asterisk"></i><span data-i18n="Id"></span></td>
            <td>
                <%= model.get('id') %>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('user.see.description')) { 
    %>
        <tr>
            <td><i class="fa fa-align-justify"></i><span data-i18n="Description"></span></td>
            <td>
                <% 
                if (model.get('description')) { 
                %>
                    <%= model.get('description').replace(/\n/g, '<br>') %>
                <%
                }
                else {
                %>
                    <span class="second_row">-</span>
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
            <td><i class="fa fa-cloud"></i><span data-i18n="Connected VMs"></span></td>
            <td>
                <% if (model.get('number_of_vms') > 0) { %>
                <%= Wat.C.ifACL('<a href="#/vms/' + Wat.U.transformFiltersToSearchHash({user_id: model.get('id')}) + '">', 'vm.see-main.') %>
                    <span data-wsupdate="number_of_vms_connected" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms_connected') %></span>
                    /
                    <span data-wsupdate="number_of_vms" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms') %></span>
                </a>
                <% } else {%>
                    <span data-wsupdate="number_of_vms_connected" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms_connected') %></span>
                    /
                    <span data-wsupdate="number_of_vms" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms') %></span>
                <% } %>
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
    if (Wat.C.checkACL('user.see.created-by')) {
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_ADMINS %>"></i><span data-i18n="Created by"></span></td>
            <td>
                <span><%= model.get('creation_admin_name') %></span>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('user.see.creation-date')) {
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