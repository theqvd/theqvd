<div class="details-header">
    <span class="fa fa-flask h1" data-i18n><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('osf.delete.')) { %>
    <a class="button fleft button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"></a>
    <% } %>
    <% if(Wat.C.checkGroupACL('osfEdit')) { %>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"></a>
    <% } %>
</div>

<table class="details details-list <% if (!enabledProperties) { %> col-width-100 <% } %>">
    <% 
    if (detailsFields['id'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
            <td>
                <%= model.get('id') %>
            </td>
        </tr>  
    <% 
    }
    if (detailsFields['overlay'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-exchange"></i><span data-i18n>Overlay</span></td>
            <td>
                <%= model.get('overlay') ? '<span class="fa fa-check"></span>' : '<span class="fa fa-remove"></span>' %>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['memory'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-bolt"></i><span data-i18n>Memory</span></td>
            <td>
                <%= model.get('memory') %> MB
            </td>
        </tr>
    <% 
    }
    if (detailsFields['user_storage'] != undefined) { 
    %>
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
        </tr>
    <% 
    }
    %>
</table>