<br>
<div class="list-navigation">    
    <div class="action-new-item">    
        <a href="javascript:" class="button fa fa-plus-circle js-button-new" data-i18n="New property"></a>
    </div>
</div>
            
<table class="list">
    <thead>
        <tr>
            <th data-i18n="Actions" colspan=2></th>
            <th data-i18n="Name"></th>
            <th data-i18n="Description" class="col-width-100"></th>
            <th data-i18n="Users"></th>
            <th data-i18n="Virtual machines"></th>
            <th data-i18n="Nodes"></th>
            <th data-i18n="OS Flavours"></th>
            <th data-i18n="Disk images"></th>
        </tr>
    </thead>
    <tbody>
        <tr class="js-zero-properties" style="<%= properties.length > 0 ? 'display: none;' : '' %>">
            <td colspan="9">
                <span class="no-elements" data-i18n="There are not elements">
                    <%= i18n.t('There are not elements') %>
                </span>
            </td>
        </tr>
        <% 
        $.each(properties.models, function (iProp, prop) { 
            var rowClass = 'js-row-property';
            var rowStyle = '';
            $.each(QVD_OBJS_WITH_PROPERTIES, function (iObj, qvdObj) {
                if (prop.get('in_' + qvdObj)) {
                    rowClass += ' js-row-property-' + qvdObj;
                }
                else if (selectedObj == qvdObj) {
                    rowStyle = 'display: none;'
                }
            });
        %>
        <tr class="<%= rowClass %>" style="<%= rowStyle %>">
            <td><a class="button button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete" data-property-id="<%= prop.get('property_id') %>"></a></td>
            <td><a class="button button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit" data-property-id="<%= prop.get('property_id') %>"></a></td>
            <td><%= prop.get('key') %></td>
            <td><%= prop.get('description') %></td>
            <td class="center <%= prop.get('in_user') ? '' : 'second_row' %>"><input type="checkbox" name="property-check" <%= prop.get('in_user') ? 'checked' : '' %> data-qvd-object="user" data-property-id="<%= prop.get('property_id') %>"></td>
            <td class="center <%= prop.get('in_vm') ? '' : 'second_row' %>"><input type="checkbox" name="property-check" <%= prop.get('in_vm') ? 'checked' : '' %> data-qvd-object="vm" data-property-id="<%= prop.get('property_id') %>"></td>
            <td class="center <%= prop.get('in_host') ? '' : 'second_row' %>"><input type="checkbox" name="property-check" <%= prop.get('in_host') ? 'checked' : '' %> data-qvd-object="host" data-property-id="<%= prop.get('property_id') %>"></td>
            <td class="center <%= prop.get('in_osf') ? '' : 'second_row' %>"><input type="checkbox" name="property-check" <%= prop.get('in_osf') ? 'checked' : '' %> data-qvd-object="osf" data-property-id="<%= prop.get('property_id') %>"></td>
            <td class="center <%= prop.get('in_di') ? '' : 'second_row' %>"><input type="checkbox" name="property-check" <%= prop.get('in_di') ? 'checked' : '' %> data-qvd-object="di" data-property-id="<%= prop.get('property_id') %>"></td>
        </tr>
        <% }); %>
    </tbody>
</table>
