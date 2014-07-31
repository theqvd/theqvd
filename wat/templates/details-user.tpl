<div class="h1">
    <span class="fa fa-user" data-i18n><%= model.get('name') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>edit</a>
</div>

<div class="details-list">
    <span class="details-item fa fa-angle-right">
        <span data-i18n>id</span>: <%= model.get('id') %>
    </span>
    <span class="details-item fa fa-angle-right">
        <% 
        if (model.get('blocked')) {
        %>
            <i class="fa fa-lock" data-i18n>blocked</i>
        <%
        }
        else {
        %>
            <i class="fa fa-unlock" data-i18n>Unblocked</i>
        <%
        }
        %>
    </span>
    <span class="details-item fa fa-angle-right" data-i18n>user_properties</span>
</div>