<div>
    <input type="text" name="packages_search" class="fleft col-width-30 configuration-block" style="margin-right: 15px;" data-i18n="[placeholder]Search" value="<%= filters.search %>">
</div>
<div>
    <select name="packages-installed-filter">
        <option value="all" <%= filters.installed ? '' : selected="selected" %>>All</option>
        <option value="installed" <%= filters.installed ? selected="selected" : '' %>>Only installed</option>
    </select>
</div>
<table class="list">
    <tbody>
        <% _.each(models, function(model) { %>
            <tr>
                <td class="cell-check center">
                    <a class="button2 button-icon fa fa-plus-circle js-add-package-btn" data-package="<%= model.get('name') %>" data-id="<%= model.get('id') %>" title="Add" style="<%= model.get('installed') ? 'display: none' : '' %>"></a>
                    <a class="button button-icon fa fa-trash js-delete-package-btn" data-package="<%= model.get('name') %>" data-id="<%= model.get('id') %>" style="<%= model.get('installed') ? '' : 'display: none' %>"></a>
                </td>
                <td>
                    <span class="text" style="white-space: normal;"><%= model.get('name') %> <%= model.get('version') %></span>
                    <div class="text second_row" style="white-space: normal;"><%= model.get('description') %></div>
                </td>
            </tr>
        <% }); %>
        <%
        if (models.length == 0) {
        %>
            <tr>
                <td>
                    <span class="no-elements" data-i18n="There are no elements">
                        <%= i18n.t('There are no elements') %>
                    </span>
                </td>
            </tr>
        <%
        }
        %>
    </tbody>
</table>