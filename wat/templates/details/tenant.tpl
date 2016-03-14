<div class="details-header">
    <span class="<%= CLASS_ICON_TENANTS %> h1"><%= model.get('name') %></span>
    <div class="clear mobile"></div>
    <a class="button2 fright fa fa-eye js-show-details-actions" data-options-state="hidden" data-i18n="Actions"></a>
    
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
       
    <% if(Wat.C.checkACL('tenant.delete.')) { %>
    <a class="button fright button-icon--desktop js-button-purge fa fa-eraser" href="javascript:" data-i18n="[title]Purge"><span data-i18n="Purge" class="mobile"></span></a>
    <% } %>
    <div class="clear mobile"></div>
</div>


    <table class="details details-list col-width-100">
    <%   
    if (Wat.C.checkACL('tenant.see.description')) { 
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
    if (Wat.C.checkACL('tenant.see.block')) { 
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
    if (Wat.C.checkACL('tenant.see.language')) { 
    %>
        <tr>
            <td><i class="fa fa-globe"></i><span data-i18n="Language"></span></td>
            <td>
                <span data-i18n="<%= WAT_LANGUAGE_TENANT_OPTIONS[model.get('language')] %>"></span>
                <%
                switch (model.get('language')) {
                    case  'auto':
                %>
                        <div class="second_row" data-i18n="Language will be detected from the browser"></div>
                <%
                        break;
                }
                %>
            </td>
        </tr>
    <% 
    } 
    if (Wat.C.checkACL('tenant.see.blocksize')) { 
    %>
        <tr>
            <td><i class="fa fa-list"></i><span data-i18n="Block size"></span></td>
            <td>
                <span><%= model.get('block') %></span>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('tenant.see.created-by')) {
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_ADMINS %>"></i><span data-i18n="Created by"></span></td>
            <td>
                <span><%= model.get('creation_admin_name') %></span>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('tenant.see.creation-date')) {
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
    </table>
