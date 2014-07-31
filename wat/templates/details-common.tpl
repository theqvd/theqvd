<div class="wrapper-content">
    <div class="details-side bb-details-side js-side">
        un side o q ase
    </div>
    <div class="details-block">
        <table class="details">
            <tbody>
                <tr>
                    <td data-i18n>id</td>
                    <td>
                        <%= model.get('id') %>
                    </td>
                </tr>
                <tr>
                    <td data-i18n>name</td>
                    <td>
                        <%= model.get('name') %>
                    </td>
                </tr>
                <tr>
                    <td data-i18n>blocked</td>
                    <td>
                        <% 
                        if (model.get('blocked')) {
                        %>
                            <i class="fa fa-lock"></i>
                        <%
                        }
                        else {
                        %>
                            <i class="fa fa-unlock"></i>
                        <%
                        }
                        %>
                    </td>
                </tr>
                <% _.each(model.get('customProps'), function(val, key) { %>
                    <tr>
                        <td data-i18n><%= key %></td>
                        <td>
                            <%= val %>
                        </td>
                    </tr>
                <% }); %>
                
            </tbody>
        </table>
    </div>
</div>