
<div>
    <input type="text" name="packages_search" class="fleft col-width-25 configuration-block" data-i18n="[placeholder]Search" value="<%= filters.search %>">
</div>
<table class="list">
    <thead>
        <tr>
            <th>
                
            </th>
            <th>
                <span data-i18n="Name"><%= i18n.t('Name') %></span>
            </th>
            <th>
                <span data-i18n="Description"><%= i18n.t('Description') %></span>
            </th>
        </tr>
    </thead>
    <tbody>
        <% _.each(models, function(model) { %>
            <tr>
                <td class="cell-check center">
                    <a class="button2 button-icon fa fa-plus-circle js-add-package-btn" data-package="<%= model.get('package') %>" title="Add"></a>
                    <i class="fa fa-check js-add-package-check" data-package="<%= model.get('package') %>" style="display: none"></i>
                </td>
                <td>
                    <span class="text"><%= model.get('package') %></span>
                </td>
                <td style="white-space: normal;">
                    <span class="text second_row"><%= model.get('description') %></span>
                </td>
            </tr>
        <% }); %>
    </tbody>
</table>