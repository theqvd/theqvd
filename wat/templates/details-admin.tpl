<div class="details-header">
    <span class="fa fa-suitcase h1" data-i18n><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('administrator_update')) { %>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
    <% } %>
</div>

<table class="details details-list col-width-100">
    <tr">
        <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <% if(Wat.C.isSuperadmin()) { %>
    <tr>
        <td><i class="fa fa-building"></i><span data-i18n>Tenant</span></td>
        <td>
            <%= model.get('tenant_name') %>
        </td>
    </tr>
    <% } %>
</table>

<div class="bb-admin-roles admin-roles"></div>
