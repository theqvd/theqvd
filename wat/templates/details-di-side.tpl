<div class="side-component">
    <div class="side-header">
        <span class="h2" data-i18n>Virtual machines</span>
        <% if (Wat.C.checkACL('vm_see')) { %>
        <a class="button2 button-right fa fa-arrows-h" href="#/vms/di/<%= model.get('id') %>" data-i18n>Extended view</a>
        <% } %>
    </div>
    <div class="bb-details-side1">
        <div class="mini-loading"><i class="fa fa-gear fa-spin"></i></div>
    </div>
</div>