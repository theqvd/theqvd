<div class="details-header">
    <span class="fa fa-user h1" data-i18n><%= model.get('name') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
</div>

<div class="details-list">
    <span class="details-item fa fa-angle-right">
        <span data-i18n>Id</span>
        <div class="indented-data">
            <%= model.get('id') %>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <% 
        if (model.get('blocked')) {
        %>
            <i class="fa fa-lock" data-i18n>Blocked</i>
        <%
        }
        else {
        %>
            <i class="fa fa-unlock" data-i18n>Unblocked</i>
        <%
        }
        %>
    </span>
</div>