<div class="details-header">
    <span class="fa fa-flask h1" data-i18n><%= model.get('name') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
</div>

<table class="details details-list">
    <tr>
        <td data-i18n>Id</td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <tr>
        <td data-i18n>Overlay</td>
        <td>
            <%= model.get('overlay') %>
        </td>
    </tr>
    <tr>
        <td data-i18n>Memory</td>
        <td>
            <%= model.get('memory') %> MB
        </td>
    </tr>
    <tr>
        <td data-i18n>User storage</td>
        <td>
            <%
            if (!model.get('user_storage')) {
            %>
                <span data-i18n="No">
                    <%= i18n.t('No') %>
                </span>
            <%
            }
            else {
                print(model.get('user_storage')  + " MB");
            }
            %>
        </td>
    </span>
</table>