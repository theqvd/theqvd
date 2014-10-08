<div class="details-header">
    <span class="fa fa-flask h1" data-i18n><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('osf_update')) { %>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
    <% } %>
</div>

<table class="details details-list">
    <tr>
        <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-exchange"></i><span data-i18n>Overlay</span></td>
        <td>
            <%= model.get('overlay') %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-bolt"></i><span data-i18n>Memory</span></td>
        <td>
            <%= model.get('memory') %> MB
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-archive"></i><span data-i18n>User storage</span></td>
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