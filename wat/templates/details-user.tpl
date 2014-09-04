<div class="details-header">
    <span class="fa fa-user h1" data-i18n><%= model.get('name') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
</div>

<table class="details details-list">
    <tr">
        <td data-i18n>Id</td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <tr>
        <td data-i18n>Blocking</td>
        <td>
            <% 
            if (model.get('blocked')) {
            %>
                <i class="fa fa-lock" data-i18n="[title]Blocked"></i>
            <%
            }
            else {
            %>
                <i class="fa fa-unlock" data-i18n="[title]Unblocked"></i>
            <%
            }
            %>
        </td>
    </tr>
</table>