<fieldset class="vms-spy-details js-vms-spy-details">
    <legend data-i18n="Details"></legend>
    <div data-i18n="Virtual machine"></div>
    <p class="details-data"><span data-i18n="Name"></span>: <span class="bold"><%= model.get('name') %></span></p>
    
    <% if (Wat.C.checkACL('vm.see.user') || Wat.C.checkACL('vm.see.user-state')) { %>
        <div data-i18n="User"></div>
        <% if (Wat.C.checkACL('vm.see.user')) { %>
            <p class="details-data"><span data-i18n="Name"></span>: <span class="bold"><%= model.get('user_name') %></span></p>
        <% } %>
        <% if (Wat.C.checkACL('vm.see.user-state')) { %>
            <p class="details-data"><span data-i18n="State"></span>: <span class="bold"><%= model.get('user_state') %></span></p>
        <% } %>
    <% } %>
</fieldset>