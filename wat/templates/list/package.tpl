
<div>
    <input type="text" name="packages_search" class="fleft col-width-24 configuration-block" data-i18n="[placeholder]Search" value="<%= filters.search %>">
</div>
<table class="list">
    <tbody>
        <% _.each(models, function(model) { %>
            <tr>
                <td class="cell-check center">
                    <a class="button2 button-icon fa fa-plus-circle js-add-package-btn" data-package="<%= model.get('package') %>" title="Add"></a>
                    <i class="fa fa-check js-add-package-check" data-package="<%= model.get('package') %>" style="display: none"></i>
                </td>
                <td>
                    <span class="text"><%= model.get('package') %></span>
                    <div class="text second_row"><%= model.get('description') %></div>
                </td>
            </tr>
        <% }); %>
    </tbody>
</table>