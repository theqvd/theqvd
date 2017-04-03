<div class="details-header">
    <span class="fa fa-suitcase h1"><%= model.get('name') %></span>
    <div class="clear mobile"></div>
    <a class="button2 fright fa fa-eye js-show-details-actions show-details-actions" data-options-state="hidden" data-i18n="Actions"></a>
    
    <% if(Wat.C.checkACL('administrator.delete.') && Wat.C.adminID != model.get('id')) { %>
        <a class="button fleft button-icon--desktop js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"><span data-i18n="Delete" class="mobile"></span></a>
    <% } %>
    
    <% if(Wat.C.checkGroupACL('administratorEdit')) { %>
        <a class="button fright button-icon--desktop js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"><span data-i18n="Edit" class="mobile"></span></a>
    <% } %>
    
    <div class="clear mobile"></div>
</div>

<div class="bb-details-layout-desktop desktop"></div>
<div class="bb-details-layout-mobile mobile"></div>