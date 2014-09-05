<div class="details-header">
    <span class="fa fa-hdd-o h1" data-i18n><%= model.get('name') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
</div>

<table class="details details-list">
    <tr>
        <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-ellipsis-h"></i><span data-i18n>IP address</span></td>
        <td>
            <%= model.get('address') %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-heart"></i><span data-i18n>State</span></td>
        <td>
            <% 
        if (model.get('state') == 'running') {
            %>
            <i class="fa fa-play icon-play" data-i18n="[title]Running"></i>
            <%
            }
            else {
            %>
            <i class="fa fa-pause icon-stop" data-i18n="[title]Stopped"></i>
            <%
            }
            %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-lock"></i><span data-i18n>Blocking</span></td>
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