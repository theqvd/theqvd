<div class="details-header">
    <span class="<%= CLASS_ICON_TENANTS %> h1"><%= model.get('name') %></span>
    <div class="clear mobile"></div>
    <a class="button2 fright fa fa-eye js-show-details-actions show-details-actions" data-options-state="hidden" data-i18n="Actions"></a>
    
    <% if(Wat.C.checkACL('tenant.delete.')) { %>
    <a class="button fleft button-icon--desktop js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"><span data-i18n="Delete" class="mobile"></span></a>
    <% } %> 
    <% if(Wat.C.checkGroupACL('tenantEdit')) { %>
    <a class="button fright button-icon--desktop js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"><span data-i18n="Edit" class="mobile"></span></a>
    <% } %>
    
    <% 
    if (Wat.C.checkACL('tenant.update.block')) {
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
       
    <% if(Wat.C.checkACL('tenant.purge.')) { %>
    <a class="button fright button-icon--desktop js-button-purge fa fa-eraser" href="javascript:" data-i18n="[title]Purge"><span data-i18n="Purge" class="mobile"></span></a>
    <% } %>
    <div class="clear mobile"></div>
</div>

<div class="bb-details-layout-desktop desktop"></div>
<div class="bb-details-layout-mobile mobile"></div>