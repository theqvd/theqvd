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
    <a class="button2 fright fa fa-eye js-show-details-actions show-details-actions" data-options-state="hidden" data-i18n="Actions"></a>
    
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

<div class="bb-details-layout-desktop desktop"></div>
<div class="bb-details-layout-mobile mobile"></div>