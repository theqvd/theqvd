<div class="details-header">
    <span class="fa fa-user h1"><%= model.get('name') %></span>
    <div class="clear mobile"></div>
    <a class="button2 fright fa fa-eye js-show-details-actions show-details-actions" data-options-state="hidden" data-i18n="Actions"></a>
    
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

<div class="bb-details-layout-desktop desktop"></div>
<div class="bb-details-layout-mobile mobile"></div>