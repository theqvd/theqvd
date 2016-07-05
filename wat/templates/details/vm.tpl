<%
// Show state table if is granted. Hide it otherwise
var mainTableClass = '';
var stateTableClass = 'hidden';

if (Wat.C.checkACL('vm.see.state')) {
    stateTableClass = 'details-right';
}
%>

<div class="details-header">
    <span class="fa fa-cloud h1"><%= model.get('name') %></span>
    <div class="clear mobile"></div>
    <a class="button2 fright fa fa-eye js-show-details-actions" data-options-state="hidden" data-i18n="Actions"></a>
    
    <% if(Wat.C.checkACL('vm.delete.')) { %>
    <a class="button fleft button-icon--desktop js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"><span data-i18n="Delete" class="mobile"></span></a>
    <% } %>
    
    <% if(Wat.C.checkGroupACL('vmEdit')) { %>
    <a class="button fright button-icon--desktop js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"><span data-i18n="Edit" class="mobile"></span></a>
    <% } %>
    
    <% 
    // Start-stop button only will be shown here if state table is hidden
    if (Wat.C.checkACL('vm.update.state') && stateTableClass == 'hidden') {
        if (model.get('state') != 'stopped') { 
    %>
        <a class="button fright button-icon--desktop js-button-stop-vm <%= CLASS_ICON_STATUS_STOPPED %> fright" href="javascript:" data-i18n="[title]Stop" data-wsupdate="state-button" data-id="<%= model.get('id') %>"><span data-i18n="Stop" class="mobile"></span></a>
    <% 
        }
        else { 
    %>
        <a class="button fright button-icon--desktop js-button-start-vm <%= CLASS_ICON_STATUS_RUNNING %> fright" href="javascript:" data-i18n="[title]Start" data-wsupdate="state-button" data-id="<%= model.get('id') %>"><span data-i18n="Start" class="mobile"></span></a>
    <% 
        }
    } 
    %>
    
    <% 
    if (Wat.C.checkACL('vm.update.block')) {
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
    if (Wat.C.checkACL('vm.update.disconnect-user')) {
    %>
        <a class="button button-icon js-button-disconnect-user fa fa-plug fright <%= model.get('user_state') != 'connected' ? 'hidden' : '' %>" href="javascript:" data-wsupdate="user_state-button" data-i18n="[title]Disconnect user"><span data-i18n="Disconnect user" class="mobile"></span></a>
    <%
    }
    %>
    
    <% 
    if (Wat.C.checkACL('vm.update.state')) {
        if (model.get('state') != 'stopped') { 
    %>
            <a class="button fright button-icon--desktop js-button-stop-vm fa fa-stop fright mobile" href="javascript:" data-i18n="[title]Stop" data-wsupdate="state-button" data-id="<%= model.get('id') %>"><span data-i18n="Stop" class="mobile"></span></a>
    <% 
        }
        else { 
    %>
            <a class="button fright button-icon--desktop js-button-start-vm fa fa-play fright mobile" href="javascript:" data-i18n="[title]Start" data-wsupdate="state-button" data-id="<%= model.get('id') %>"><span data-i18n="Start" class="mobile"></span></a>
    <% 
        }
    } 
        if (Wat.C.checkACL('vm.spy.') && model.get('state') == 'running') { 
    %>
            <a class="button fright button-icon--desktop js-button-spy-vm fa fa-user-secret fright" href="javascript:" data-i18n="[title]Spy" data-wsupdate="spy-button" data-id="<%= model.get('id') %>"><span data-i18n="Spy" class="mobile"></span></a>
    <% 
        }
    %>
        
    <div class="clear mobile"></div>
</div>

<% 
// Show state info fields if is granted any of contained fields. Hide it otherwise
var showStateInfo = false;

if (Wat.C.checkGroupACL('vmStateInfoDetails')) {
    showStateInfo = true;
}

// Show vm status table depend on the returned state
var runningStyle = 'display: none;';
var stoppedStyle = 'display: none;';
var startingStyle = 'display: none;';
var stoppingStyle = 'display: none;';

switch (model.get('state')) {
    case 'running':
        var runningStyle = '';
        break;
    case 'stopped':
        var stoppedStyle = '';
        break;
    case 'starting':
        var startingStyle = '';
        break;
    case 'stopping':
        var stoppingStyle = '';
        break;
}

%>

<table class="details details-list <%= mainTableClass %>">
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
    if (Wat.C.checkACL('vm.see.id')) { 
    %>
        <tr>
            <td><i class="fa fa-asterisk"></i><span data-i18n="Id"></span></td>
            <td>
                <%= model.get('id') %>
            </td>
        </tr>
    <% 
    }  
    if (Wat.C.checkACL('vm.see.description')) { 
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
    if (Wat.C.checkACL('vm.see.user')) {
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_USERS %>"></i><span data-i18n="User"></span></td>
            <td>
                <%= Wat.C.ifACL('<a href="#/user/' + model.get('user_id') + '" data-i18n="[title]Click for details">', 'user.see-details.') %>
                    <%= model.get('user_name') %>
                <%= Wat.C.ifACL('</a>', 'user.see-details.') %>
                
                <% 
                if (Wat.C.checkACL('vm.see.user-state')) { 
                    if (model.get('user_state') == 'connected') {
                %>
                        (<span data-i18n data-wsupdate="user_state-text" data-id="<%= model.get('id') %>">Connected</span>)
                <%
                    }
                    else {
                %>
                        (<span data-i18n data-wsupdate="user_state-text" data-id="<%= model.get('id') %>">Disconnected</span>)
                <%
                    }
                }
                %>
                </td>
        </tr>  
    <% 
    } 
    if (Wat.C.checkACL('vm.see.state')) {
    %>
        <tr class="mobile">
            <td><i class="fa fa-heart"></i><span data-i18n="State"></span></td>
            <td data-wsupdate="state-text" data-id="<%= model.get('id') %>">
                <%= DICTIONARY_STATES[model.get('state')] %>
            </td>
        </tr>  
    <% 
    }
    if (!Wat.C.checkACL('vm.see.user') && Wat.C.checkACL('vm.see.user-state')) {
    %>
        <tr>
            <td><i class="fa fa-plug"></i><span data-i18n="User state"></span></td>
            <td>
                <% 
                if (model.get('user_state') == 'connected') {
                %>
                    <span data-i18n data-wsupdate="user_state-text" data-id="<%= model.get('id') %>">Connected</span>
                <%
                }
                else {
                %>
                    <span data-i18n data-wsupdate="user_state-text" data-id="<%= model.get('id') %>">Disconnected</span>
                <%
                }
                %>
                </td>
        </tr>  
    <% 
    }
    if (Wat.C.checkACL('vm.see.ip')) {
    %>
        <tr>
            <td><i class="fa fa-ellipsis-h"></i><span data-i18n="IP address"></span></td>
            <td>
                <%= model.get('ip') %>
            </td>
        </tr>  
    <% 
    }
    if (Wat.C.checkACL('vm.see.mac')) {
    %>
        <tr>
            <td><i class="fa fa-ellipsis-h"></i><span data-i18n="MAC address"></span></td>
            <td>
                <%= model.get('mac') %>
            </td>
        </tr>  
    <% 
    }
    if (Wat.C.checkACL('vm.see.osf')) {
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_OSFS %>"></i><span data-i18n="OS Flavour"></span></td>
            <td>
                <%= Wat.C.ifACL('<a href="#/osf/' + model.get('osf_id') + '" data-i18n="[title]Click for details">', 'osf.see-details.') %>
                    <%= model.get('osf_name') %>
                <%= Wat.C.ifACL('</a>', 'osf.see-details.') %>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('vm.see.di-tag')) {
    %>
        <tr>
            <td><i class="fa fa-tag"></i><span data-i18n="Image tag"></span></td>
            <td>
                <%= model.get('di_tag') %>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('vm.see.di')) {
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_DIS %>"></i><span data-i18n="Disk image"></span></td>
            <td>
                <%= Wat.C.ifACL('<a href="#/di/' + model.get('di_id') + '" data-i18n="[title]Click for details">', 'di.see-details.') %>
                    <%= model.get('di_name') %>
                <%= Wat.C.ifACL('</a>', 'di.see-details.') %>
                <%
                    if (model.get('state') == 'running' && model.get('di_id') != model.get('di_id_in_use')) {
                %>
                        <i class="fa fa-warning warning" data-wsupdate="di_warning_icon" data-id="<%= model.get('id') %>" data-i18n="[title]The virtual machine is running with different image - Restart it to update it to new image"></i>
                <%
                    }
                %>
                <div class="second_row"><span data-i18n="Version"></span>: <%= model.get('di_version') %></span>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('vm.see.expiration')) {
    %>
        <tr class="bb-vm-details-expiration" data-wsupdate="expiration_soft-row" data-id="<%= model.get('id') %>" data-expiration_soft="<%= model.get('expiration_soft') %>" data-expiration_hard="<%= model.get('expiration_hard') %>"></tr>
    <% 
    }
    if (Wat.C.checkACL('vm.see.block')) {
    %>
        <tr>
            <td><i class="fa fa-lock"></i><span data-i18n="Blocking"></span></td>
            <td>
                <% 
                if (model.get('blocked')) {
                %>
                    <!--
                    <i class="fa fa-lock" data-i18n="[title]Blocked"></i>
                    -->
                    <span data-i18n="Blocked"></span>
                <%
                }
                else {
                %>
                    <!--
                    <i class="fa fa-unlock" data-i18n="[title]Unblocked"></i>
                    -->
                    <span data-i18n="Unblocked"></span>
                <%
                }
                %>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('vm.see.created-by')) {
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_ADMINS %>"></i><span data-i18n="Created by"></span></td>
            <td>
                <span><%= model.get('creation_admin_name') %></span>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('vm.see.creation-date')) {
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
    <tbody class="bb-properties">
    </tbody>
</table>